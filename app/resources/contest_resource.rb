class ContestResource < ApplicationResource
  has_many :participants, single: true
  has_many :matches, single: true

  after_attributes do |contest|
    contest.user_id ||= context.current_user.id
  end

  self.default_sort = [{ last_action_at: :desc }]

  attribute :user_id,        :integer,  only: [:filterable]
  # attribute :status,         :string,   except: [:writable]
  # attribute :public,         :boolean
  attribute :name,           :string
  attribute :shortname,      :string
  attribute :description,    :string
  attribute :ctype,          :string
  attribute :ctype_params,   :hash,     except: [:writable]
  attribute :result_params,  :hash
  attribute :stats,          :hash,     only: [:readable, :schema]
  attribute :userdata,       :hash
  attribute :draw_at,        :datetime, except: [:writable]
  attribute :last_action_at, :datetime
  attribute :token_read,     :string,   except: [:writable]
  attribute :token_write,    :string,   except: [:writable]
  attribute :created_at,     :datetime, except: [:writable]
  attribute :updated_at,     :datetime, except: [:writable]

  attribute :has_draw,       :boolean,  only:   [:readable, :schema]
  attribute :has_started,    :boolean,  only:   [:readable, :schema]
end
