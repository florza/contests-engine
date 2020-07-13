class User < ApplicationRecord
  has_many :contests
  has_secure_password

  validates :email, presence: true
  validates :password_digest, presence: true
end
