class Participant < ApplicationRecord
  belongs_to :user
  belongs_to :contest
  has_many :participants_1, class_name: "Match", foreign_key: "participant_1_id"
  has_many :participants_2, class_name: "Match", foreign_key: "participant_2_id"

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
  validates :remarks, exclusion: { in: [nil] }  # allow blank, but not null

  validate :no_create_after_draw, on: :create

  before_create :init_attributes

  def no_create_after_draw
    if contest.has_draw
      errors.add(:participant, 'must not be added if a draw exists')
    end
  end

  ##
  # The following logic similar to the above was copied from ActiveRecord
  # Guides, but nevertheles produces an error in throw:
  #   NoMethodError (undefined method `data' for #<ActiveModel::Errors:0x0...>),
  # probably because destroys usually run no validations and of an unproper
  # handling of Graphiti in this case.
  # It was therefore replaced by logic in ParticipantsController#destroy

  # before_destroy :no_destroy_after_draw
  # def no_destroy_after_draw
  #   if contest.has_draw
  #     errors.add(:participant, 'must not be deleted if a draw exits')
  #     throw(:abort)
  #   end
  # end

  def init_attributes
    self.token_write ||= get_token
    self.remarks ||= ''
  end

end
