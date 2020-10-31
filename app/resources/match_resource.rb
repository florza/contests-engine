class MatchResource < ApplicationResource
  belongs_to :contest

  after_attributes do |match|
    match.contest_id ||= context.current_contest.id
  end

  attribute :contest_id,           :integer_id, only:   [:filterable]
  attribute :participant_1_id,     :integer_id, except: [:writable]
  attribute :participant_2_id,     :integer_id, except: [:writable]
  # attribute :status,               :string
  attribute :planned_at,           :datetime
  attribute :remarks,              :string
  attribute :ctype_params,         :hash,       only:   [:readable, :schema]
  attribute :userdata,             :hash
  attribute :result_at,            :datetime
  attribute :result,               :hash,       onoly:  [:readable, :schema]
  attribute :result_1_vs_2,        :string,     only:   [:readable, :schema]
  attribute :result_2_vs_1,        :string,     only:   [:readable, :schema]
  attribute :stats,                :hash,       only:   [:readable, :schema]
  attribute :winner_id,            :integer_id
  attribute :looser_id,            :integer_id, except: [:writable]
  attribute :winner_next_match_id, :integer_id, except: [:writable]
  attribute :winner_next_place_1,  :boolean,    except: [:writable]
  attribute :looser_next_match_id, :integer_id, except: [:writable]
  attribute :looser_next_place_1,  :boolean,    except: [:writable]
  attribute :updated_by_user_id,   :integer_id, except: [:writable]
  attribute :updated_by_token,     :string,     except: [:writable]
  attribute :created_at,           :datetime,   except: [:writable]
  attribute :updated_at,           :datetime,   except: [:writable]

  attribute :editable,             :boolean,    only:   [:readable, :schema]

end
