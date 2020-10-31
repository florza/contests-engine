class RefreshController < ApplicationController
  before_action :authorize_refresh_by_access_request!

  def create
    logger.debug "Refresh token: #{log_token(request_headers['Authorization'])}"
    session = JWTSessions::Session.new(
          payload: claimless_payload, refresh_by_access_allowed: true)
    tokens = session.refresh_by_access_payload do
      logger.debug "Token refresh faileded!"
      raise JWTSessions::Errors::Unauthorized, 'Malicious activity detected'
    end
    logger.debug "Token refreshed: #{log_token(tokens[:access])}"
    render json: { auth: tokens[:access] }
  end
end
