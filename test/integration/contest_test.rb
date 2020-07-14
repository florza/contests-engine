require 'test_helper'

class ContestTest < ActionDispatch::IntegrationTest

  def setup
    register_testuser
  end

  test "can register new user" do
    post signup_path, headers: @headers,
          params: '{ "email": "registeruser@test.org", "password": "test" }'
    assert_response :success
  end

  test "can login with registered user" do
    post signin_path, headers: @headers,
          params: '{ "email": "testuser@test.org", "password": "test" }'
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
  end

  test "can logout" do
    delete signin_path, headers: @headers
    assert_response :success
  end

  private

  def register_testuser
    @headers = { 'CONTENT_TYPE' => 'application/json' }
    body =
    post signup_path, headers: @headers,
          params: '{ "email": "testuser@test.org", "password": "test" }'
    @headers['X-CSRF-TOKEN'] = JSON.parse(@response.body)['csrf']
  end
end
