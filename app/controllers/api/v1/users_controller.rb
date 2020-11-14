module Api
  module V1
    class UsersController < ApplicationController
      def index
        users = UserResource.all(params)
        render jsonapi: users, meta: meta
        # respond_with(users, meta: meta)
      end

      def show
        user = UserResource.find(params)
        respond_with(user, meta: meta)
      end

      def create
        user = UserResource.build(params)

        if user.save
          render jsonapi: user, meta: meta, status: 201
        else
          render jsonapi_errors: user
        end
      end

      def update
        user = UserResource.find(params)

        if user.update_attributes
          render jsonapi: user, meta: meta
        else
          render jsonapi_errors: user
        end
      end

      def destroy
        user = UserResource.find(params)

        if user.destroy
          render jsonapi: { meta: meta }, status: 200
        else
          render jsonapi_errors: user
        end
      end

    end
  end
end
