 module Api
  module V1
    class ContestsController < ApplicationController

      before_action :authorize_user!, except: [:index, :show]
      before_action :authorize_user_or_readtoken!, only: [:index, :show]

      # GET /contests
      # All contests of the current user or the 1 contest identified by token
      def index
        params.merge! stats: { total: 'count' }
        contest_selection =
          if current_user
            {user_id: current_user.id}
          else
            {id: current_contest.id}
          end
        contests = ContestResource.all(params, Contest.where(contest_selection))
        respond_with(contests)
      end

      # GET /contests/1
      def show
        # params.merge! include: 'participants'
        contest = ContestResource.find(params)
        respond_with(contest)
      end

      # POST /contests
      def create
        contest = ContestResource.build(params)
        if contest.save
          render jsonapi: contest, status: :created
        else
          render jsonapi_errors: contest
        end
      end

      # PATCH/PUT /contests/1
      def update
        contest = ContestResource.find(params)
        if contest.update_attributes
          render jsonapi: contest
        else
          render jsonapi_errors: contest
        end
      end

      # DELETE /contests/1
      def destroy
        contest = ContestResource.find(params)
        if contest.destroy
          render jsonapi: { meta: {} }, status: :ok
        else
          render jsonapi_errors: contest
        end
      end

      private

      # Only allow a trusted parameter "white list" through.
      # def contest_params
      #   params.require(:contest).permit(:name, :shortname, :description,
      #                                   :ctype, :public, :last_action_at,
      #                                   :userdata,
      #                                   { result_params: [:winning_sets,
      #                                                     :tie_allowed,
      #                                                     :points_win,
      #                                                     :points_tie,
      #                                                     :points_loss] })
      # end
    end
  end
end
