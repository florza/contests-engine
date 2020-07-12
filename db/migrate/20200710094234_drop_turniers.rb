class DropTurniers < ActiveRecord::Migration[5.2]
  def up
    drop_table :turniers
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
