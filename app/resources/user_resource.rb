class UserResource < ApplicationResource
  attribute :username,              :string
  attribute :password,              :string,  only: [:writable, :schema]
  attribute :password_confirmation, :string,  only: [:writable, :schema]
  attribute :userdata,              :hash
  attribute :created_at,            :datetime
  attribute :updated_at,            :datetime
end
