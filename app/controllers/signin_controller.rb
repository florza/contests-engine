class SigninController < ApplicationController
  before_action :authorize_access_request!, only: [:destroy]

  def create
    if params[:username] && params[:username] > ''
      user = User.where("lower(username) = ?",
              params[:username].downcase).first
      return not_found_user if user.nil?
      return not_authorized unless user.authenticate(params[:password])
      user = User.public_columns.find(user.id)  # no password_digest!
      payload = { user_id: user.id }
    elsif params[:contestkey] && params[:contestkey] > ''
      contestkey = params[:contestkey]
      if (contest = Contest.find_by_token_read(contestkey))
        payload = { tokentype: 'Contest',
                    tokenrole: 'read',
                    tokenid: contest.id }
      elsif (contest = Contest.find_by_token_write(contestkey))
        payload = { tokentype: 'Contest',
                    tokenrole: 'write',
                    tokenid: contest.id }
      elsif (participant = Participant.find_by_token_write(contestkey))
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
    render json: {auth: tokens[:access],
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
            status: :unauthorized
  end

  def not_found_token
    render json: { error: "Cannot find contest key" },
            status: :unauthorized
  end
end
