class Result

  # returns an error message or nil
  def self.validate(result, match, result_params)
    if (result.nil? || result.empty? ||
        result['score'].nil? || result['score'].empty?)
      return 'empty result cannot have a winner or tie' if !match.winner_id.nil?
      return false
    end
    return validate_format(result, result_params) ||
            validate_sets(result) ||
            validate_winner(result, match, result_params)
  end

  # result as seen from Participant_1, this is used in most cases
  def self.to_s(result)
    return nil if result.nil?
    # result = JSON.parse(result) if result.instance_of?(String)
    score = result['score'].map { |set|
              set[0].to_s + ':' + set[1].to_s }.join(' / ')
    result['walk_over'] ? score + ' (w.o.)' : score
  end

  # Result as seen from Participant_2
  def self.to_s_reversed(result)
    return nil if result.nil?
    # result = JSON.parse(result) if result.instance_of?(String)
    score = result['score'].map { |set|
              set[1].to_s + ':' + set[0].to_s }.join(' / ')
    result['walk_over'] ? score + ' (w.o.)' : score
  end

  # sums of points/matches/sets/games won/tied/lost
  # stored as a hash in Match.stats
  def self.get_stats(match, result_params)
    return nil if match.result.nil?
    stats = {}
    stats['points'] = get_stats_points(match, result_params)
    stats['matches'] = get_stats_matches(match)
    stats['sets'] = get_stats_sets(match)
    stats['games'] = get_stats_games(match)
    return stats
  end

  # two hash constants defined as functions to avoid changes without deep copy
  # points: [p1, p2]
  # won, tied, lost: as seen by p1 (reverse for p2)
  # no tie in games, rarely in sets (probably only walk over results)
  def self.empty_match_stats
      { 'points' => [0, 0], 'matches' => [0, 0, 0],
        'sets' => [0, 0, 0], 'games' => [0, 0] }
  end

  # same as above, but only this participants points
  def self.empty_participant_stats
    { 'points' => 0, 'matches' => [0, 0, 0],
      'sets' => [0, 0, 0], 'games' => [0, 0] }
  end


  private

  def self.validate_format(result, result_params)
    score = result['score']
    return 'Result must contain a score' if score.nil?
    max_sets = result_params['winning_sets'] * 2 - 1 || 1
    if (!score.instance_of?(Array)) || score.empty? ||
        score.length > max_sets
      return "is not an array with 1 to #{max_sets} subarrays"
    end
    return false
  end

  def self.validate_sets(result)
    result['score'].each_with_index do |set, i|
      if !set.instance_of?(Array) || set.size != 2 ||
          !set[0].instance_of?(Integer) || set[0] < 0 ||
          !set[1].instance_of?(Integer) || set[1] < 0
        return "of set #{i+1} is not an array of two positive numbers"
      end
    end
    return false
  end

  def self.validate_winner(result, match, result_params)
    sets_participant_1 = sets_participant_2 = 0
    result['score'].each_with_index do |set, i|
      sets_participant_1 += 1 if set[0] > set[1]
      sets_participant_2 += 1 if set[0] < set[1]
    end
    if sets_participant_1 > sets_participant_2
      winner_id = match.participant_1_id
    elsif sets_participant_1 < sets_participant_2
      winner_id = match.participant_2_id
    elsif !(result['walk_over'] || result_params['tie_allowed'])
      return 'no ties allowed as score'
    else
      winner_id = 0
    end
    if !result['walk_over'] && winner_id != match.winner_id
      return 'given winner and set scores do not fit'
    end
    if result['walk_over'] && match.winner_id.nil?
      return 'winner must be defined for a walk-over'
    end
    return false
  end

  def self.get_stats_points(match, result_params)
    if match.winner_id == match.participant_1_id
      return [result_params['points_win'],
              result_params['points_loss']]
    elsif match.winner_id == match.participant_2_id
      return [result_params['points_loss'],
              result_params['points_win']]
    else
      return [result_params['points_tie'],
              result_params['points_tie']]
    end
  end

  def self.get_stats_matches(m)
    if m.winner_id == m.participant_1_id
      return [1, 0, 0]
    elsif m.winner_id == m.participant_2_id
      return [0, 0, 1]
    else
      return [0, 1, 0]
    end
  end

  def self.get_stats_sets(m)
    sw = st = sl = 0
    m.result['score'].each do |set|
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

  def self.get_stats_games(m)
    gw = gl = 0
    m.result['score'].each do |set|
      gw += set[0]
      gl += set[1]
    end
    return [gw, gl]
  end
end
