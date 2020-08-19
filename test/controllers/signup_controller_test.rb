require 'test_helper'

class SignupControllerTest < ActionDispatch::IntegrationTest

  test "can register new user" do
    post signup_path, headers: @headers,
          params: { username: 'registeruser', password: 'test' },
          as: :json
    assert_response :success
    assert_not_nil JSON.parse(@response.body)['csrf']
    assert_not_nil User.find_by(username: "registeruser")
  end

end
