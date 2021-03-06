module Api
  module V1
    class MatchesController < ApplicationController
      before_action :authorize_user_or_token!, only: [:show, :index]
      before_action :authorize_user_or_writetoken!, except: [:index, :show]
      #before_action :set_match, only: [:show, :update]

      # GET /contests/:contest_id/matches
      def index
        params.merge! stats: { total: 'count' }
        matches = MatchResource.all(params,
          Match.where(contest_id: current_contest.id))
        respond_with(matches, meta: meta)
      end

      # GET /contests/:contest_id/matches/1
      def show
        match = MatchResource.find(params)
        respond_with(match, meta: meta)
      end

      # POST /matches
      # def create
      #   match = MatchResource.find(params)
      #   if match.save
      #     render jsonapi: match, meta: meta, status: :created
      #   else
      #     render jsonapi_errors: match
      #   end
      # end

      # PATCH/PUT /matches/1
      def update
        match = MatchResource.find(params)
        params.merge!(updated_by_user_id: current_user&.id,
                      updated_by_token: current_token)
        if match.update_attributes
          render jsonapi: match, meta: meta
        else
          render jsonapi_errors: match
        end
      end

      # DELETE /matches/1
      # def destroy
      #   match = MatchResource.find(params)
      #   if match.destroy
      #     render jsonapi: { meta: meta }, status: :ok
      #   else
      #     render jsonapi_errors: match
      #   end
      # end

    end
  end
end
