class ProcessManagerGroups < ProcessManager

  LOSS = 0
  TIE = 1
  WIN = 2

  def initialize(match, contest)
    @match = match
    @contest = contest
    pts = contest.contesttype_params['points']
    if pts.nil?
      @points_earned = [0, 1, 3]
    else
      @points_earned = [pts['loss'], pts['tie'], pts['win']]
    end
    @participants = {}
    @matches = contest.matches
  end

  def process_result
    @matches.each do |m|
      sum_points(m)
    end
    debugger
    @contest.participants.each do |p|
      ctp = p.contesttype_params || {}
      ctp['grp_points'] = @participants[p.id] || [0]
      p.update(contesttype_params: ctp)
    end
  end

  def sum_points(m)
    if m.winner_id == m.participant_1_id
      add_points(m.participant_1_id, m, WIN)
      add_points(m.participant_2_id, m, LOSS)
    elsif m.winner_id == m.participant_2_id
      add_points(m.participant_1_id, m, LOSS)
      add_points(m.participant_2_id, m, WIN)
    else
      add_points(m.participant_1_id, m, TIE)
      add_points(m.participant_2_id, m, TIE)
    end
  end

  def add_points(participant_id, m, outcome)
    if @participants[participant_id].nil?
      sums = [0] # basic idea: additional sums for sets won, sets lost, ...
    else
      sums = @participants[participant_id]
    end
    sums[0] += @points_earned[outcome]
    @participants[participant_id] = sums
  end

end
