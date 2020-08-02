class ProcessManagerGroups < ProcessManager

  def self.process_result(match, contest)
    update_participants_points(match, contest)
  end

  private

  def self.update_participants_points(match, contest)
    participants = {}
    contest.matches.each do |m|
      if m.result
        sum_points_participant(1, match, participants)
        sum_points_participant(2, match, participants)
      end
    end
    contest.participants.each do |p|
      p.contesttype_params['grp_counts'] =
                  participants[p.id] || Result::empty_participant_counts
      p.save!
    end
  end

  def self.sum_points_participant(part_1_2, match, participants)
    counts_m = match.contesttype_params['counts']
    if part_1_2 == 1
      p_id = match.participant_1_id
    else
      p_id = match.participant_2_id
      ['points', 'matches', 'sets', 'games'].each do |category|
        counts_m[category].reverse!  # that's how they are seen by p_2, not p_1
      end
    end
    counts_p = participants[p_id]
    if counts_p.nil?
      counts_p = Result.empty_participant_counts
    end
    counts_p['points'] += counts_m['points'][0]
    ['matches', 'sets', 'games'].each do |category|
      counts_p[category] =
          counts_p[category].zip(counts_m[category]).map {|a| a.sum}
    end
    participants[p_id] = counts_p
  end

end
