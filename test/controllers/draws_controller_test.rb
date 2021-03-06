require 'test_helper'

class DrawsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @params = {
          data: { type: 'draw',
                  attributes: { draw_tableau: [
                                  [ participants(:DM1).id,
                                    participants(:DM2).id,
                                    participants(:DM3).id,
                                    participants(:DM4).id ]
                                ] } }
    }
    login_userOne
  end

  # With GET, Rails recognises params only in the query string
  test "should show draw" do
    url_with_params = api_v1_contest_draw_url(@contest) +
      '?data[type]=draw&data[id]=' + @contest.id.to_s +
      '&data[attributes][draw_tableau]=[[],[]]'
    get url_with_params, headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result
    assert_equal 2, result['data']['attributes']['draw_structure'].size
  end

  # With GET, Rails recognises params only in the query string
  test "should not show draw with invalid params" do
    url_with_params = api_v1_contest_draw_url(@contest) +
      '?data[type]=draw&data[id]=' + @contest.id.to_s +
      '&data[attributes][draw_tableau]=[[],[],[]]'
    get url_with_params, headers: @headers, as: :json
    assert_response :unprocessable_entity
  end

  test "should create draw" do
    post api_v1_contest_draw_url(@contest), headers: @headers, as: :json,
          params: @params
    assert_response 201
    assert_equal 6, @contest.matches.size
  end

  test "should not create draw with invalid params" do
    post api_v1_contest_draw_url(@contest), headers: @headers, as: :json,
          params: {
            data: { type: 'draw',
                    attributes: { draw_tableau: [ [], [], [] ] } }
          }
    assert_response :unprocessable_entity
  end

  test "should destroy draw" do
    post api_v1_contest_draw_url(@contest), headers: @headers, as: :json,
          params: @params
    assert_equal 6, @contest.matches.size

    delete api_v1_contest_draw_url(@contest), headers: @headers, as: :json
    assert_response 200
    assert_equal 0, @contest.matches.size
  end
end
