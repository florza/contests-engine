class DrawManagerKO < DrawManager

  validate :validate_ko

  def initialize(contest, params)
    super
    @ko_startpos = params[:ko_startpos]
    @ko_startpos = JSON.parse(@ko_startpos) if @ko_startpos.class == String
  end

  def update_contest
    update_contest_draw_info( 'ko_startpos' => @ko_startpos )
  end

  def update_participants
    update_participants_draw_info([@ko_startpos])
  end

  def get_participant_params(group, pos)
    return { 'ko_pos' => pos }
  end

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
    return # TODO delete and correct following code!
    if @ko_startpos != @participants.count
      errors.add(:groups, 'wrong number of participants in positions')
    end
    if @ko_startpos.uniq.count != @participants.count
      errors.add(:groups, 'participant ids in positions are not unique')
    end
    @ko_startpos.each do |participant_id|
      if participant_id != 0
        if !@participants.find { |p| p.id == participant_id }
          errors.add(:groups, "invalid id #{participant_id} in positions")
        end
      end
    end
  end

  def get_ko_schedule
    matches = {}
    round = firstRound = getTableauSize(@ko_startpos.size) / 2
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

  def getTableauSize(n)
    return 0 if n < 2
    s = 2
    s *= 2 while s < n
    return s
  end

end
