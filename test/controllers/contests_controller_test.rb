require 'test_helper'

class ContestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    login_userOne
  end

  test "should get index" do
    get api_v1_contests_url, as: :json
    assert_response :success
  end

  test "should create contest" do
    assert_difference('Contest.count') do
      post api_v1_contests_url,
          params: { contest: {name: @contest.name + ' 2',
                              shortname: @contest.shortname + ' 2',
                              description: '',
                              contesttype: 'Group',
                              nbr_sets: 1,
                              public: false} },
          as: :json
    end
    assert_response 201
  end

  test "should show contest" do
    get api_v1_contest_url(@contest), as: :json
    assert_response :success
  end

  test "should update contest" do
    put api_v1_contest_url(@contest),
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
      delete api_v1_contest_url(@contest), as: :json
    end

    assert_response 204
  end
end
