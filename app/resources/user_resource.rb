class UserResource < ApplicationResource
  attribute :username, :string
  attribute :userdata, :hash
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
end

UserResource.all.data
