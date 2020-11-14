require 'test_helper'

class MatchTest < ActiveSupport::TestCase

  def setup
    @match = Match.new(
      contest: contests(:DemoMeisterschaft),
      remarks: ''
    )
  end

  test "sample match is valid" do
    assert @match.valid?
  end

  test "required attributes must be set" do
    [:contest_id].each do |attr|
      match2 = @match.dup
      match2[attr] = nil
      assert_not match2.valid?, "Empty #{attr.to_s} must be invalid"
    end
  end

  test "match with succeeding match result is invalid" do

    # Set draw and enter result for first match
    draw_mgr = draw_ko
    first_match = @contest.matches.
      where(participant_1_id: participants(:DKO2).id).
      where(participant_2_id: participants(:DKO3).id).
      first
    first_match.result = { 'score_p1' => [3], 'score_p2' => [6] }
    first_match.winner_id = first_match.participant_2_id
    assert first_match.save
    assert first_match.valid?

    # Change result for first match must be ok
    first_match.result['score_p1'] = [3]
    assert first_match.valid?

    # Enter result for second match must be ok
    second_match = @contest.matches.find(first_match.winner_next_match_id)
    second_match.result = { 'score_p1' => [6], 'score_p2' => [2] }
    second_match.winner_id = second_match.participant_1_id
    assert second_match.save

    # Change result for first match must not be ok any more!
    first_match = @contest.matches.find(first_match.id)
    first_match.result['score_p1'] = [2]
    assert_not first_match.valid?
    assert_includes first_match.errors.messages[:result],
      'must not be changed if a draw exists'
  end
end
