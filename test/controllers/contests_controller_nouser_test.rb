# Tests of contest controller with no user logged in (no header sent)
# All requests shoud be refused

require 'test_helper'

class ContestsControllerNoUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
  end

  test "should not get index without user" do
    get api_v1_contests_url, as: :json
    assert_response 401
  end

  test "should not create contest without user" do
    post api_v1_contests_url,
        params: { contest: {name: 'New test context',
                            shortname: 'New test',
                            description: 'Description',
                            ctype: 'Groups',
                            public: false} },
        as: :json
    assert_response 401
  end

  test "should not show contest without user" do
    get api_v1_contest_url(@contest.id), as: :json
    assert_response 401
  end

  test "should not update contest without user" do
    put api_v1_contest_url(@contest),
        params: { contest: {name: @contest.name,
                            shortname: @contest.shortname,
                            description: @contest.description,
                            ctype: @contest.ctype,
                            public: @contest.public} },
        as: :json
    assert_response 401
  end

  test "should not destroy contest without user" do
    delete api_v1_contest_url(@contest), as: :json
    assert_response 401
  end
end
