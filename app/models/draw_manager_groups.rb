class DrawManagerGroups < DrawManager

  validate :validate_groups

  def initialize(contest, params)
    super
    @grp_groups = params[:grp_groups]
    @grp_groups = JSON.parse(@grp_groups) if @grp_groups.class == String
  end

  def update_contest
    update_contest_draw_info( 'grp_groups' => @grp_groups )
  end

  def update_participants
    update_participants_draw_info(@grp_groups)
  end

  def get_participant_params(group, pos)
    return { 'grp_nr' => group, 'grp_pos' => pos }
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
      if !@participants.find(participant_id)
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
