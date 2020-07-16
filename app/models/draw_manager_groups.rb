class DrawManagerGroups

  def initialize(contest, params)
    @errors = []
    @contest = contest
    @participants = @contest.participants
    @groups = params[:groups]
    @sequence = params[:sequence]
  end

  def draw
    validate_params and (return if errors?)
    p 'draw can be continued...'
  end

  def validate_params
    if @participants.count != @sequence.count
      @errors.push 'different number of participants'
    end
    if @participants.count != @groups.sum
      @errors.push 'wrong sum of group sizes'
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

  def errors
    @errors
  end

  def errors?
    !errors.empty?
  end
end
