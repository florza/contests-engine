class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :contest

  before_create :init_attributes

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
  validates :remarks,	presence: true

  # usually hide :token_write
  scope :public_columns,
            -> { select(:id, :user_id, :contest_id, :name, :shortname,
                        :remarks, :status, :group_params, :ko_params,
                        :created_at, :updated_at) }

  def init_attributes
    self.token_write ||= get_token
  end

end
