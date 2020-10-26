require 'test_helper'

class MatchesControllerTokenTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
    draw_demomeisterschaft
    logout
    @match = @contest.matches.first
  end

  test "should get index of contest matches with token" do
    login_readToken
    get api_v1_contest_matches_url(@contest), headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 6, result['data'].size
  end

  # test "should create match" do
  #   assert_difference('Match.count') do
  #     post api_v1_contest_matches_url, params: { match: {  } }, as: :json
  #   end
  #   assert_response 201
  # end

  test "should show match with token" do
    login_readToken
    get api_v1_contest_match_url(@contest, @match), headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result['data'].size
  end

  test "should not update match with read token" do
    logout
    login_readToken
    result = { 'score_p1' => [6,7], 'score_p2' => [2,5] }
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: {
            data: { type: 'matches',
                    id: @match.id,
                    attributes: { result: result,
                                  winner_id: @match.participant_1_id} }
          },
          as: :json
    assert_response :unauthorized
  end

  test "should update match with contest write token" do
    login_writeToken
    result = { 'score_p1' => [6,7], 'score_p2' => [2,5] }
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: {
            data: { type: 'matches',
                    id: @match.id,
                    attributes: { result: result,
                                  winner_id: @match.participant_1_id} }
          },
          as: :json
    assert_response :success
  end

  test "should update match with participant token" do
    login_participantToken
    result = { 'score_p1' => [6,7], 'score_p2' => [2,5] }
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: {
            data: { type: 'matches',
                    id: @match.id,
                    attributes: { result: result,
                                  winner_id: @match.participant_1_id} }
          },
          as: :json
    assert_response :success
  end

  # test "should destroy match" do
  #   assert_difference('Match.count', -1) do
  #     delete api_v1_contest_match_url(@match), as: :json
  #   end
  #   assert_response 204
  # end
end
