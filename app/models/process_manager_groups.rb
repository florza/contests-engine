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

end
