module Api
  module V1
    class TeilnehmersController < ApplicationController
      before_action :authorize_access_request!, except: [:show, :index]
      before_action :set_teilnehmer, only: [:show, :update, :destroy]

      # GET /teilnehmers
      def index
        @teilnehmers = Teilnehmer.all

        render json: @teilnehmers
      end

      # GET /teilnehmers/1
      def show
        render json: @teilnehmer
      end

      # POST /teilnehmers
      def create
        @teilnehmer = Teilnehmer.new(teilnehmer_params)

        if @teilnehmer.save
          render json: @teilnehmer, status: :created, location: @teilnehmer
        else
          render json: @teilnehmer.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /teilnehmers/1
      def update
        if @teilnehmer.update(teilnehmer_params)
          render json: @teilnehmer
        else
          render json: @teilnehmer.errors, status: :unprocessable_entity
        end
      end

      # DELETE /teilnehmers/1
      def destroy
        @teilnehmer.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_teilnehmer
          @teilnehmer = Teilnehmer.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def teilnehmer_params
          params.require(:teilnehmer).permit(:name, :kurzname, :user_id)
        end
    end
  end
end
