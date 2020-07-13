module Api
  module V1
    class ParticipantsController < ApplicationController
      before_action :authorize_access_request!, except: [:show, :index]
      before_action :set_participant, only: [:show, :update, :destroy]
      before_action :current_contest

      # GET /contests/<contest_id>/participants
      def index
        @participants = Participant.all
        render json: @participants
      end

      # GET /contests/<contest_id>//participants/<id>
      def show
        render json: @participant
      end

      # POST /contests/<contest_id>/participants
      def create
        @participant = Participant.new(participant_params)

        if @participant.save
          render json: @participant, status: :created, location: @participant
        else
          render json: @participant.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /contests/<contest_id>/participants/1
      def update
        if @participant.update(participant_params)
          render json: @participant
        else
          render json: @participant.errors, status: :unprocessable_entity
        end
      end

      # DELETE /contests/<contest_id>/participants/1
      def destroy
        @participant.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_participant
          @participant = Participant.find(params[:id])
          render json: @participant.errors, status: :unprocessable_entity
        end

        # Only allow a trusted parameter "white list" through.
        def participant_params
          params.require(:participant).permit(:name, :shortname, :remarks,
                                              :group, :grp_start,
                                              :ko_tableau, :ko_start)
        end

        def current_contest
          @contest = Contest.find_by(id: params[:contest_id])
        end
end
  end
end
