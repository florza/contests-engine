require 'test_helper'

class MatchesControllerNoUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
    draw_demomeisterschaft
    logout
    @match = @contest.matches.first
  end

  test "should not get index of matches without user" do
    get api_v1_contest_matches_url(@contest), as: :json
    assert_response :unauthorized
  end

  # test "should create match" do
  #   assert_difference('Match.count') do
  #     post api_v1_contest_matches_url, params: { match: {  } }, as: :json
  #   end
  #   assert_response 201
  # end

  test "should not show match without user" do
    get api_v1_contest_match_url(@contest, @match), as: :json
    assert_response :unauthorized
  end

  test "should not update match without user" do
    result = { 'score_p1' => [6,7], 'score_p2' => [2,5] }
    patch api_v1_contest_match_url(@contest, @match),
          params: {
            data: { type: 'matches',
                    id: @match.id,
                    attributes: { result: result,
                                  winner_id: @match.participant_1_id} }
          },
          as: :json
    assert_response :unauthorized
  end

  # test "should destroy match" do
  #   assert_difference('Match.count', -1) do
  #     delete api_v1_contest_match_url(@match), as: :json
  #   end
  #   assert_response 204
  # end
end
