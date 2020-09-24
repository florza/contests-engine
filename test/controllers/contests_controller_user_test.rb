require 'test_helper'

class ContestsControllerUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
  end

  test "should get index of users contests" do
    get api_v1_contests_url, headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 3, result['data'].size
  end

  test "should create contest" do
    assert_difference('User.find(users(:userOne).id).contests.count') do
      post api_v1_contests_url,
          headers: @headers,
          params: {
            data: { type: 'contests',
                    attributes: { name: 'New test contest',
                                  shortname: 'New test',
                                  description: 'Description',
                                  ctype: 'Groups' } }
          },
          as: :json
    end
    assert_response 201
  end

  test "should not create invalid contest" do
    post api_v1_contests_url,
          headers: @headers,
          params: {
            data: { type: 'contests',
                    id: @contest.id,
                    attributes: { name: 'New test contest',
                                  shortname: '',
                                  description: 'Description',
                                  ctype: 'Groups' } }
          },
          as: :json
    assert_response :unprocessable_entity
  end

  test "should show contest" do
    get api_v1_contest_url(@contest.id), headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result['data']
  end

  test "should update contest" do
    put api_v1_contest_url(@contest),
        headers: @headers,
        params: {
          data: { type: 'contests',
                  id: @contest.id,
                  attributes: { name: @contest.name,
                                shortname: @contest.shortname,
                                description: @contest.description,
                                ctype: @contest.ctype } }
        },
        as: :json
    assert_response 200
  end

  test "should not update contest with invalid values" do
    put api_v1_contest_url(@contest),
        headers: @headers,
        params: {
          data: { type: 'contests',
                  id: @contest.id,
                  attributes: { name: @contest.name,
                                shortname: '',
                                description: @contest.description,
                                ctype: @contest.ctype } }
        },
        as: :json
    assert_response :unprocessable_entity
  end

  test "should destroy contest" do
    assert_difference('Contest.count', -1) do
      delete api_v1_contest_url(@contest), headers: @headers, as: :json
    end
    assert_response 200
  end
end
