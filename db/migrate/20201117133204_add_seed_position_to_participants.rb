class AddSeedPositionToParticipants < ActiveRecord::Migration[6.0]
  def change
    add_column :participants, :seed_position, :integer
  end
end
