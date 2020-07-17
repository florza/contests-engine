class DrawManagerGroups < DrawManager

  def initialize(contest, params)
    @errors = []
    @contest = contest
    @participants = @contest.participants.to_a
    @groups = params[:groups]
    @groups = JSON.parse(@groups) if @groups.class == String
  end

  def draw
    validate_group_params and (return if errors?)

    Participant.transaction do
      i = 0
      @groups.each_with_index do |members, group0|
        members.each_with_index do |participant_id, pos0|
          participant = @participants.find { |p| p.id == participant_id }
          grp_params = { grp_nr: group0 + 1, grp_pos: pos0 + 1 }
          if !participant.update({ group_params: grp_params })
            @errors.push 'participants update failed' and return
          end
          i += 1
        end
      end
    end
  end

  def validate_group_params
    participant_ids = @groups.flatten
    if participant_ids.count != @participants.count
      @errors.push 'wrong number of participants in all groups'
    end
    if participant_ids.uniq.count != @participants.count
      @errors.push 'participant ids in sequence are not unique'
    end
    participant_ids.each do |participant_id|
      if !@participants.find { |p| p.id == participant_id }
        @errors.push "invalid id #{participant_id} in sequence"
      end
    end
    @groups.each do |group|
      if group.count < 2
        @erros.push 'groups should not be smaller than 2' and break
      end
    end
  end
end
