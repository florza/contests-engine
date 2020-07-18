class DrawManagerGroups < DrawManager

  validate :validate_groups

  def initialize(contest, params)
    @contest = contest
    @participants = @contest.participants.to_a
    @groups = params[:groups]
    @groups = JSON.parse(@groups) if @groups.class == String
  end

  def draw
    return if !valid?
    update_participants
    create_matches if valid?
  end

  def update_participants
    Participant.transaction do
      i = 0
      @groups.each_with_index do |members, group0|
        members.each_with_index do |participant_id, pos0|
          participant = @participants.find { |p| p.id == participant_id }
          grp_params = { grp_nr: group0 + 1, grp_pos: pos0 + 1 }
          if !participant.update({ group_params: grp_params })
            errors.add(:groups, 'participants update failed') and return
          end
          i += 1
        end
      end
    end
  end

  def create_matches
    @groups.each do |group|
      matches = Schedule.get_group_schedule(group, false)
      matches.each do |match|
        m = @contest.matches.new
        m.participant_1_id = match[:home]
        m.participant_2_id = match[:away]
        m.group_params = { round: match[:round] }
        m.updated_by_token = nil
        m.updated_by_user_id = @contest.user_id
        if !m.save
          errors.add(:groups, 'match creation failed') and return
        end
        p m
      end
    end
  end

  def validate_groups
    participant_ids = @groups.flatten
    if participant_ids.count != @participants.count
      errors.add(:groups, 'wrong number of participants in all groups')
    end
    if participant_ids.uniq.count != @participants.count
      errors.add(:groups, 'participant ids in sequence are not unique')
    end
    participant_ids.each do |participant_id|
      if !@participants.find { |p| p.id == participant_id }
        errors.add(:groups, "invalid id #{participant_id} in sequence")
      end
    end
    @groups.each do |group|
      if group.count < 2
        erros.add(:groups, 'groups should not be smaller than 2') and break
      end
    end
  end
end
