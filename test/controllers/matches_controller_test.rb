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
    assert_equal 1, result.count
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

  test "should update match" do
    patch api_v1_contest_match_url(@contest, @match),
          headers: @headers,
          params: { match: {remarks: 'My remarks',
                            result: [ [6,2] [7,5] ]} },
          as: :json
    assert_response 200
  end

  # test "should destroy match" do
  #   assert_difference('Match.count', -1) do
  #     delete api_v1_contest_match_url(@match), as: :json
  #   end
  #   assert_response 204
  # end
end
