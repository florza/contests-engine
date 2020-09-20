class UserController < ApplicationController

  def index
    Users = UserResource.all(params)

    respond_to do |format|
      format.json { render(json: Users) }
      format.jsonapi { render(jsonapi: Users) }
      format.xml { render(xml: Users) }
    end
  end
end
