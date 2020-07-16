require 'test_helper'

class ContestsControllerTokenTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
  end

  test "should get index of contest with token" do
    get api_v1_contests_url,
        params: { t: @contest.token_read },
        as: :json
    result = JSON.parse(@response.body)
    assert_equal 1, result.count
  end

  test "should not create new contest with token" do
    post api_v1_contests_url,
        params: { t: @contest.token_write,
                  contest: {name: 'New test context',
                            shortname: 'New test',
                            description: 'Description',
                            contesttype: 'Groups',
                            nbr_sets: 1,
                            public: false} },
        as: :json
    assert_response 401
  end

  # In the test environment, this test currently aborts with
  #   No route matches [POST] "/api/v1/contests/849877958"
  # The reason is unknown, the same link sent from Postman
  # in development works!
  test "should show token contest" do
    get api_v1_contest_url(@contest),
        params: { t: @contest.token_read },
        as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result.count
  end

  test "should not update contest with token" do
    put api_v1_contest_url(@contest),
        params: { t: @contest.token_write,
                  contest: {name: @contest.name,
                            shortname: @contest.shortname,
                            description: @contest.description,
                            contesttype: @contest.contesttype,
                            nbr_sets: @contest.nbr_sets,
                            public: @contest.public} },
        as: :json
    assert_response 401
  end

  test "should not destroy contest with token" do
    delete api_v1_contest_url(@contest),
        params: { t: @contest.token_write },
        as: :json
    assert_response 401
  end
end
