class Result

  # returns an error message or nil
  def self.validate(result, match, contest)
    return if result.nil?
    begin
      result = JSON.parse(result) if result.instance_of?(String)
    rescue JSON::ParserError
      return "is not a valid JSON field"
    end
    return validate_result(result, contest) || validate_sets(result) ||
            validate_winner(result, match)
  end

  def self.to_s(result)
    return nil if result.nil?
    result = JSON.parse(result) if result.instance_of?(String)
    result.map { |set| set[0].to_s + ':' + set[1].to_s}.join(' / ')
  end

  def self.to_s_reversed(result)
    return nil if result.nil?
    result = JSON.parse(result) if result.instance_of?(String)
    result.map { |set| set[1].to_s + ':' + set[0].to_s}.join(' / ')
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
    return "given winner and set results do not fit" if winner_id != match.winner_id
    return false
  end

end
