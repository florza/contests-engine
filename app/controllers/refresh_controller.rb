class RefreshController < ApplicationController
  before_action :authorize_refresh_by_access_request!

  def create
    session = JWTSessions::Session.new(
          payload: claimless_payload, refresh_by_access_allowed: true)
    tokens = session.refresh_by_access_payload do
      raise JWTSessions.Errors.Unauthorized, "Somethings not right here!"
    end
    render json: { auth: tokens[:access] }
  end
end
