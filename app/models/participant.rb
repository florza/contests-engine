class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :contest

  validates :name,      presence: true, length: { maximum: 50 },
  										  uniqueness: { case_sensitive: false,
  										                scope: :contest_id,
  										                message: 'Name is not unique within contest.' }

  validates :shortname,	presence: true, length: { maximum: 20 },
  										  uniqueness: { case_sensitive: false,
  										                scope: :contest_id,
  										                message: 'Shortname is not unique within contest.' }

  validates :user_id,	presence: true
  validates :contest_id,	presence: true

end
