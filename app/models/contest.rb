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

  before_create:init_attributes

  default_scope -> { order(last_action_at: :desc) }

  # usually hide :token_read, :token_write
  scope :public_columns,
            -> { select(:id, :user_id, :name, :shortname, :description,
                        :status, :ctype, :ctype_params, :result_params,
                        :public, :last_action_at, :draw_at,
                        :userdata, :created_at, :updated_at)
                  .order(last_action_at: :desc)}


  def init_attributes
    self.last_action_at ||= DateTime.now
    self.token_read ||= get_token
    self.token_write ||= get_token
    self.ctype_params ||= DEFAULT_CTYPE_PARAMS
    self.result_params ||= DEFAULT_RESULT_PARAMS
  end

end
