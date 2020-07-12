class CreateContests < ActiveRecord::Migration[5.2]
  def change
    create_table :contests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, limit: 50, null: false, unique: true
      t.string :shortname, limit: 20, null: false, unique: true
      t.text :description, limit: 500, null: false, default: ""
      t.string :status, limit: 50, null: false, default: :active # :active, :closed
      t.string :contesttype, limit: 50, null: false
      t.integer :nbr_sets, null: false, default: 1
      t.boolean :public, null: false, default: false
      t.string :token_read, limit: 32, null: false
      t.string :token_write, limit: 32, null: false
      t.datetime :last_action_at, null: false, default: DateTime.now
      t.datetime :draw_at
      t.timestamps
    end
  end
end
