
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

  ##
  # Set @contest and @full_params to values for DemoKO

  def prepare_draw_ko
    @contest = contests(:DemoKO)
    @full_params = {
      contest_id: @contest.id,  # simulates the id coming from the url
      data: { type: 'contests',
              id: @contest.id,
              attributes: { draw_tableau: [ [ participants(:DKO1).id,
                                              'BYE',
                                              participants(:DKO2).id,
                                              participants(:DKO3).id,
                                              participants(:DKO4).id,
                                              participants(:DKO5).id,
                                              'BYE',
                                              participants(:DKO6).id ] ] } }
    }
  end

  ##
  # Execute manual draw with the above parameters

  def draw_ko
    prepare_draw_ko
    draw_params = @full_params
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
    mgr.draw
    @contest.reload
    return mgr
  end

  ##
  # Create a first draw and a match result for :DemoGruppen

  def create_draw_and_result
    # Create first draw
    draw_params = @full_params
    draw_mgr = DrawManagerGroups.new(draw_params)
    draw_mgr.draw
    assert draw_mgr.valid?

    # Add a match result
    match = @contest.matches.last
    match.result = { 'score_p1' => [3], 'score_p2' => [6] }
    match.winner_id = match.participant_2_id
    assert match.save
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
