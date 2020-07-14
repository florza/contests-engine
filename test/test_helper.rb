ENV['RAILS_ENV'] ||= 'test'
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
end
