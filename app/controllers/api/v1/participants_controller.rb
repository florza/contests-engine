module Api
  module V1
    class ParticipantsController < ApplicationController
      before_action :authorize_user!, except: [:index, :show]
      before_action :authorize_user_or_token!, only: [:index, :show]
      #before_action :set_participant, only: [:show, :update, :destroy]
      #before_action :authorize_user_or_writetoken!, only: []

      # GET /contests/<contest_id>/participants
      def index
        # @participants = @contest.participants
        params.merge! stats: { total: 'count' }
        participants = ParticipantResource.all(params,
          Participant.where(contest_id: current_contest.id))
        respond_with(participants, meta: meta)
      end

      # GET /contests/<contest_id>//participants/<id>
      def show
        participant = ParticipantResource.find(params)
        respond_with(participant, meta: meta)
      end

      # POST /contests/<contest_id>/participants
      def create
        participant = ParticipantResource.build(params)
        if participant.save
          render jsonapi: participant, meta: meta, status: :created
        else
          render jsonapi_errors: participant
        end
      end

      # PATCH/PUT /contests/<contest_id>/participants/1
      def update
        participant = ParticipantResource.find(params)
        if participant.update_attributes
          render jsonapi: participant, meta: meta
        else
          render jsonapi_errors: participant
        end
      end

      # DELETE /contests/<contest_id>/participants/1
      def destroy
        participant = ParticipantResource.find(params)
        if current_contest.has_draw
          # Simulate the error message by hand, as rails and graphiti do not
          # handle validation properly (see also participant.rb)
          render jsonapi:
            error_response(:participant, 'must not be deleted if a draw exists'),
            status: :unprocessable_entity
        elsif participant.destroy
          render jsonapi: { meta: meta }, status: :ok
        else
          render jsonapi_errors: participant.errors
        end
      end
    end

  end
end
