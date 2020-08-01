class Match < ApplicationRecord

  belongs_to :contest
  belongs_to :participant_1, class_name: "Participant", foreign_key: "participant_1_id", optional: true
  belongs_to :participant_2, class_name: "Participant", foreign_key: "participant_2_id", optional: true
  has_one :winner_next_match, class_name: "Match", foreign_key: "winner_next_match_id"
  has_one :looser_next_match, class_name: "Match", foreign_key: "looser_next_match_id"

  validates :contest_id, presence: true
  validate :validate_result

  before_save do |m|
    m.result_1_vs_2 = Result.to_s(m.result)
    m.result_2_vs_1 = Result.to_s_reversed(m.result)
  end
  after_update do |m|
    #if m.result_1_vs_2 != result_1_vs_2_was
      process_result
    #end
  end

  scope :public_columns,
            -> { select(:id, :user_id, :contest_id, :participant_1_id,
                        :participant_2_id, :remarks, :userdata, :contesttype_params, :planned_at, :result_at,
                        :result, :result_1_vs_2, :result_2_vs_1, :winner_id,
                        :looser_id, :created_at, :updated_at) }

  def validate_result
    return if result.nil?
    if (message = Result.validate(result, self, self.contest))
      errors.add(:result, message)
    end
  end

  def process_result
    pmclass = "ProcessManager#{self.contest.contesttype}"
    process_mgr = pmclass.constantize.new(self, self.contest)
    process_mgr.process_result
  end
end
