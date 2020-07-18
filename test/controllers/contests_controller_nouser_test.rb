# Tests of contest controller with no user logged in (no header sent)
# All requests shoud be refused

require 'test_helper'

class ContestsControllerNoUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
  end

  test "should not get index of users contests" do
    get api_v1_contests_url, as: :json
    assert_response 401
  end

  test "should not create contest" do
    post api_v1_contests_url,
        params: { contest: {name: 'New test context',
                            shortname: 'New test',
                            description: 'Description',
                            contesttype: 'Groups',
                            nbr_sets: 1,
                            public: false} },
        as: :json
    assert_response 401
  end

  test "should not show contest" do
    get api_v1_contest_url(@contest.id), as: :json
    assert_response 401
  end

  test "should not update contest" do
    put api_v1_contest_url(@contest),
        params: { contest: {name: @contest.name,
                            shortname: @contest.shortname,
                            description: @contest.description,
                            contesttype: @contest.contesttype,
                            nbr_sets: @contest.nbr_sets,
                            public: @contest.public} },
        as: :json
    assert_response 401
  end

  test "should not destroy contest" do
    delete api_v1_contest_url(@contest), as: :json
    assert_response 401
  end
end