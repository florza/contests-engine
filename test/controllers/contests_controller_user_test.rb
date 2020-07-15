require 'test_helper'

class ContestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
  end

  test "should get index of users contests" do
    get api_v1_contests_url, headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 2, result.count
  end

  test "should create contest" do
    assert_difference('Contest.count') do
      post api_v1_contests_url,
          headers: @headers,
          params: { contest: {name: 'New test context',
                              shortname: 'New test',
                              description: 'Description',
                              contesttype: 'Groups',
                              nbr_sets: 1,
                              public: false} },
          as: :json
    end
    assert_response 201
  end

  test "should show contest" do
    get api_v1_contest_url(@contest.id), headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result.count
  end

  test "should update contest" do
    put api_v1_contest_url(@contest),
        headers: @headers,
        params: { contest: {name: @contest.name,
                            shortname: @contest.shortname,
                            description: @contest.description,
                            contesttype: @contest.contesttype,
                            nbr_sets: @contest.nbr_sets,
                            public: @contest.public} },
        as: :json
    assert_response 200
  end

  test "should destroy contest" do
    assert_difference('Contest.count', -1) do
      delete api_v1_contest_url(@contest), headers: @headers, as: :json
    end

    assert_response 204
  end
end
