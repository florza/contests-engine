class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized

  def authorize_user!
    authorize_access_request!
    set_user_contest
  end

  def authorize_user_or_readtoken!
    if params['t'].nil?
      authorize_user!
    else
      authorize_readtoken(params['t'])
    end
  end

  def authorize_user_or_writetoken!
    if params['t'].nil?
      authorize_user!
    else
      authorize_writetoken(params['t'])
    end
  end

  def not_authorized
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end

  private

  def authorize_readtoken(token)
    contest_id = Contest.find_by_token_read(token).select(:id).first
    if contest_id
      @contest = Contest.public_columns.find(contest_id)
    else
      authorize_writetoken(token)
    end
  end

  def authorize_writetoken(token)
    if !(contest_id = Contest.find_by_token_write(token))
      if !(participant_id = Participant.find_by(token_write: token))
        not_authorized
      else
        @participant = Participant.public_columns.find(participant_id)
        @contest = Contest.public_columns.find(contest_id)
      end
    else
      @contest = Contest.public_columns.find(contest_id)
    end
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

  end
end
