module Api
  module V1
    class ParticipantsController < ApplicationController
      before_action :authorize_user!, except: [:index, :show]
      before_action :authorize_user_or_readtoken!, only: [:index, :show]
      #before_action :set_participant, only: [:show, :update, :destroy]
      #before_action :authorize_user_or_writetoken!, only: []

      # GET /contests/<contest_id>/participants
      def index
        # @participants = @contest.participants.public_columns
        params.merge! stats: { total: 'count' }
        participants = ParticipantResource.all(params,
          Participant.where(contest_id: current_contest.id))
        respond_with(participants)
      end

      # GET /contests/<contest_id>//participants/<id>
      def show
        participant = ParticipantResource.find(params)
        respond_with(participant)
      end

      # POST /contests/<contest_id>/participants
      def create
        participant = ParticipantResource.build(params)
        if participant.save
          render jsonapi: participant, status: :created
        else
          render jsonapi_errors: participant
        end
      end

      # PATCH/PUT /contests/<contest_id>/participants/1
      def update
        participant = ParticipantResource.find(params)
        if participant.update_attributes
          render jsonapi: participant
        else
          render jsonapi_errors: participant
        end
      end

      # DELETE /contests/<contest_id>/participants/1
      def destroy
        participant = ParticipantResource.find(params)
        if participant.destroy
          render jsonapi: { meta: {} }, status: :ok
        else
          render jsonapi_errors: participant.errors
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      # def set_participant
      #   @participant ||= Participant.public_columns.find(params[:id])
      #   if @participant && @contest.id != @participant.contest_id
      #     not_authorized
      #   end
      # end

      # Only allow a trusted parameter "white list" through.
      # def participant_params
      #   params.require(:participant).permit(:name, :shortname, :remarks,
      #                                       :userdata)
      # end

    end
  end
end
