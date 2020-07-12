 module Api
  module V1
    class ContestsController < ApplicationController
      before_action :authorize_access_request!, except: [:show, :index]
      before_action :set_contest, only: [:show, :update, :destroy]
      before_action :set_user, only: [:show, :create, :update, :destroy]

      # GET /contests
      def index
        @contests = Contest.all
        render json: @contests
      end

      # GET /contests/1
      def show
        render json: @contest
      end

      # POST /contests
      def create
        @contest = Contest.new(contest_params)
        @contest.user_id = @user.id
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
        # Use callbacks to share common setup or constraints between actions.
        def set_contest
          @contest = Contest.find(params[:id])
        end

        def set_user
          @user = current_user
        end

        # Only allow a trusted parameter "white list" through.
        def contest_params
          params.require(:contest).permit(:name, :shortname, :description,
                                          :contesttype, :nbr_sets, :public)
        end
    end
  end
end
