require 'test_helper'

class SignupControllerTest < ActionDispatch::IntegrationTest

  test "can register new user" do
    post signup_path, headers: @headers,
          params: { email: 'registeruser@test.org', password: 'test' },
          as: :json
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
    assert_not_nil User.find_by(email: "registeruser@test.org")
  end

end
