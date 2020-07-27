module Api
  module V1
    class ParticipantsController < ApplicationController
      before_action :authorize_user!, except: [:index, :show]
      before_action :authorize_user_or_readtoken!, only: [:index, :show]
      before_action :set_participant, only: [:show, :update, :destroy]
      #before_action :authorize_user_or_writetoken!, only: []

      # GET /contests/<contest_id>/participants
      def index
        @participants = @contest.participants.public_columns
        render json: @participants
      end

      # GET /contests/<contest_id>//participants/<id>
      def show
        render json: @participant
      end

      # POST /contests/<contest_id>/participants
      def create
        @participant = @contest.participants.new(participant_params)
        @participant.user_id = @contest.user_id
        if @participant.save
          render json: @participant, status: :created
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
        @participant ||= Participant.public_columns.find(params[:id])
        if @participant && @contest.id != @participant.contest_id
          not_authorized
        end
      end

      # Only allow a trusted parameter "white list" through.
      def participant_params
        params.require(:participant).permit(:name, :shortname, :remarks)
      end
    end
  end
end
