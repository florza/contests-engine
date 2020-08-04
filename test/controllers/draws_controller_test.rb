require 'test_helper'

class DrawsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
  end

  test "should create draw" do
    post api_v1_contest_draw_url(@contest),
          headers: @headers,
          params: { draw: { groups: [ [ participants(:DM1).id,
                                        participants(:DM2).id,
                                        participants(:DM3).id,
                                        participants(:DM4).id ] ] } },
          as: :json
    assert_response 201
    assert_equal 6, @contest.matches.count
  end
end
