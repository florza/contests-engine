require 'test_helper'

class ContestsControllerTokenTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
  end

  test "should get index of contest with token" do
    login_readToken
    get api_v1_contests_url, as: :json
    result = JSON.parse(@response.body)
    assert_equal 1, result.size
  end

  test "should show token contest with token" do
    login_readToken
    get api_v1_contest_url(@contest), as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result.size
  end

  test "should not create new contest with token" do
    login_writeToken
    post api_v1_contests_url,
        params: { contest: {name: 'New test context',
                            shortname: 'New test',
                            description: 'Description',
                            ctype: 'Groups',
                            public: false} },
        as: :json
    assert_response 401
  end

  test "should not update contest with token" do
    login_writeToken
    put api_v1_contest_url(@contest),
        params: { contest: {name: @contest.name,
                            shortname: @contest.shortname,
                            description: @contest.description,
                            ctype: @contest.ctype,
                            public: @contest.public} },
        as: :json
    assert_response 401
  end

  test "should not destroy contest with token" do
    login_writeToken
    delete api_v1_contest_url(@contest), as: :json
    assert_response 401
  end
end
