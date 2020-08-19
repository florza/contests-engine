class SigninController < ApplicationController
  before_action :authorize_access_request!, only: [:destroy]

  def create
    if params[:username] && params[:username] > ''
      user = User.public_columns.where("lower(username) = ?",
              params[:username].downcase).first
      return not_found_user if user.nil?
      payload = { user_id: user.id }
    elsif params[:contestkey] && params[:contestkey] > ''
      contestkey = params[:contestkey]
      if contest = Contest.find_by_token_read(contestkey)
        payload = { tokentype: 'Contest',
                    tokenrole: 'read',
                    tokenid: contest.id }
      elsif contest = Contest.find_by_token_write(contestkey)
        payload = { tokentype: 'Contest',
                    tokenrole: 'write',
                    tokenid: contest.id }
      elsif participant = Participant.find_by_token_write(contestkey)
        payload = { tokentype: 'Participant',
                    tokenrole: 'write',
                    tokenid: participant.id }
      else
        return not_found_token
      end
    else
      return not_authorized
    end

    session = JWTSessions::Session.new(payload: payload,
                                        refresh_by_access_allowed: true)
    tokens = session.login
    response.set_cookie(JWTSessions.access_cookie,
                      value: tokens[:access],
                      httponly: true,
                      secure: Rails.env.production?)
    render json: {csrf: tokens[:csrf],
                  signin_type: payload[:user_id] ? 'user' : 'token',
                  signin_data: payload[:user_id] ? user : payload}
  end

  def destroy
    session = JWTSessions::Session.new(payload: payload)
    session.flush_by_access_payload
    render json: :ok
  end

  private

  def not_found_user
    render json: { error: "Cannot find username/password combination" },
            status: :not_found
  end

  def not_found_token
    render json: { error: "Cannot find contest key" },
            status: :not_found
  end
end
