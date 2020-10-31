
ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Log in as a particular user (in controller tests).
  def log_in_as(user)
    session[:user_id] = user.id
  end

  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

end

class ActionDispatch::IntegrationTest
  # Setup fixtures also for integration tests.
  fixtures :all


  # register a special testuser
  # because password AND password_digest of fixtures are NOT known
  def register_testuser
    @headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
    body =
    post signup_path, headers: @headers,
          params: '{ "username": "testuser@test.org", "password": "test" }'
    @headers['Authorization'] = JSON.parse(@response.body)['auth']
  end

  def login_userOne
    @headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
    post signin_path, headers: @headers,
          params: '{ "username": "userOne", "password": "pw" }'
    @headers['Authorization'] = JSON.parse(@response.body)['auth']
  end

  def logout
    delete signin_path, headers: @headers
  end

  def login_readToken
    @headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
    post signin_path, headers: @headers,
          params: '{ "contestkey": "readToken1" }'
    @headers['Authorization'] = JSON.parse(@response.body)['auth']
  end

  def login_writeToken
    @headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
    post signin_path, headers: @headers,
          params: '{ "contestkey": "writeToken1" }'
    @headers['Authorization'] = JSON.parse(@response.body)['auth']
  end

  def login_participantToken
    @headers = { 'CONTENT_TYPE' => 'application/vnd.api+json' }
    post signin_path, headers: @headers,
          params: '{ "contestkey": "writeTokenDM1" }'
    @headers['Authorization'] = JSON.parse(@response.body)['auth']
  end

  def draw_demomeisterschaft()
    post api_v1_contest_draw_url(@contest),
      headers: @headers,
      params: {
        data: { type: 'contests',
                id: @contest.id,
                attributes: { draw_tableau: [
                                [ participants(:DM1).id,
                                  participants(:DM2).id,
                                  participants(:DM3).id,
                                  participants(:DM4).id] ] } }
      },
      as: :json
  end
end
