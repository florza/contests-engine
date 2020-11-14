class DrawManager
  extend ActiveModel::Naming
  include ActiveRecord::Validations

  attr_reader :draw_tableau, :draw_seeds

  def initialize(params)
    @contest = Contest.find(params[:contest_id] || params[:id])
    @participants = @contest.participants.to_a

    if params.class == String
      params = JSON.parse(params).symbolize_keys
    end
    @draw_tableau = params.dig(:data, :attributes, :draw_tableau)
    @draw_tableau = JSON.parse(@draw_tableau) if @draw_tableau.class == String
    @draw_tableau = [[]] if @draw_tableau.blank?

    @drawn_participants = @draw_tableau.flatten.select {|p| p.to_i > 0}

    @draw_seeds = params.dig(:data, :attributes, :draw_seeds)
    @draw_seeds = JSON.parse(@draw_seeds) if @draw_seeds.class == String
    @draw_seeds = [] if @draw_seeds.blank?
  end

  # Graphity resources need an id on the model
  def id
    @contest.id
  end

  def draw
    seeds = @draw_seeds
    if seeds.size > 0
      generate_seeded_draw
    elsif !complete? && valid?
      complement_draw
    end
    update_contest if valid?
    update_participants if valid? && complete?
    create_matches if valid? && complete?
  end

  def delete_draw(contest)
    return if !valid?
    if contest.ctype_params || contest.draw_at
      contest.ctype_params.delete('draw_tableau')
      contest.ctype_params.delete('draw_seeds')
      contest.draw_at = nil
      contest.save!
    end
    contest.participants.each do |p|
      if p.ctype_params && p.ctype_params['draw_pos'] &&
          (p.ctype_params['draw_group'] || p.ctype_params['draw_pos'])
        p.ctype_params.delete('draw_group')
        p.ctype_params.delete('draw_pos')
        p.save!
      end
    end
    contest.matches.destroy_all
    true
  end

  def create_matches(group, matches, match_ids = {})
    matches.each do |key, match|
      params = { 'draw_group' => group,
                 'draw_round' => match[:round] }
      params['draw_pos'] = match[:pos] if match[:pos]
      m = @contest.matches.new(
        participant_1_id: match[:participant_1_id],
        participant_2_id: match[:participant_2_id],
        ctype_params: { 'draw_group' => group,
                        'draw_round' => match[:round],
                        'draw_pos' => match[:pos] },
        updated_by_token: nil,
        updated_by_user_id: @contest.user_id
      )
      create_matches_before_save(m, match_ids)
      if m.save
        match_ids[[match[:round], match[:pos]]] = m.id
      else
        errors.add(:ko, 'match creation failed') && return
      end
    end
  end

  ##
  # This method is called back from the above create_matches for every
  # newly created match, just before it is saved.
  # This default implementation does nothing, but it can be overwritten
  # by subclasses to fill ctype-specific fields that are not filled
  # by the general method.

  def create_matches_before_save(match, match_ids)
    # no-op
  end

  ##
  # General methods to support validation for all ctypes

  def validate_draw_allowed
    if @contest.has_started
      errors.add(:draw, 'must not be changed if matches were already played')
    end
  end

  def validate_drawn_uniqueness
    if @drawn_participants.uniq.size != @drawn_participants.size
      errors.add(:draw_tableau, 'participant ids in sequence are not unique')
    end
  end

  def validate_drawn_ids
    @drawn_participants.each do |ppant_id|
      unless @participants.find {|p| p.id == ppant_id}
        errors.add(:draw_tableau, "invalid participant_id #{ppant_id}")
      end
    end
  end

  def complete?
    @drawn_participants.size == @participants.size
  end

  ##
  # Get order of seed positions and byes for n participants in a KO tableau.
  # May also be used for the distribution of smaller and bigger groups
  # in groups contests, so it's defined here.
  #
  #   2  # => [1, 2]
  #   4  # => [1, 4, 3, 2]
  #   7  # => [1, 'BYE', 5, 4, 3, 6, 7, 2]
  #   13 # => [1, 'BYE', 9, 8, 5, 12, 13, 4, 3, 'BYE', 11, 6, 7, 10, 'BYE', 2]

  def get_ko_structure(n)
    return [] if n < 2
    s = [1, 2]
    while s.size < n
      newSize = 2 * s.size
      s1 = s.each_with_index.map do |p, i|
        pNew = newSize + 1 - p
        pNew = 'BYE' if pNew > n
        i.even? ? [p, pNew] : [pNew, p]
      end
      s = s1.flatten
    end
    return s
  end

  # required manual definitions for validations in not ActiveRecord classes
  def persisted?
    false
  end

  def new_record?
    true
  end

  private

  def update_contest
    draw_params = { 'draw_tableau' => @draw_tableau,
                    'draw_seeds' => @draw_seeds }
    params = (@contest.ctype_params || {}).merge!(draw_params)
    unless @contest.update(
      { ctype_params: params,
        draw_at: DateTime.now,
        last_action_at: DateTime.now }
    )
      errors.add(:draw, 'contest update failed')
    end
  end

  def update_participants
    #Participant.transaction do
      @draw_tableau.each_with_index do |members, group0|
        members.each_with_index do |participant_id, pos0|
          next if participant_id.to_i <= 0
          participant = @participants.find {|p| p.id == participant_id}
          participant.ctype_params = { 'draw_group' => group0 + 1,
                                       'draw_pos' => pos0 + 1 }
          unless participant.save
            errors.add(:draw, 'participants update failed') && return
          end
        end
      end
    #end
  end

end
