class SignupController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      user = User.public_columns.find(user.id)  # no password_digest!
      payload  = { user_id: user.id }
      session = JWTSessions::Session.new(
              payload: payload, refresh_by_access_allowed: true)
      tokens = session.login

      render json: {auth: tokens[:access],
                    signin_type: 'user',
                    signin_data: user}
    else
      render json: { error: user.errors.full_messages.join(' ') }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:username, :password, :password_confirmation, :userdata)

  end
end
