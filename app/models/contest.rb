class Contest < ApplicationRecord

  DEFAULT_RESULT_PARAMS =
    { 'winning_sets' => 1, 'tie_allowed': false,
      'points_win' => 3, 'points_loss' => 0, 'points_tie' => 1}
  DEFAULT_CTYPE_PARAMS = { 'draw_tableau' => [[]], 'draw_seeds' => [] }

  belongs_to :user
  has_many :participants
  has_many :matches

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
  validates :ctype,	inclusion: { in: %w(Groups KO GroupsKO GroupsGroup) }

  validate :no_ctype_update_after_draw, on: :update

  before_create:init_attributes

  def no_ctype_update_after_draw
    if ctype_changed? && has_draw
      errors.add(:ctype, 'must not be changed if a draw exists')
    end
  end

  def has_draw
    matches.count > 0
  end

  def has_started
    matches.where('winner_id is not null').count > 0
  end

  def init_attributes
    self.last_action_at ||= DateTime.now
    self.token_read ||= get_token
    self.token_write ||= get_token
    self.ctype_params ||= DEFAULT_CTYPE_PARAMS
    self.result_params ||= DEFAULT_RESULT_PARAMS
  end

end
