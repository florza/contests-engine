require 'test_helper'

class ContestsControllerTokenTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
  end

  test "should get index of contest with token" do
    login_readToken
    get api_v1_contests_url, as: :json
    result = JSON.parse(@response.body)
    assert_equal 1, result['data'].size
  end

  test "should show token contest with token" do
    login_readToken
    get api_v1_contest_url(@contest), as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result['data'].size
  end

  test "should not create new contest with token" do
    login_writeToken
    post api_v1_contests_url,
        params: {
            data: { type: 'contests',
                    attributes: { name: 'New test contest',
                                  shortname: 'New test',
                                  description: 'Description',
                                  ctype: 'Groups' } }
          },
          as: :json
    assert_response 401
  end

  test "should not update contest with token" do
    login_writeToken
    put api_v1_contest_url(@contest),
        params: {
          data: { type: 'contests',
                  id: @contest.id,
                  attributes: { name: @contest.name,
                                shortname: @contest.shortname,
                                description: @contest.description,
                                ctype: @contest.ctype } }
        },
        as: :json
    assert_response 401
  end

  test "should not destroy contest with token" do
    login_writeToken
    delete api_v1_contest_url(@contest), as: :json
    assert_response 401
  end
end
