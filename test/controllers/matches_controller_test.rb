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
    assert_equal 6, result.size
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
    assert_not_nil result.size
  end

  test "should update match with result as object" do
    result = { 'score_p1' => [6,7], 'score_p2' => [2,5] }
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: { match: {remarks: 'My remarks',
                            result: result,
                            winner_id: @match.participant_1_id} },
          as: :json
    assert_response 200
    m = Match.find(@match.id)
    assert_equal("6:2 / 7:5", Result.to_s(m.result),
                  'Matchresult sent as object is not saved!')
  end

  # FIXME
  # Does NOT work if the score numbers are sent as string, e.g. ["6","7"]
  # as it is done from Postman!
  # A correction of the validation would also need a conversion
  # of the values to work.
  test "should update match with result as JSON(!)-string" do
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: { match: {remarks: 'My remarks',
                            result: '{"score_p1": [6,7],
                                      "score_p2": [2,5]}',
                            winner_id: @match.participant_1_id} },
          as: :json
    assert_response 200
    m = Match.find(@match.id)
    assert_equal("6:2 / 7:5", Result.to_s(m.result))
  end

  # test "should destroy match" do
  #   assert_difference('Match.count', -1) do
  #     delete api_v1_contest_match_url(@match), as: :json
  #   end
  #   assert_response 204
  # end
end
