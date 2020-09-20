class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized
  include Graphiti::Rails::Responders

  register_exception JWTSessions::Errors::Unauthorized, status: 401
  register_exception JWTSessions::Errors::Expired, status: 401

  ##
  # Current user or token (only one is filled), to be used in updates
  # for update_by_user_id or updated_by_token fields

  attr_accessor :current_user_id
  attr_accessor :current_token

  ##
  # Authorization for users only, no tokens accepted

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

  def authorize_user_or_readtoken!
    get_current_authorization!
    if payload['user_id']
      set_user_contest
    else
      set_token_contest
    end
  end

  ##
  # Authorization for users or write token

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
  # Set @contest to the last active contest of the user

  def set_user_contest
    @user = User.find(payload['user_id'])
    contest_id = params['contest_id'] || params['id']
    if contest_id
      @contest = Contest.public_columns.find(contest_id)
      if @contest && @contest.user_id != @user.id
        not_authorized
      end
    else
      @contest = @user.contests.public_columns.order(last_action: :desc).limit(1)
    end
    self.current_user_id = @user.id
    self.current_token = nil
  end

  ##
  # Set @contest to the contest of the token, if it is a contest token
  # or to the contest of the participant, if it is a participant token

  def set_token_contest
    if payload['tokentype'] == 'Participant'
      @participant = Participant.public_columns.find(payload['tokenid'])
      not_authorized if @participant.nil?
      contest_id = @participant.contest_id
    else
      contest_id = payload['tokenid']
    end
    @contest = Contest.public_columns.find(contest_id)
    self.current_user_id = nil
    self.current_token = payload['tokenid']
  end

end
