require 'test_helper'

class MatchesControllerUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
    draw_demomeisterschaft
    @match = @contest.matches.first
  end

  test "should get index of contests matches" do
    get api_v1_contest_matches_url, headers: @headers, as: :json
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

  test "should show match" do
    get api_v1_contest_match_url(@contest, @match), headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result['data'].size
  end

  test "should update match with result as object" do
    result = { 'score_p1' => [6,7], 'score_p2' => [2,5] }
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: {
          data: { type: 'matches',
                  id: @match.id,
                  attributes: { remarks: 'My remarks',
                                result: result,
                                winner_id: @match.participant_1_id } }
          },
          as: :json
    assert_response 200
    m = Match.find(@match.id)
    assert_equal("6:2 / 7:5", Result.to_s(m.result),
                  'Matchresult sent as object is not saved!')
  end

  test "should not update match with invalid values" do
    result = { 'score_p1' => [6,7], 'score_p2' => [2,5] }
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: {
            data: { type: 'matches',
                  id: @match.id,
                  attributes: {result: result,
                            winner_id: 111} }
          },
          as: :json
    assert_response :unprocessable_entity
  end

  # test "should destroy match" do
  #   assert_difference('Match.count', -1) do
  #     delete api_v1_contest_match_url(@match), as: :json
  #   end
  #   assert_response 204
  # end
end
