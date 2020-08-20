module Api
  module V1
    class MatchesController < ApplicationController
      before_action :authorize_user_or_readtoken!, only: [:show, :index]
      before_action :authorize_user_or_writetoken!, except: [:index, :show]
      before_action :set_match, only: [:show, :update]

      # GET /matches
      def index
        @matches = @contest.matches
        render json: @matches
      end

      # GET /matches/1
      def show
        render json: @match
      end

      # POST /matches
      # def create
      #   @match = Match.new(match_params)

      #   if @match.save
      #     render json: @match, status: :created, location: @match
      #   else
      #     render json: @match.errors, status: :unprocessable_entity
      #   end
      # end

      # PATCH/PUT /matches/1
      def update
        if @match.update(match_params)
          render json: @match
        else
          render json: @match.errors, status: :unprocessable_entity
        end
      end

      # DELETE /matches/1
      # def destroy
      #   @match.destroy
      # end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_match
          @match = Match.public_columns.find(params[:id])
          if @match && @contest.id != @match.contest_id
            not_authorized
          end
        end

        # Only allow a trusted parameter "white list" through.
        def match_params
          params.require(:match).permit(:remarks, :winner_id,
                                        :planned_at, :userdata,
                                        { result: [ { score_p1: [] },
                                                    { score_p2: [] },
                                                    :walk_over,
                                                    :lucky_loser ] })
        end
    end
  end
end
