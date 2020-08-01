require 'test_helper'

class ResultTest < ActiveSupport::TestCase

  def setup
    @match = Match.new(
      contest: contests(:DemoMeisterschaft),
      participant_1: participants(:stanDemo),
      participant_2: participants(:rogerDemo),
      remarks: ''
    )
  end

  test "empty result in sample match is valid" do
    assert @match.valid?
  end

  test "result must be an array" do
    @match.result = 'i am a string'
    assert_not @match.valid?
  end

  test "result array must not be empty" do
    @match.result = []
    assert_not @match.valid?
  end

  test "result array must not contain too many elements" do
    @match.result = [ [1,2], [3,4], [5,6], [7,8] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result can contain more elements than nbr_sets" do
    @match.result = [[1,2],[3,4],[5,6]]
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  test "result must only contain arrays" do
    @match.result = [ [1,2], 3, 4 ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result subarray must contain 2 elements" do
    @match.result = [ [1,2], [3, 4, 5 ] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
    @match.result = [ [1,2], [3] ]
    assert_not @match.valid?
  end

  test "result subarray must contain numbers in 1st field" do
    @match.result = [ [1, 2], ['3'] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end


  test "result subarray must contain numbers in 2nd field" do
    @match.result = [ [1, 2], [3], {}]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result subarray must not contain negativ numbers in 1st field" do
    @match.result = [ [1, 2], [-3,4] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "result subarray must not contain negativ numbers in 2nd field" do
    @match.result = [ [1, -2], [3,4] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end

  test "winner has been entered correctly" do
    @match.result = [ [1, 2], [4,3], [5,6] ]
    @match.winner_id = @match.participant_2_id
    assert @match.valid?
  end

  test "winner has not been entered correctly" do
    @match.result = [ [1, 2], [4,3], [5,6] ]
    @match.winner_id = @match.participant_1_id
    assert_not @match.valid?
  end

  test "no winner has been entered on a remis" do
    @match.result = [ [1, 2], [4,3] ]
    assert @match.valid?
  end

  test "winner has been entered but there is none" do
    @match.result = [ [1, 2], [4,3] ]
    @match.winner_id = @match.participant_2_id
    assert_not @match.valid?
  end
end
