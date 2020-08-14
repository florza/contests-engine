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

  test "result array must not be empty" do
    @match.result['score'] = []
    assert_not @match.valid?
  end

  test "result array must not contain too many elements" do
    @match.result['score'] = [ [1,2], [3,4], [5,6], [7,8] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result can contain more elements than winning_sets" do
    @match.result['score'] = [[1,2],[3,4],[5,6]]
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  test "result must only contain arrays" do
    @match.result['score'] = [ [1,2], 3, 4 ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result subarray must contain 2 elements" do
    @match.result['score'] = [ [1,2], [3, 4, 5 ] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
    @match.result['score'] = [ [1,2], [3] ]
    assert_not @match.valid?
  end

  test "result subarray must contain numbers in 1st field" do
    @match.result['score'] = [ [1, 2], ['3'] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end


  test "result subarray must contain numbers in 2nd field" do
    @match.result['score'] = [ [1, 2], [3], {}]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result subarray must not contain negativ numbers in 1st field" do
    @match.result['score'] = [ [1, 2], [-3,4] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result subarray must not contain negativ numbers in 2nd field" do
    @match.result['score'] = [ [1, -2], [3,4] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "winner has been entered correctly" do
    @match.result['score'] = [ [1, 2], [4,3], [5,6] ]
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  test "winner has not been entered correctly" do
    @match.result['score'] = [ [1, 2], [4,3], [5,6] ]
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
    @match.result = { 'score' => nil }
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "empty score cannot have a winner" do
    @match.result = { 'score' => [] }
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "tie result invalid if not allowed" do
    @match.result['score'] = [ [1, 2], [4,3] ]
    assert_not @match.valid?
  end

  test "tie result valid if allowed" do
    setTieAllowed
    @match.result['score'] = [ [1, 2], [4,3] ]
    assert @match.valid?
  end

  test "tie result must not have a winner" do
    setTieAllowed
    @match.result['score'] = [ [1, 2], [4,3] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "tie result invalid if no tie" do
    setTieAllowed
    @match.result['score'] = [ [1, 2], [4,3], [6, 5] ]
    assert_not @match.valid?
  end

  test "the winner can win less sets in a walk over" do
    @match.result['score'] = [ [6, 2] ]
    @match.winner_id = @match.participant_2_id
    @match.result['walk_over'] = true
    assert @match.valid?
  end

  test "score must not be empty in a walk over" do
    @match.result['score'] = []
    @match.result['walk_over'] = true
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "score may be 0:0 in a walk over" do
    @match.result['score'] = [ [0, 0] ]
    @match.result['walk_over'] = true
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  def setTieAllowed
    contest = @match.contest
    contest.result_params['tie_allowed'] = true
    contest.save!
  end
end
