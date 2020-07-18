class Contest < ApplicationRecord
  belongs_to :user
  has_many :participants
  has_many :matches

  before_create :init_attributes

  validates :name, presence: true,
                   length: { maximum: 50 },
  								 uniqueness: { case_sensitive: false,
  								               scope: :user_id,
  										           message: 'Name is not unique within this user.' }

  validates :shortname,	presence: true,
                        length: { maximum: 20 },
  										  uniqueness: { case_sensitive: false,
  										                scope: :user_id,
  										                message: 'Shortname is not unique within this user.' }

  validates :user_id,	presence: true
  validates :description, presence: true
  validates :contesttype,	presence: true,
                          inclusion: { in: %w(Groups KO GroupsKO GroupsGroup) }
  validates :nbr_sets, presence: true

  # usually hide :token_read, :token_write
  scope :public_columns,
            -> { select(:id, :user_id, :name, :shortname, :description,
                        :status, :contesttype, :nbr_sets, :public,
                        :last_action_at, :draw_at, :created_at, :updated_at) }


  def init_attributes
    self.last_action_at ||= DateTime.now
    self.token_read ||= get_token
    self.token_write ||= get_token
  end

end
