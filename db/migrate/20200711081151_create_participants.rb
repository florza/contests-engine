class CreateParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contest, null: false, foreign_key: true
      t.string :name, limit: 50, null: false
      t.string :shortname, limit: 20, null: false
      t.text :remarks, limit: 500, null: false, default: ""
      t.string :status, limit: 10, null: false, default: :active # :active, :closed
      t.integer :group, null: false, default: 0
      t.integer :grp_start, null: false, default: 0
      t.integer :grp_pos, null: false, default: 0
      t.integer :ko_tableau, null: false, default: 0
      t.integer :ko_start, null: false, default: 0
      t.integer :ko_pos, null: false, default: 0
      t.timestamps

      t.timestamps
    end

    add_index :participants, [:contest_id, :name], unique: true
    add_index :participants, [:contest_id, :shortname], unique: true
  end
end
