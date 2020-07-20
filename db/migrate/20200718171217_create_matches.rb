class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches do |t|
      t.references :contest, null: false
      t.references :participant_1, references: :participant
      t.references :participant_2, references: :participant
      t.string "status", limit: 10, default: "active", null: false
      t.string "remarks", default: "", null: false
      t.json "userdata" # additional data stored for the frontend
      t.json "params", default: {}, null: false
      t.datetime "planned_at"
      t.datetime "result_at"
      t.json "result"
      t.integer :winner_id  # participant_1 oder _2
      t.integer :looser_id  # participant_2 oder _1
      t.references :winner_next_match, references: :match
      t.boolean :winner_next_place_1  # into participant_1 or _2?
      t.references :looser_next_match, references: :match
      t.boolean :looser_next_place_1  # into participant_1 or _2?
      t.references :updated_by_user, references: :user
      t.string "updated_by_token", limit: 32

      t.timestamps
    end
  end
end
