class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized

  # current user or token (only one is filled)
  attr_accessor :current_user_id
  attr_accessor :current_token

  def authorize_user!
    get_current_authorization!
    payload['user_id'].nil? ? not_authorized : set_user_contest
  end

  def authorize_user_or_readtoken!
    get_current_authorization!
    if payload['user_id']
      set_user_contest
    else
      set_token_contest
    end
  end

  def authorize_user_or_writetoken!
    get_current_authorization!
    if payload['user_id']
      set_user_contest
    else
       if payload['tokenrole'] === 'write'
        set_token_contest
       else
        not_authorized
       end
    end
  end

  def not_authorized
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end

  private

  def get_current_authorization!
    authorize_access_request!
  end

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

  def set_token_contest
    if payload['tokentype'] == 'participant'
      @participant  = Participant.public_columns.find(payload['tokenid'])
      not_authorized if @participant.nil?
      contest_id = @participant.contest_id
    else
      contest_id = payload['tokenid']
    end
    @contest = Contest.public_columns.find(contest_id)
    not_authorized if @contest.nil?
    self.current_user_id = nil
    self.current_token = payload['tokenid']
  end

end
