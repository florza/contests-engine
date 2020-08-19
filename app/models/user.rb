class User < ApplicationRecord
  has_many :contests
  has_secure_password

  validates :username,  presence: true,
                        length: { maximum: 20 },
  								      uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true
  validates :password, confirmation: true

  scope :public_columns,
            -> { select(:id, :username, :userdata, :created_at, :updated_at) }
end
