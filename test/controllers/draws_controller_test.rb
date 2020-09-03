require 'test_helper'

class DrawsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @params = { draw: { draw_tableau: [ [ participants(:DM1).id,
                                          participants(:DM2).id,
                                          participants(:DM3).id,
                                          participants(:DM4).id ] ] } }
    login_userOne
  end

  # TODO Sends no parameters here! Usually they should exist,
  #      but with GET, Rails recognises them only in the query string
  test "should show draw" do
    get api_v1_contest_draw_url(@contest), headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result
  end

  test "should create draw" do
    post api_v1_contest_draw_url(@contest), headers: @headers, as: :json,
          params: @params
    assert_response 201
    assert_equal 6, @contest.matches.size
  end

  test "should destroy draw" do
    post api_v1_contest_draw_url(@contest), headers: @headers, as: :json,
          params: @params
    assert_equal 6, @contest.matches.size

    delete api_v1_contest_draw_url(@contest), headers: @headers, as: :json
    assert_response 204
    assert_equal 0, @contest.matches.size
  end
end
