class Match < ApplicationRecord

  belongs_to :contest
  belongs_to :participant_1, class_name: "Participant", foreign_key: "participant_1_id", optional: true
  belongs_to :participant_2, class_name: "Participant", foreign_key: "participant_2_id", optional: true
  has_one :winner_next_match, class_name: "Match", foreign_key: "winner_next_match_id"
  has_one :looser_next_match, class_name: "Match", foreign_key: "looser_next_match_id"

  validates :contest_id, presence: true

  scope :public_columns,
            -> { select(:id, :user_id, :contest_id, :participant_1_id,
                        :participant_2_id, :remarks, :userdata, :contesttype_params, :planned_at, :result_at,
                        :result, :winner_id,
                        :looser_id, :created_at, :updated_at) }

end
