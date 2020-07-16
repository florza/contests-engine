module Api
  module V1
    class DrawsController < ApplicationController
      before_action :authorize_user!

      def create
        dmclass = "DrawManager#{@contest.contesttype}"
        draw_mgr = dmclass.constantize.new(@contest, params[:draw])
        draw_mgr.draw
        if draw_mgr.errors?
          render json: draw_mgr.errors, status: :unprocessable_entity
        else
          render json: params[:draw], status: :created
        end
      end
    end
  end
end
