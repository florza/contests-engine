module Api
  module V1
    class DrawsController < ApplicationController
      before_action :authorize_user!

      def create
        draw_mgr = get_draw_manager(params[:draw])
        draw_mgr.draw
        if draw_mgr.valid?
          render json: params[:draw], status: :created
        else
          render json: draw_mgr.errors, status: :unprocessable_entity
        end
      end

      def destroy
        draw_mgr = get_draw_manager
        draw_mgr.delete_draw(@contest)
      end

      private

      def get_draw_manager(myparams = {})
        dmclass = "DrawManager#{@contest.ctype}"
        dmclass.constantize.new(@contest, myparams)
      end

      # NOT USED: grp_groups cannot be permitted as array of arrays
      # def draw_params
      #   params.require(:draw).permit( { draw_tableau: [] },
      #                                 { draw_seeds: [] } )
      # end

    end
  end
end
