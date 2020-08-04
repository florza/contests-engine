class Result

  # returns an error message or nil
  def self.validate(result, match, contest)
    return if result.nil?
    return validate_result(result, contest) || validate_sets(result) ||
            validate_winner(result, match)
  end

  # result as seen from Participant_1, this is used in most cases
  def self.to_s(result)
    return nil if result.nil?
    result = JSON.parse(result) if result.instance_of?(String)
    result.map { |set| set[0].to_s + ':' + set[1].to_s}.join(' / ')
  end

  # Result as seen from Participant_2
  def self.to_s_reversed(result)
    return nil if result.nil?
    result = JSON.parse(result) if result.instance_of?(String)
    result.map { |set| set[1].to_s + ':' + set[0].to_s}.join(' / ')
  end

  # sums of points/matches/sets/games won/tied/lost
  # stored as a hash in Match.contesttype_params
  def self.get_counts(match, contest)
    return nil if match.result.nil?
    counts = {}
    counts['points'] = get_count_points(match, contest)
    counts['matches'] = get_count_matches(match)
    counts['sets'] = get_count_sets(match)
    counts['games'] = get_count_games(match)
    return counts
  end

  # two hash constants defined as functions to avoid changes without deep copy
  # points: [p1, p2], others: [won, tied, lost] as seen by p1 (reverse for p2)
  # no tie in games, rarely in sets (probably only walk over results)
  def self.empty_match_counts
      { 'points' => [0, 0], 'matches' => [0, 0, 0],
        'sets' => [0, 0, 0], 'games' => [0, 0] }
  end

  # same as above, but only this participants points
  def self.empty_participant_counts
    { 'points' => 0, 'matches' => [0, 0, 0],
      'sets' => [0, 0, 0], 'games' => [0, 0] }
  end


  private

  def self.validate_result(result, contest)
    if (!result.instance_of?(Array)) || result.empty? ||
        result.length > (contest.nbr_sets * 2 - 1)
      return "is not an array with 1 to #{contest.nbr_sets * 2 - 1} subarrays"
    end
    return false
  end

  def self.validate_sets(result)
    result.each_with_index do |set, i|
      if !set.instance_of?(Array) || set.size != 2 ||
          !set[0].instance_of?(Integer) || set[0] < 0 ||
          !set[1].instance_of?(Integer) || set[1] < 0
        return "of set #{i+1} is not an array of two positive numbers"
      end
    end
    return false
  end

  def self.validate_winner(result, match)
    sets_participant_1 = sets_participant_2 = 0
    result.each_with_index do |set, i|
      sets_participant_1 += 1 if set[0] > set[1]
      sets_participant_2 += 1 if set[0] < set[1]
    end
    if sets_participant_1 > sets_participant_2
      winner_id = match.participant_1_id
    elsif sets_participant_1 < sets_participant_2
      winner_id = match.participant_2_id
    else
      winner_id = nil
      # depends on yet undefined params: return "must have a winner"
    end
    if winner_id != match.winner_id
      return "given winner and set results do not fit"
    end
    return false
  end

  def self.get_count_points(match, contest)
    points = contest.contesttype_params['points']
    if match.winner_id == match.participant_1_id
      return [points['win'], points['loss']]
    elsif match.winner_id == match.participant_2_id
      return [points['loss'], points['win']]
    else
      return [points['tie'], points['tie']]
    end
  end

  def self.get_count_matches(m)
    if m.winner_id == m.participant_1_id
      return [1, 0, 0]
    elsif m.winner_id == m.participant_2_id
      return [0, 0, 1]
    else
      return [0, 1, 0]
    end
  end

  def self.get_count_sets(m)
    sw = st = sl = 0
    m.result.each do |set|
      if set[0] > set[1]
        sw += 1
      elsif set[0] < set[1]
        sl += 1
      else
        st += 1
      end
    end
    return [sw, st, sl]
  end

  def self.get_count_games(m)
    gw = gl = 0
    m.result.each do |set|
      gw += set[0]
      gl += set[1]
    end
    return [gw, gl]
  end
end
