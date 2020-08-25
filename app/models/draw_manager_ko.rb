class DrawManagerKO < DrawManager

  validate :validate_ko

  def initialize(contest, params)
    super
    @ko_startpos = params[:ko_startpos]
    @ko_startpos = JSON.parse(@ko_startpos) if @ko_startpos.class == String
    @ko_seeds = params[:ko_seeds]
    @ko_startpos = JSON.parse(@ko_seeds) if @ko_seeds.class == String
  end

  def draw
    if @ko_seeds && @ko_seeds.count > 0
      generate_seeded_draw
    elsif !complete? && valid?
      complete_draw
    end
    super
  end

  def update_contest
    update_contest_draw_info( 'ko_startpos' => @ko_startpos )
  end

  def update_participants
    if complete?
      update_participants_draw_info([@ko_startpos]) do |group, pos|
        { 'ko_pos' => pos }
      end
    end
  end

  def delete_draw(contest)
    if contest.ctype_params
      contest.ctype_params.delete('ko_startpos')
      contest.ctype_params.delete('ko_seeds')
      contest.save!
    end
    contest.participants.each do |p|
      if p.ctype_params && p.ctype_params['ko_pos']
        p.ctype_params.delete('ko_pos')
        p.save!
      end
    end
    contest.matches.destroy_all
  end

  private

  def create_matches
    @contest.matches.destroy_all
    matches = get_ko_schedule
    match_ids = {}
    # ordering starts with the final, so when a match is created
    # the id of its successor has already been placed in match_ids
    matches.sort.each do |key, match|
      m = @contest.matches.new(
        participant_1_id: match[0],
        participant_2_id: match[1],
        ctype_params: { 'ko_round': match[:round], 'ko_pos': match[:pos] },
        updated_by_token: nil,
        updated_by_user_id: @contest.user_id
      )
      if key[0] > 1
        m.winner_next_match_id = match_ids[[match[:round], match[:pos]]]
        m.winner_next_place_1 = match[:round].odd?
      end
      if !m.save
        errors.add(:ko, 'match creation failed') and return
      else
        match_ids[[m['ko_round'], m['ko_pos']]] = m.id
      end
    end
  end

  def validate_ko
    validate_ko_size
    validate_ko_byes
    validate_ko_uniqueness
    validate_ko_ids
  end

  def validate_ko_size
    tableau_size = get_tableau_size(@participants.count)
    if @ko_startpos.count != tableau_size
      errors.add(:ko_startpos, "must contain #{tableau_size} positions")
    end
  end

  def validate_ko_byes
    get_tableau_structure(@participants.count).each_with_index do |pos, i|
      if (pos.nil? && @ko_startpos[i] != 'BYE') ||
          (pos && @ko_startpos[i] == 'BYE')
        errors.add(:ko_startpos, "contains wrong BYE positions")
        break
      end
    end
  end

  def validate_ko_uniqueness
    pp @ko_startpos
    drawn_ppants = @ko_startpos.select {|p| p.to_i > 0}
    if drawn_ppants.uniq.count != drawn_ppants.count
      errors.add(:ko_startpos, 'must contain unique participant ids')
    end
  end

  def validate_ko_ids
    @ko_startpos.select {|p| p.to_i > 0}.each do |ppant_id|
      if !@participants.find {|p| p.id == ppant_id}
        errors.add(:ko_startpos, "invalid participant id #{ppant_id}")
      end
    end
  end

  def complete?
    @ko_startpos.count {|p| p.to_i > 0} == @participants.count
  end

  def complete_draw
    ppants_to_draw = @participants.select {|p| !@ko_startpos.include?(p.id) }
    pos_to_draw = @ko_startpos.each_with_index.select {|p, i| p == 0}
    pos_to_draw.each do |p, i|
      draw = rand(ppants_to_draw.count)
      @ko_startpos[i] = ppants_to_draw[draw].id
      ppants_to_draw.delete_at(draw)
    end
    # raise RuntimeError if ppants_to_draw.count != 0
  end

  def get_ko_schedule
    matches = {}
    round = firstRound = get_tableau_size(@ko_startpos.size) / 2
    while round > 0
      1.upto(round) do |pos|
        pos2 = 2 * pos
        ppant1 = ppant2 = nil
        if round == firstRound
          ppant1 = @ko_startpos[pos2 - 2]
          ppant2 = @ko_startpos[pos2 - 1]
          next if ppant1 == 0 || ppant2 == 0  # Bye, i.e. no match in first round
        elsif round == firstRound / 2
          if matches[[2 * round, 2 * pos - 1]].nil?
            ppant1 = @ko_startpos[4 * (pos - 1)]  # Bye, winner is in next round
          elsif matches[[2 * round, 2 * pos]].nil?
            ppant2 = @ko_startpos[4 * pos - 1]    # Bye, winner is in next round
          end
        end
        matches[[round, pos]] = { participant_1_id: ppant1,
                                  participant_2_id: ppant2,
                                  round: round,
                                  pos: pos }
      end
      round /= 2
    end
    return matches
  end

  # Get order of seed positions and byes for n participants.
  #
  #   2  # => [1, 2]
  #   4  # => [1, 4, 3, 2]
  #   7  # => [1, nil, 5, 4, 3, 6, 7, 2]
  #   13 # => [1, nil, 9, 8, 5, 12, 13, 4, 3, nil, 11, 6, 7, 10, nil, 2]
  def get_tableau_structure(n)
    return [] if n < 2
    s = [1, 2]
    while s.size < n
      newSize = 2 * s.size
      s1 = s.each_with_index.map do |p, i|
        pNew = newSize + 1 - p
        pNew = nil if pNew > n
        i.even? ? [p, pNew] : [pNew, p]
      end
      s = s1.flatten
    end
    return s
  end

  # x | x >= n and x is a power of 2
  def get_tableau_size(n)
    2 ** Math.log(n, 2).ceil
  end

end
