class ProcessManagerGroups < ProcessManager

  def self.process_result(match, contest)
    update_participants_stats(contest)
  end

  private

  ##
  # Method called from the parents update_participants_stats
  # to get the group nr of the match or participant
  def self.getGroupNr(record)
    return record.ctype_params['draw_group']
  end

  ##
  # Compute rank within groups, going from 1 to n, with possible duplicates
  # and corresponding jumps, e.g. 1, 2, 2, 4, 5

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

end
