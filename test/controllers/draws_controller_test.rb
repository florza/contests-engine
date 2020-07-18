require 'test_helper'

class DrawsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
  end

  test "should create draw" do
    post api_v1_contest_draw_url(@contest),
          headers: @headers,
          params: { draw: { groups: [ [ participants(:stanDemo).id,
                                        participants(:rogerDemo).id ] ] } },
          as: :json
    assert_response 201
    assert_equal 1, @contest.matches.count
  end
end
