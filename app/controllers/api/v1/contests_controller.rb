 module Api
  module V1
    class ContestsController < ApplicationController

      # Authorization and setting of the context variables
      # are handled in their own functions in ApplicationController
      # @user: only set if authorized with login,
      #        only such a user may create/edit/delete contests
      # @contest: the active contest, which may be
      #           - the last used contest of this @user
      #           - the contest defined by the contest read or write token
      #           - the contest of the participants defined by a write token
      # @participant: active participant if authorized by a
      #               particpants (not contests!) write token

      before_action :authorize_user!, except: [:index, :show]
      before_action :authorize_user_or_readtoken!, only: [:index, :show]
      #before_action :authorize_user_or_writetoken!, only: []

      # GET /contests
      def index
        @contests = @user ? @user.contests.public_columns : [@contest]
        render json: @contests
      end

      # GET /contests/1
      def show
        render json: @contest
      end

      # POST /contests
      def create
        @contest = @user.contests.new(contest_params)
        if @contest.save
          render json: @contest, status: :created
        else
          render json: @contest.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /contests/1
      def update
        if @contest.update(contest_params)
          render json: @contest
        else
          render json: @contest.errors, status: :unprocessable_entity
        end
      end

      # DELETE /contests/1
      def destroy
        @contest.destroy
      end

      private

      # Only allow a trusted parameter "white list" through.
      def contest_params
        params.require(:contest).permit(:name, :shortname, :description,
                                        :ctype, :ctype_params,
                                        :result_params, :public,
                                        :last_action_at, :userdata)
      end
    end
  end
end
