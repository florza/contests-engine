 module Api
  module V1
    class ContestsController < ApplicationController

      before_action :authorize_user!, except: [:index, :show]
      before_action :authorize_user_or_token!, only: [:index, :show]

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
        respond_with(contests, meta: meta)
      end

      # GET /contests/1
      def show
        # params.merge! include: 'participants'
        contest = ContestResource.find(params)
        respond_with(contest, meta: meta)
      end

      # POST /contests
      def create
        contest = ContestResource.build(params)
        if contest.save
          render jsonapi: contest, meta: meta, status: :created
        else
          render jsonapi_errors: contest
        end
      end

      # PATCH/PUT /contests/1
      def update
        contest = ContestResource.find(params)
        if contest.update_attributes
          render jsonapi: contest, meta: meta
        else
          render jsonapi_errors: contest
        end
      end

      # DELETE /contests/1
      def destroy
        contest = ContestResource.find(params)
        if contest.destroy
          render jsonapi: { meta: meta }, status: :ok
        else
          render jsonapi_errors: contest
        end
      end

    end
  end
end
