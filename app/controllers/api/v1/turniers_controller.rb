module Api
  module V1
    class TurniersController < ApplicationController
      before_action :authorize_access_request!, except: [:show, :index]
      before_action :set_turnier, only: [:show, :update, :destroy]

      # GET /turniers
      def index
        @turniers = Turnier.all

        render json: @turniers
      end

      # GET /turniers/1
      def show
        render json: @turnier
      end

      # POST /turniers
      def create
        @turnier = Turnier.new(turnier_params)

        if @turnier.save
          render json: @turnier, status: :created, location: @turnier
        else
          render json: @turnier.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /turniers/1
      def update
        if @turnier.update(turnier_params)
          render json: @turnier
        else
          render json: @turnier.errors, status: :unprocessable_entity
        end
      end

      # DELETE /turniers/1
      def destroy
        @turnier.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_turnier
          @turnier = Turnier.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def turnier_params
          params.require(:turnier).permit(:name)
        end
    end
  end
end
