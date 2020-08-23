class DrawManager
  extend ActiveModel::Naming
  include ActiveRecord::Validations

  def initialize(contest, params)
    @contest = contest
    @participants = @contest.participants.to_a
  end

  def draw
    update_contest if valid?
    update_participants if valid?
    create_matches if valid?
  end

  def update_contest_draw_info(params)
    newparams = (@contest.ctype_params || {}).merge!(params)
    if !@contest.update(
      { ctype_params: params,
        draw_at: DateTime.now,
        last_action_at: DateTime.now }
    )
      errors.add(:draw, 'contest update failed')
    end
  end

  def update_participants_draw_info(groups)
    Participant.transaction do
      groups.each_with_index do |members, group0|
        members.each_with_index do |participant_id, pos0|
          next if participant_id == 0
          participant = @participants.find { |p| p.id == participant_id }
          participant.ctype_params =
              get_participant_params(group0 + 1, pos0 + 1)
          if !participant.save
            errors.add(type, 'participants update failed')
            return
          end
        end
      end
    end
  end

  # required manual definitions for validations in not ActiveRecord classes
  def persisted?
    false
  end

  def new_record?
    true
  end

end
