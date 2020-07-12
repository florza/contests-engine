class DropTeilnehmers < ActiveRecord::Migration[5.2]
  def up
    drop_table :teilnehmers
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
