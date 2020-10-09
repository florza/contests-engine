class JsonToJsonb < ActiveRecord::Migration[6.0]
  def change

    # Contests
    change_column         :contests, :ctype_params, :jsonb
    change_column         :contests, :stats, :jsonb
    change_column         :contests, :result_params, :jsonb
    change_column         :contests, :userdata, :jsonb

    # Participants
    change_column         :participants, :ctype_params, :jsonb
    change_column         :participants, :stats, :jsonb
    change_column         :participants, :userdata, :jsonb

    # Matches
    change_column         :matches, :ctype_params, :jsonb
    change_column         :matches, :stats, :jsonb
    change_column         :matches, :result, :jsonb
    change_column         :matches, :userdata, :jsonb

    # Users
    change_column         :users, :userdata, :jsonb
  end
end
