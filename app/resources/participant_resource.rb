class ParticipantResource < ApplicationResource
  belongs_to :contest

  after_attributes do |participant|
    participant.user_id ||= context.current_contest.user_id
    participant.contest_id ||= context.current_contest.id
  end

  # attribute :user_id,                 :integer_id,  except: [:writable]
  attribute :contest_id,              :integer_id,  only: [:filterable]
  # attribute :status,                  :string
  attribute :name,                    :string
  attribute :shortname,               :string
  attribute :remarks,                 :string
  attribute :seed_position,           :integer,     except: [:writable]
  attribute :name_seed_position,      :string,      only: [:readable, :schema]
  attribute :shortname_seed_position, :string,      only: [:readable, :schema]
  attribute :userdata,                :hash
  attribute :ctype_params,            :hash,        only: [:readable, :schema]
  attribute :stats,                   :hash,        only: [:readable, :schema]
  attribute :token_write,             :string,      except: [:writable]
  attribute :created_at,              :datetime,    except: [:writable]
  attribute :updated_at,              :datetime,    except: [:writable]
end
