require 'test_helper'

class ContestTest < ActionDispatch::IntegrationTest

  def setup
    register_testuser
  end

  test "can register new user" do
    post signup_path, headers: @headers,
          params: '{ "email": "registeruser@test.org", "password": "test" }'
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can login with newly registered user" do
    post signin_path, headers: @headers,
          params: '{ "email": "testuser@test.org", "password": "test" }'
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can login with existing user from fixtures" do
    post signin_path, headers: @headers,
          params: '{ "email": "userOne@example.com", "password": "password" }'
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

 test "can logout" do
    delete signin_path, headers: @headers
    assert_response :success
  end

  test "user can get all her contest" do
    login_userOne
    get api_v1_contests_path, headers: @headers
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 2, result.count
  end

end
