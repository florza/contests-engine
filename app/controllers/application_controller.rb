class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized

  def authorize_user_or_readtoken!
    if params['t'].nil?
      authorize_access_request!
    else
      # not yet implemented
    end
  end

  def authorize_user_or_writetoken!
    if params['t'].nil?
      authorize_access_request!
    else
      # not yet implemented
    end
  end

  def current_user
    @current_user ||= User.find(payload['user_id'])
  end

  def not_authorized
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end
end
