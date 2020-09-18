require 'test_helper'

class SigninControllerTest < ActionDispatch::IntegrationTest

  def setup
    register_testuser
  end

  test "can login with newly registered user" do
    post signin_path, headers: @headers, as: :json,
          params: { username: 'testuser@test.org', password: 'test' }
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can login with existing user from fixtures" do
    post signin_path, headers: @headers, as: :json,
          params: { username: users(:userOne).username, 'password': 'pw' }
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can login with contest read token" do
    post signin_path, headers: @headers, as: :json,
          params: { contestkey: 'readToken1' }
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can login with contest write token" do
    post signin_path, headers: @headers, as: :json,
          params: { contestkey: 'writeToken1' }
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can login with participant write token" do
    post signin_path, headers: @headers, as: :json,
          params: { contestkey: 'writeTokenDM1' }
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "cannot login with invalid username" do
    post signin_path, headers: @headers, as: :json,
          params: { username: 'wrongUsername', 'password': 'pw' }
    assert_response :unauthorized
    assert_nil JSON.parse(@response.body)['csrf']
  end

  test "cannot login with invalid password" do
    post signin_path, headers: @headers, as: :json,
          params: { username: users(:userOne).username, 'password': 'wrongPW' }
    assert_response :unauthorized
    assert_nil JSON.parse(@response.body)['csrf']
  end

  test "cannot login without username or token" do
    post signin_path, headers: @headers, as: :json,
          params: { }
    assert_response :unauthorized
    assert_nil JSON.parse(@response.body)['csrf']
  end

  test "cannot login with invalid token" do
    post signin_path, headers: @headers, as: :json,
          params: { contestkey: 'invalidToken' }
    assert_response :unauthorized
    assert_nil JSON.parse(@response.body)['csrf']
  end

  test "can logout" do
    delete signin_path, headers: @headers
    assert_response :success
  end
end
