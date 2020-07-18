class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches do |t|
      t.references :contest, null: false
      t.references :participant_1, references: :participant
      t.references :participant_2, references: :participant
      t.string "status", limit: 10, default: "active", null: false
      t.json "group_params", default: {}, null: false
      t.json "ko_params", default: {}, null: false
      t.references :updated_by_user, references: :user, null: true
      t.string "updated_by_token", limit: 32, null: true
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false

      t.timestamps
    end
  end
end
