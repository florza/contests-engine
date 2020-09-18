require 'test_helper'

class ResultTest < ActiveSupport::TestCase

  def setup
    @match = Match.new(
      contest: contests(:DemoMeisterschaft),
      participant_1: participants(:DM1),
      participant_2: participants(:DM2),
      remarks: '',
      result: {}
    )
  end

  test "empty or nil result in sample match is valid" do
    assert @match.valid?
    @match.result = nil
    assert @match.valid?
  end

  test "result must be an array" do
    @match.result = 'i am a string'
    assert_not @match.valid?
  end

  test "result array may be empty" do
    @match.result['score_p1'] = []
    @match.result['score_p1'] = []
    assert @match.valid?
  end

  test "result array must not contain too many elements" do
    @match.result['score_p1'] = [1,3,5,7]
    @match.result['score_p2'] = [2,4,6,8]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result can contain more elements than winning_sets" do
    @match.result['score_p1'] = [1,3,5]
    @match.result['score_p2'] = [2,4,6]
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  test "scores must be arrays" do
    @match.result['score_p1'] = 1
    @match.result['score_p2'] = 2
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "scores must have equal length" do
    @match.result['score_p1'] = [1,2]
    @match.result['score_p2'] = [2,4,6]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result subarray must contain numbers" do
    @match.result['score_p1'] = [1,2,'3']
    @match.result['score_p2'] = [1,2,{}]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end


  test "scores must not contain negativ numbers" do
    @match.result['score_p1'] = [1,-2]
    @match.result['score_p2'] = [-1,2]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "winner has been entered correctly" do
    @match.result['score_p1'] = [1,4,5]
    @match.result['score_p2'] = [2,3,6]
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  test "winner has not been entered correctly" do
    @match.result['score_p1'] = [1,4,5]
    @match.result['score_p2'] = [2,3,6]
    @match.winner_id = @match.participant_1_id
    assert_not @match.valid?
  end

  test "missing result cannot have a winner" do
    @match.result = nil
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "empty result cannot have a winner" do
    @match.result = {}
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "missing score cannot have a winner" do
    @match.result = { 'score_p1' => nil }
    @match.result = { 'score_p2' => [6] }
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "empty score cannot have a winner" do
    @match.result = { 'score_p1' => [] }
    @match.result = { 'score_p2' => [] }
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "tie result invalid if not allowed" do
    @match.result['score_p1'] = [1,4]
    @match.result['score_p2'] = [2,3]
    @match.winner_id = 0
    assert_not @match.valid?
  end

  test "tie result valid if allowed" do
    setTieAllowed
    @match.result['score_p1'] = [1,4]
    @match.result['score_p2'] = [2,3]
    @match.winner_id = 0
    assert @match.valid?
  end

  test "winner_id in tie must not be null but 0" do
    setTieAllowed
    @match.result['score_p1'] = [1,4]
    @match.result['score_p2'] = [2,3]
    assert_not @match.valid?
  end

  test "tie result must not have a winner" do
    setTieAllowed
    @match.result['score_p1'] = [1,4]
    @match.result['score_p2'] = [2,3]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "tie result invalid if no tie" do
    setTieAllowed
    @match.result['score_p1'] = [1,4,6]
    @match.result['score_p2'] = [2,3,5]
    assert_not @match.valid?
  end

  test "the winner can win less sets in a walk over" do
    @match.result['score_p1'] = [6]
    @match.result['score_p2'] = [2]
    @match.winner_id = @match.participant_2_id
    @match.result['walk_over'] = true
    assert @match.valid?
  end

  test "winner must not be empty in a walk over" do
    @match.result['score_p1'] = [2]
    @match.result['score_p2'] = [3]
    @match.result['walk_over'] = true
    assert_not @match.valid?
  end

  test "score must not be empty in a walk over" do
    @match.result['score_p1'] = []
    @match.result['score_p2'] = []
    @match.result['walk_over'] = true
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "score may be 0:0 in a walk over" do
    @match.result['score_p1'] = [0]
    @match.result['score_p2'] = [0]
    @match.result['walk_over'] = true
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  test "result as string contains w.o." do
    @match.result['score_p1'] = [2]
    @match.result['score_p2'] = [3]
    @match.winner_id = @match.participant_2_id
    @match.result['walk_over'] = true
    assert @match.valid?
    @match.save!
    assert @match.result_1_vs_2 == '2:3 (w.o.)'
    assert @match.result_2_vs_1 == '3:2 (w.o.)'
  end

  def setTieAllowed
    contest = @match.contest
    contest.result_params['tie_allowed'] = true
    contest.save!
  end
end
