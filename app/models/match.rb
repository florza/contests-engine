class Match < ApplicationRecord

  belongs_to :contest
  belongs_to :participant_1, class_name: "Participant", foreign_key: "participant_1_id", optional: true
  belongs_to :participant_2, class_name: "Participant", foreign_key: "participant_2_id", optional: true
  has_one :winner_next_match, class_name: "Match", foreign_key: "winner_next_match_id"
  has_one :looser_next_match, class_name: "Match", foreign_key: "looser_next_match_id"

  validates :contest_id, presence: true

  before_save do |m|
    if m.result.nil?
      result_1_vs_2 = result_2_vs_1 = nil
    else
      m.result = JSON.parse(m.result) if m.result.instance_of? String
      m.result_1_vs_2 = result_to_s(m.result)
      m.result_2_vs_1 = result_rev_to_s(m.result)
    end
  end

  scope :public_columns,
            -> { select(:id, :user_id, :contest_id, :participant_1_id,
                        :participant_2_id, :remarks, :userdata, :contesttype_params, :planned_at, :result_at,
                        :result, :result_1_vs_2, :result_2_vs_1, :winner_id,
                        :looser_id, :created_at, :updated_at) }

  def result_to_s(result)
    s = ''
    result.each_with_index do |set, i|
      s += ' / ' if i > 0
      s += set[0].to_s + ':' + set[1].to_s
    end
    s
  end

  def result_rev_to_s(result)
    s = ''
    result.each_with_index do |set, i|
      s += ' / ' if i > 0
      s += set[1].to_s + ':' + set[0].to_s
    end
    s
  end
end
