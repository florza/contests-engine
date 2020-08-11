require 'test_helper'

class ContestsControllerTokenTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @token_read = "?t=#{@contest.token_read}"
    @token_write = "?t=#{@contest.token_write}"
  end

  test "should get index of contest with token" do
    get api_v1_contests_url + @token_read, as: :json
    result = JSON.parse(@response.body)
    assert_equal 1, result.count
  end

  test "should show token contest" do
    get api_v1_contest_url(@contest) + @token_read, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result.count
  end

  test "should not create new contest with token" do
    post api_v1_contests_url + @token_write,
        params: { contest: {name: 'New test context',
                            shortname: 'New test',
                            description: 'Description',
                            ctype: 'Groups',
                            public: false} },
        as: :json
    assert_response 401
  end

  test "should not update contest with token" do
    put api_v1_contest_url(@contest) + @token_write,
        params: { contest: {name: @contest.name,
                            shortname: @contest.shortname,
                            description: @contest.description,
                            ctype: @contest.ctype,
                            public: @contest.public} },
        as: :json
    assert_response 401
  end

  test "should not destroy contest with token" do
    delete api_v1_contest_url(@contest) + @token_write, as: :json
    assert_response 401
  end
end
