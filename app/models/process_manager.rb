class ProcessManager

  ##
  # After editing a match result, compute the participants stats and rankings
  # The major part of the logic is valid for Groups and KO, but some small
  # differences are handled by the method getGroupNr, which is defined
  # in the subclasses

  def self.update_participants_stats(contest)
    stats = {}
    contest.reload
    sum_match_stats(contest.matches, stats)
    set_stats_with_no_matches(contest.participants, stats)
    update_rank(contest.participants, stats)
    update_participants(contest.participants, stats)
  end

  def self.sum_match_stats(matches, stats)
    matches.each do |match|
      unless match.winner_id.nil?
        sum_stats_participant(1, match, stats)
        sum_stats_participant(2, match, stats)
      end
    end
  end

  def self.sum_stats_participant(part_1_2, match, stats)
    if match.stats.blank?
      puts 'Match found without stats:', match
    end
    grp_nr = getGroupNr(match)
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
    if stats_p.blank?
      stats_p = Result.empty_participant_stats
    end
    stats_p['points'] += stats_m['points'][0] || 0
    ['matches', 'sets', 'games'].each do |category|
      stats_p[category] =
          stats_p[category].zip(stats_m[category]).map {|a| a.sum}
    end
    if stats[grp_nr].nil?
      stats[grp_nr] = {}
    end
    stats[grp_nr][p_id] = stats_p
  end

  ##
  # Complete the computed stats with entries for participants
  # who have not yet played any match. This must be done especially in
  # Groups before computing ranks, to place those participants correctly
  # after participants having won the majority of their matches,
  # but before participants who have more lost matches than wins.
  #
  # The rankvalue is also computed in KO, to eventually provide a means
  # to compute a more detailled rank than just "4 participants on rank 5,
  # 8 participants on rank 9 and so on".

  def self.set_stats_with_no_matches(participants, stats)
    participants.each do |p|
      grp_nr = getGroupNr(p)
      unless stats[grp_nr]
        stats[grp_nr] = {}
      end
      unless stats[grp_nr][p.id]
        stats[grp_nr][p.id] = Result.empty_participant_stats
      end
      stats[grp_nr][p.id]['rankvalue'] =
          Result.get_rankvalue(stats[grp_nr][p.id])
    end
  end

  ##
  # self.update_rank(participants, stats)
  # must be defined in every subclass

  def self.update_participants(participants, stats)
    participants.each do |p|
      p.stats = stats[getGroupNr(p)][p.id]
      p.save!
    end
  end
end
