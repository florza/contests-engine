module Api
  module V1
    class DrawsController < ApplicationController
      before_action :authorize_user!

      def show
        #draw_mgr = DrawManagerResource.build(params)
        draw_mgr = get_draw_manager(params)
        if draw_mgr.valid?
          structure = draw_mgr.draw_structure
          #r = DrawResource.build(draw_mgr)
          as_jsonapi = { data: {type: 'draw',
                                id: current_contest.id,
                                attributes: { draw_tableau: structure } } }
          render json: as_jsonapi
        else
          render jsonapi_errors: draw_mgr
        end
      end

      def create
        draw_mgr = get_draw_manager(params)
        draw_mgr.draw
        if draw_mgr.valid?
          # render jsonapi: params[:draw], status: :created
          myparams = params.delete(:data)
          myparams.merge! include: 'participants'
          contest = ContestResource.find(params)
          respond_with(contest)
        else
          render jsonapi_errors: draw_mgr
        end
      end

      def destroy
        draw_mgr = get_draw_manager(params)
        draw_mgr.delete_draw(current_contest)
      end

      private

      def get_draw_manager(myparams = {})
        myparams ||= { contest_id: current_contest.id }
        dmclass = "DrawManager#{current_contest.ctype}"
        dmclass.constantize.new(myparams)
      end

      # NOT USED: draw_tableau cannot be permitted as array of arrays
      # def draw_params
      #   params.require(:draw).permit( { draw_seeds: [] },
      #                                 { draw_tableau: [] } )
      # end

    end
  end
end
