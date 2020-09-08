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
      # NOT update, which would cause a loop of callbacks!
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
end
