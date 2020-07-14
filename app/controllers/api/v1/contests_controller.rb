 module Api
  module V1
    class ContestsController < ApplicationController
      before_action :authorize_access_request! #, except: [:index]
      #before_action :authorize_user_or_readtoken!, only: [:index, :show]
      #before_action :authorize_user_or_writetoken!, except: [:index, :show]
      before_action :set_user #, only: [:show, :create, :update, :destroy]
      before_action :set_contest, only: [:show, :update, :destroy]

      # GET /contests
      def index
        @contests = @user.nil? ? Contest.all : @user.contests
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
        def set_user
          @user = current_user
        end

        def set_contest
          @contest = Contest.find(params[:id])
          if @contest && @contest.user_id != @user.id
            render json: { error: 'Not owner' }, status: :unauthorized
          end
        end

        # Only allow a trusted parameter "white list" through.
        def contest_params
          params.require(:contest).permit(:name, :shortname, :description,
                                          :contesttype, :nbr_sets, :public)
        end
    end
  end
end
