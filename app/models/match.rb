class Match < ApplicationRecord
  belongs_to :contest
  belongs_to :participant_1, class_name: "Participant", foreign_key: "participant_1_id"
  belongs_to :participant_2, class_name: "Participant", foreign_key: "participant_2_id"
end
