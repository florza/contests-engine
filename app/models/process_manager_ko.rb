class ProcessManagerKO < ProcessManager

  def self.process_result(match, contest)
    update_participants_stats(contest)
    if match.winner_id
      process_winner(match, contest)
      process_looser(match, contest)
    end
  end

  private

  def self.process_winner(match, contest)
    this_match = Match.find(match.id) # with ALL attributes
    if this_match.winner_next_match_id
      next_match = Match.find(this_match.winner_next_match_id)
      col = if this_match.winner_next_place_1
              :participant_1_id
            else
              :participant_2_id
            end
      # NOT update!(), which would cause a loop of callbacks!
      next_match.update_column(col, this_match.winner_id)
    end
  end

  def self.process_looser(match, contest)
    # no action yet
  end

  ##
  # Method called from the parents update_participants_stats
  # Since KO has no groups, 1 is returned
  def self.getGroupNr(match)
    return 1
  end

  ##
  # Sum match stats for each participant
  # Extend parent class method with additional logic to
  # save the range of possible rank values of the participant,
  # for example:
  #
  # 1..4 for the winner of a quarter-final
  # 5..5 for the looser of a quarter-final
  #
  # The range is directly stored as stats['rank'],
  # so it must not be recomputed or renamed in the next function

  def self.sum_stats_participant(part_1_2, match, stats)
    super
    p_id = part_1_2 == 1 ? match.participant_1_id : match.participant_2_id
    rank_range = stats[getGroupNr(match)][p_id]['rank']
    rank_range = 1..9999 if !rank_range.is_a?(Range)
    match_round = match.ctype_params['draw_round']
    if match.winner_id == p_id
      if rank_range.end > match_round
        rank_range = rank_range.begin..match_round
      end
    elsif match.winner_id > 0
      rank_range = (match_round + 1)..(match_round + 1)
    end
    stats[getGroupNr(match)][p_id]['rank'] = rank_range
  end

  ##
  # Overwrite parent method to correct the previously computed rank
  # (number of participants as end of range instead of 9999)
  # or to set not yet computed ranks to 1..nbr_participants

  def self.update_rank(participants, stats)
    nbr_participants = participants.size
    stats.each do |grp, participant|
      participant.each do |p_id, stat|
        if stat['rank'].nil? || !stat['rank'].is_a?(Range)
          stat['rank'] = 1..nbr_participants
        elsif stat['rank'].begin == stat['rank'].end
          stat['rank'] = stat['rank'].begin
        elsif stat['rank'].end == 9999
          stat['rank'] = stat['rank'].begin..nbr_participants
        end
      end
    end
  end

end
