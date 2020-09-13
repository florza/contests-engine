class Result

  # returns an error message or nil
  def self.validate(result, match, result_params)
    if result.blank? || result['score_p1'].blank? || result['score_p2'].blank?
      return 'empty result cannot have a winner or tie' unless match.winner_id.nil?
      return false
    end
    return validate_format(result, result_params) ||
            validate_sets(result) ||
            validate_winner(result, match, result_params)
  end

  # result as seen from Participant_1, this is used in most cases
  def self.to_s(result)
    return nil if result.blank?
    # result = JSON.parse(result) if result.is_a?(String)
    score = result['score_p1'].zip(result['score_p2']).map { |set|
              set[0].to_s + ':' + set[1].to_s }.join(' / ')
    result['walk_over'] ? score + ' (w.o.)' : score
  end

  # Result as seen from Participant_2
  def self.to_s_reversed(result)
    return nil if result.blank?
    # result = JSON.parse(result) if result.is_a?(String)
    score = result['score_p1'].zip(result['score_p2']).map { |set|
              set[1].to_s + ':' + set[0].to_s }.join(' / ')
    result['walk_over'] ? score + ' (w.o.)' : score
  end

  ##
  # Get stats of the actual match, i.e.
  # sums of points/matches/sets/games that are won/tied/lost
  # Stored as a hash in Match.stats as base for further statistics

  def self.get_stats(match, result_params)
    if match.winner_id.nil?
      return empty_match_stats
    end
    score = match.result['score_p1'].zip(match.result['score_p2'])
    stats = {}
    stats['points'] = get_stats_points(match, result_params)
    stats['matches'] = get_stats_matches(match)
    stats['sets'] = get_stats_sets(score)
    stats['games'] = get_stats_games(score)
    return stats
  end

  ##
  # ctype-dependent params of match
  # (solved with case, to avoid overkill with subclassing Result)
  # def self.get_ctype_params(match, ctype)
  #   case ctype
  #   when 'Groups'
  #     return match.ctype_params # no change
  #   when 'KO'
  #     params = match.ctype_params || {}
  #     params['act_round'] =
  #   end
  # end

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
    { 'points' => 0, 'matches' => [0, 0, 0], 'sets' => [0, 0, 0],
      'games' => [0, 0], 'rankvalue' => 0, 'rank' => 0 }
  end

  def self.get_rankvalue(stats)
    # generate a number in the form AAABBBCCCDDD
    # which sorts after the detailed ranking rules:
    # AAA is the number of points won
    # BBB is 500 + (MatchesWon - MatchesLost) i.e. +4 => 504, -4 => 496
    # CCC is 500 + (SetsWon - SetsLost)
    # DDD is 500 + (GamesWon - GamesLost)
    if stats.blank?
      return 500500500
    end
    return 1000000000 * stats['points'] +
      500000000 + 1000000 * (stats['matches'][0] - stats['matches'][2]) +
      500000 + 1000 * (stats['sets'][0] - stats['sets'][2]) +
      500 + (stats['games'][0] - stats['games'][1])
  end

  private

  def self.validate_format(result, result_params)
    max_sets = result_params['winning_sets'] * 2 - 1 || 1
    unless (result['score_p1'].is_a?(Array) &&
        result['score_p2'].is_a?(Array) &&
        result['score_p1'].size === result['score_p2'].size &&
        result['score_p1'].size >= 1 &&
        result['score_p1'].size <= max_sets)
      return "score_p1 and score_p2 are not arrays with 1 to #{max_sets} elements"
    end
    return false
  end

  def self.validate_sets(result)
    score = result['score_p1'].zip(result['score_p2'])
    score.each_with_index do |set, i|
      if !set.is_a?(Array) || set.size != 2 ||
          !set[0].is_a?(Integer) || set[0] < 0 ||
          !set[1].is_a?(Integer) || set[1] < 0
        return "of set #{i+1} is not an array of two non negative numbers"
      end
    end
    return false
  end

  def self.validate_winner(result, match, result_params)
    sets_participant_1 = sets_participant_2 = 0
    score = result['score_p1'].zip(result['score_p2'])
    score.each_with_index do |set, i|
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
    return  case match.winner_id
            when match.participant_1_id
              [result_params['points_win'], result_params['points_loss']]
            when match.participant_2_id
              [result_params['points_loss'], result_params['points_win']]
            else
              [result_params['points_tie'], result_params['points_tie']]
            end
  end

  def self.get_stats_matches(m)
    return  case m.winner_id
            when m.participant_1_id then [1, 0, 0]
            when m.participant_2_id then [0, 0, 1]
            else [0, 1, 0]
            end
  end

  def self.get_stats_sets(score)
    sw = st = sl = 0
    score.each do |set|
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

  def self.get_stats_games(score)
    gw = gl = 0
    score.each do |set|
      gw += set[0]
      gl += set[1]
    end
    return [gw, gl]
  end
end
