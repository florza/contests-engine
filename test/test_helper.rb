ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def default_contest
    {
      user: users(:userOne),
      name: 'name',
      shortname: 'short name',
      description: 'description',
      contesttype: 'group',
      nbr_sets: 1,
      public: true,
      created_at: DateTime.now(),  # seems not to be filled in Rails 5
      updated_at: DateTime.now()
    }
  end
end
