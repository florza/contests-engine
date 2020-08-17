require 'test_helper'

class SigninControllerTest < ActionDispatch::IntegrationTest

  def setup
    register_testuser
  end

  test "can login with newly registered user" do
    post signin_path,
          headers: @headers,
          params: { username: 'testuser@test.org', password: 'test' },
          as: :json
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can login with existing user from fixtures" do
    post signin_path,
          headers: @headers,
          params: { username: users(:userOne).username, 'password': 'pw' },
          as: :json
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can logout" do
    delete signin_path, headers: @headers
    assert_response :success
  end
end
