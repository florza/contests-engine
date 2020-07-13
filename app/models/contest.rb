class Contest < ApplicationRecord
  belongs_to :user
  has_many :participants

  after_initialize :init

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

  def init
    self.token_read ||= get_token
    self.token_write ||= get_token
  end

end
