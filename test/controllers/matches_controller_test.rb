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
    assert_equal 6, result.count
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
    assert_not_nil result.count
  end

  # FIXME Find out if sending of array is possible, make it work or delete test
  test "should update match" do
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: { match: {remarks: 'My remarks',
                            result: [[6,2],[7,5]],
                            winner_id: @match.participant_1_id} },
          as: :json
    assert_response 200
    m = Match.find(@match.id)
    assert_equal("6:2 / 7:5", Result.to_s(m.result),
                  'Matchresult sent as array is not saved!')
  end

  test "should update match with result as string" do
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: { match: {remarks: 'My remarks',
                            result: "[[6,2],[7,5]]",
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
