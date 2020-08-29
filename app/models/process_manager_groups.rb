class ProcessManagerGroups < ProcessManager

  def self.process_result(match, contest)
    update_participants_stats(contest)
  end

  private

  def self.update_participants_stats(contest)
    stats = {}
    contest.reload
    sum_match_stats(contest.matches, stats)
    set_stats_with_no_matches(contest.participants, stats)
    update_rank(contest.participants, stats)
    update_participants(contest.participants, stats)
  end

  private

  def self.sum_match_stats(matches, stats)
    matches.each do |match|
      unless match.winner_id.nil?
        sum_stats_participant(1, match, stats)
        sum_stats_participant(2, match, stats)
        #pp "- match #{match.id}", participants
      end
    end
  end

  def self.sum_stats_participant(part_1_2, match, stats)
    if match.stats.nil?
      puts 'Match found without stats:', match
    end
    grp_nr = match.ctype_params['grp_nr']
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
    stats_p = stats.dig(grp_nr, p_id)
    if stats_p.nil?
      stats_p = Result.empty_participant_stats
    end
    stats_p['points'] += stats_m['points'][0]
    ['matches', 'sets', 'games'].each do |category|
      stats_p[category] =
          stats_p[category].zip(stats_m[category]).map {|a| a.sum}
    end
    if stats[grp_nr].nil?
      stats[grp_nr] = {}
    end
    stats[grp_nr][p_id] = stats_p
  end

  def self.set_stats_with_no_matches(participants, stats)
    # must be done before computing ranks to place those ppants correctly
    participants.each do |p|
      grp_nr = p.ctype_params['grp_nr']
      unless stats[grp_nr]
        stats[grp_nr] = {}
      end
      unless stats[grp_nr][p.id]
        stats[grp_nr][p.id] = Result::empty_participant_stats
      end
      stats[grp_nr][p.id]['rankvalue'] =
          Result.get_rankvalue(stats[grp_nr][p.id])
    end
  end

  def self.update_rank(participants, stats)
    stats.each do |grp_nr, groupstats|
      stats_array = groupstats.to_a.sort { |a,b|
          b[1]['rankvalue'] <=> a[1]['rankvalue'] }
      rank = 0
      last_rankvalue = -1
      stats_array.each_with_index do |s, i|
        if s[1]['rankvalue'] != last_rankvalue
          rank = i + 1
          last_rankvalue = s[1]['rankvalue']
        end
        stats[grp_nr][s[0]]['rank'] = rank
      end
    end
  end

  def self.update_participants(participants, stats)
    participants.each do |p|
      p.stats = stats[p.ctype_params['grp_nr']][p.id]
      p.save!
    end
  end

end
