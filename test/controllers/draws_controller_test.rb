require 'test_helper'

class DrawsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
  end

  test "should create draw" do
    post api_v1_contest_draw_url(@contest),
          headers: @headers,
          params: { draw: { draw_tableau: [ [ participants(:DM1).id,
                                              participants(:DM2).id,
                                              participants(:DM3).id,
                                              participants(:DM4).id ] ] } },
          as: :json
    assert_response 201
    assert_equal 6, @contest.matches.size
  end

  test "should destroy draw" do
    post api_v1_contest_draw_url(@contest),
          headers: @headers,
          params: { draw: { draw_tableau: [ [ participants(:DM1).id,
                                              participants(:DM2).id,
                                              participants(:DM3).id,
                                              participants(:DM4).id ] ] } },
          as: :json
    assert_equal 6, @contest.matches.size

    delete api_v1_contest_draw_url(@contest), headers: @headers, as: :json
    assert_response 204
    assert_equal 0, @contest.matches.size
  end
end
