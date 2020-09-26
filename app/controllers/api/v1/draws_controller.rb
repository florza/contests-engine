module Api
  module V1
    class DrawsController < ApplicationController
      before_action :authorize_user!
      before_action :sanitize_params, only: [:show, :create]

      ##
      # The draw manager must be available in DrawResource as a virtual
      # model object that contains the data
      attr_reader :draw_manager

      def show
        params['fields'] = { draws: 'draw_structure' }
        @draw_manager = get_draw_manager(params)
        draw = DrawResource.find(params)
        if @draw_manager.valid?
          respond_with(draw)
        else
          render jsonapi_errors: draw
        end
      end

      ##
      # Returns not only the draw_tableau, but the whole contest
      def create
        params[:fields] = { draws: 'draw_tableau' }
        @draw_manager = get_draw_manager(params)
        @draw_manager.draw
        draw = DrawResource.find(params)
        if @draw_manager.valid?
          respond_with(draw)

          # Variant: return the entire contest with all changes
          # params.delete!(:data)
          # params[:include] = 'participants,matches'
          # contest = ContestResource.find(params)
          # respond_with(contest)
        else
          render jsonapi_errors: draw
        end
      end

      def destroy
        @draw_manager = get_draw_manager(params)
        @draw_manager.delete_draw(current_contest)
        render jsonapi: { meta: {} }, status: :ok
      end

      private

      ##
      # Get a new DrawManager with the correct class for the contests ctype.

      def get_draw_manager(myparams = {})
        myparams ||= { contest_id: current_contest.id }
        dmclass = "DrawManager#{current_contest.ctype}"
        dmclass.constantize.new(myparams)
      end

      ##
      # In rails tests, params in GET requests must be appended to the query
      # string, they cannot be sent in the body as in other requests.
      # Therefore, in such tests draw_tableau is sent as a string, not as a
      # JSON field. It must be transformed to handle it correctly.
      # In real request from a client (or Postman), no transformation would
      # be necessary.

      def sanitize_params
        draw_tableau = params.dig(:data, :attributes, :draw_tableau)
        if draw_tableau.class == String
          params[:data][:attributes][:draw_tableau] = JSON.parse(draw_tableau)
        end
      end

    end
  end
end
