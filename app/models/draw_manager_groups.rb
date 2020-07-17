class DrawManagerGroups < DrawManager

  def initialize(contest, params)
    @errors = []
    @contest = contest
    @participants = @contest.participants.to_a
    @groups = params[:groups]
    @groups = JSON.parse(@groups) if @groups.class == String
    @sequence = params[:sequence]
    @sequence = JSON.parse(@sequence) if @sequence.class == String
  end

  def draw
    validate_group_params and (return if errors?)

    Participant.transaction do
      i = 0
      @groups.each_with_index do |size, group|
        1.upto(size) do |pos|
          participant = @participants.find { |p| p.id == @sequence[i] }
          grp_params = { grp_nr: group + 1, grp_pos: pos }
          if !participant.update({ group_params: grp_params })
            @errors.push 'participants update failed' and return
          end
          i += 1
        end
      end
    end
  end

  def validate_group_params
    if @participants.count != @sequence.count
      @errors.push 'wrong number of participants in sequence'
    end
    if @participants.count != @groups.sum
      @errors.push 'wrong sum of group sizes in groups'
    end
    if @groups.min < 2
      @erros.push 'groups should not be smaller than 2'
    end
    if @sequence.uniq.count != @sequence.count
      @errors.push 'participant ids in sequence are not unique'
    end
    @sequence.each do |pid|
      if !@participants.find(pid)
        @errors.push "invalid id #{pid} in sequence"
      end
    end
  end
end
