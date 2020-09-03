
ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start

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
    @headers = { 'CONTENT_TYPE' => 'application/json' }
    body =
    post signup_path, headers: @headers,
          params: '{ "username": "testuser@test.org", "password": "test" }'
    @headers['X-CSRF-TOKEN'] = JSON.parse(@response.body)['csrf']
  end

  def login_userOne
    @headers = { 'CONTENT_TYPE' => 'application/json' }
    post signin_path, headers: @headers,
          params: '{ "username": "userOne", "password": "pw" }'
    @headers['X-CSRF-TOKEN'] = JSON.parse(@response.body)['csrf']
  end

  def login_readToken
    @headers = { 'CONTENT_TYPE' => 'application/json' }
    post signin_path, headers: @headers,
          params: '{ "contestkey": "readToken1" }'
    @headers['X-CSRF-TOKEN'] = JSON.parse(@response.body)['csrf']
  end

  def login_writeToken
    @headers = { 'CONTENT_TYPE' => 'application/json' }
    post signin_path, headers: @headers,
          params: '{ "contestkey": "writeToken1" }'
    @headers['X-CSRF-TOKEN'] = JSON.parse(@response.body)['csrf']
  end

  def draw_demomeisterschaft()
    post api_v1_contest_draw_url(@contest),
      headers: @headers,
      params: { draw: { draw_tableau: [ [ participants(:DM1).id,
                                          participants(:DM2).id,
                                          participants(:DM3).id,
                                          participants(:DM4).id] ] } },
      as: :json
  end
end
