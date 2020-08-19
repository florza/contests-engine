class DrawManagerGroups < DrawManager

  validate :validate_groups

  def initialize(contest, params)
    @contest = contest
    @participants = @contest.participants.to_a
    @grp_groups = params[:grp_groups]
    @grp_groups = JSON.parse(@grp_groups) if @grp_groups.class == String
  end

  def draw
    update_contest if valid?
    update_participants if valid?
    create_matches if valid?
  end

  def update_contest
    newParams = @contest.ctype_params || {}
    newParams['grp_groups'] = @grp_groups
    if !@contest.update(
      { ctype_params: newParams,
        draw_at: DateTime.now,
        last_action_at: DateTime.now }
    )
      errors.add(:grp_groups, 'contest update failed')
    end
  end

  def update_participants
    Participant.transaction do
      @grp_groups.each_with_index do |members, group0|
        members.each_with_index do |participant_id, pos0|
          participant = @participants.find { |p| p.id == participant_id }
          #ctype_params = { 'grp_nr' => group0 + 1, 'grp_pos' => pos0 + 1 }
          participant.ctype_params =
            { 'grp_nr' => group0 + 1, 'grp_pos' => pos0 + 1 }
          if !participant.save
            errors.add(:groups, 'participants update failed')
            return
          end
        end
      end
    end
  end

  def create_matches
    @contest.matches.destroy_all
    @grp_groups.each_with_index do |members, group0|
      matches = Schedule.get_group_schedule(members, false)
      matches.each do |match|
        m = @contest.matches.new(
          participant_1_id: match[:home],
          participant_2_id: match[:away],
          ctype_params: { grp_nr: group0 + 1, grp_round: match[:round] },
          updated_by_token: nil,
          updated_by_user_id: @contest.user_id
        )
        if !m.save
          errors.add(:groups, 'match creation failed') and return
        end
      end
    end
  end

  def validate_groups
    participant_ids = @grp_groups.flatten
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
    @grp_groups.each do |group|
      if group.count < 2
        erros.add(:groups, 'groups should not be smaller than 2') and break
      end
    end
  end
end
