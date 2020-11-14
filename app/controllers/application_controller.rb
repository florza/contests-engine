class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized
  include Graphiti::Rails::Responders

  ##
  # Render a more detailled status code than 500 if not authorized

  register_exception JWTSessions::Errors::Unauthorized, status: 401
  register_exception JWTSessions::Errors::Expired, status: 401

  ##
  # Define read access to login details, according to type of authentication:
  # current_contest: always set, except on user login of a user with 0 contests
  #                  on SignIn (no contest_id in request), the contest with
  #                  the highest last_action_at is used
  # current_user: set if user login
  # current_token: set if login by contest or participant token
  # current_participant: set if login by participant token
  #
  # These details are also made available to resources in ApplicationResource

  attr_reader :current_contest
  attr_reader :current_user
  attr_reader :current_token
  attr_reader :current_participant

  ##
  # Authorization for users only, no tokens accepted
  # Needed for all data changes except match updates

  def authorize_user!
    get_current_authorization!
    if payload['user_id']
      set_user_contest
    else
      not_authorized
    end
  end

  ##
  # Authorization for users or any token (read or write)
  # Needed for all reads

  def authorize_user_or_token!
    get_current_authorization!
    if payload['user_id']
      set_user_contest
    else
      set_token_contest
    end
  end

  ##
  # Authorization for users or write token
  # Needed for updates of matches, mostly for result edits

  def authorize_user_or_writetoken!
    get_current_authorization!
    if payload['user_id']
      set_user_contest
    elsif payload['tokenrole'] == 'write'
      set_token_contest
    else
      not_authorized
    end
  end

  ##
  # Authorization of the refresh request
  # which needs an already timed out access token
  def authorize_refresh!
    authorize_refresh_by_access_request!
  end

  ##
  # Handling of 'not_authorized' execptions raised by JWT or ourselfs.

  def not_authorized
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end

  private

  ##
  # Check the token with the original JWT-Session methods.
  # Returns only if a valid user, contest or participant token
  # has been found, otherwise a not_authorized exception is raised.

  def get_current_authorization!
    authorize_access_request!
  end

  ##
  # Set @current_contest and other fields to
  # - the contest whose id is part of the request
  # - or the last active contest of the user

  def set_user_contest
    @current_user = User.find(payload['user_id'])
    contest_id = params.dig('contest_id') ||
        params.dig('data', 'attributes', 'contest_id') ||
        params.dig('id') ||
        params.dig('data', 'id')
    if contest_id
      @current_contest = Contest.find(contest_id)
      if @current_contest&.user_id != @current_user.id
        not_authorized
      end
    else
      @current_contest =
        @current_user.contests.order(last_action_at: :desc).first
    end
    @current_token = nil
    @current_participant = nil
  end

  ##
  # Set @current_contest and other fields to
  # - the contest of the token, if it is a contest token, or
  # - to the contest of the participant, if it is a participant token

  def set_token_contest
    if payload['tokentype'] == 'Participant'
      @current_participant = Participant.find(payload['tokenid'])
      not_authorized if @current_participant.nil?
      contest_id = @current_participant.contest_id
    else
      @current_participant = nil
      contest_id = payload['tokenid']
    end
    @current_contest = Contest.find(contest_id)
    @current_token = payload['tokenid']
    @current_user = nil
  end

  def log_token(token)
    return 'none' if !token
    return token if  token.size < 21
    token.first(10) + '...' + token.last(10)
  end

  def error_response(attribute, message)
        {
          errors: [{
            code:  'unprocessable_entity',
            status: '422',
            title: "Validation Error",
            detail: attribute.to_s.camelcase + ' ' + message,
            source: {},
            meta: {
              attribute: attribute,
              message: message,
              code: :blank
            }
          }]
        }
      end
end
