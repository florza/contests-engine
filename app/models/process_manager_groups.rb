class ProcessManagerGroups < ProcessManager

  def self.process_result(match, contest)
    update_participants_stats(contest)
  end

  private

  def self.update_participants_stats(contest)
    participants = {}
    contest.reload
    contest.matches.each do |match|
      if match.result
        sum_stats_participant(1, match, participants)
        sum_stats_participant(2, match, participants)
        #pp "- match #{match.id}", participants
      end
    end
    contest.participants.each do |p|
      p.stats = participants[p.id] || Result::empty_participant_stats
      p.save!
    end
  end

  def self.sum_stats_participant(part_1_2, match, participants)
    if match.stats.nil?
      debugger
    end
    stats_m = match.stats.clone
    if part_1_2 == 1
      p_id = match.participant_1_id
    else
      p_id = match.participant_2_id
      ['points', 'matches', 'sets', 'games'].each do |category|
        # reverse: as seen by participant_2, without changing match
        stats_m[category] = match.stats[category].reverse
      end
    end
    stats_p = participants[p_id]
    if stats_p.nil?
      stats_p = Result.empty_participant_stats
    end
    stats_p['points'] += stats_m['points'][0]
        ['matches', 'sets', 'games'].each do |category|
      stats_p[category] =
          stats_p[category].zip(stats_m[category]).map {|a| a.sum}
    end
    if p_id.nil?
      debugger
    end
    participants[p_id] = stats_p
  end

end
