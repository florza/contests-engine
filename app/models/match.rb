class Match < ApplicationRecord

  belongs_to :contest
  belongs_to :participant_1, class_name: "Participant", foreign_key: "participant_1_id", optional: true
  belongs_to :participant_2, class_name: "Participant", foreign_key: "participant_2_id", optional: true
  belongs_to :winner_next_match, class_name: "Match", foreign_key: "winner_next_match_id", optional: true
  belongs_to :looser_next_match, class_name: "Match", foreign_key: "looser_next_match_id", optional: true

  validates :contest_id, presence: true
  validate :validate_result

  after_initialize do |m|
    @contest = self.contest
  end

  before_validation do |m|
    begin
      m.result = JSON.parse(m.result) if m.result.is_a?(String)
    rescue JSON::ParserError
      errors.add(:result, "is not a valid JSON field")
    end
  end

  before_save do |m|
    # m.result_1_vs_2 = Result.to_s(m.result)
    # m.result_2_vs_1 = Result.to_s_reversed(m.result)
    m.stats = Result.get_stats(m, @contest.result_params)
    # m.ctype_params = Result.get_ctype_params(m, @contest.ctype)
  end

  after_update do |m|
    #if m.result_1_vs_2 != result_1_vs_2_was
      process_result
    #end
  end

  def result_1_vs_2
    Result.to_s(result)
  end

  def result_2_vs_1
    Result.to_s_reversed(result)
  end

  def result_editable
    !participant_1_id.nil? &&
      !participant_2_id.nil? &&
      winner_next_match&.winner_id.nil? # no result yet
  end

  def validate_result
    if !new_record? && !result_editable &&
        (result_changed? || winner_id_changed?)
      errors.add(:result, 'must not be changed if a draw exists')
    end
    if (message = Result.validate(result, self, @contest.result_params))
      errors.add(:result, message)
    end
  end

  def process_result
    pmclass = "ProcessManager#{@contest.ctype}".constantize
    pmclass.process_result(self, @contest)
  end
end
