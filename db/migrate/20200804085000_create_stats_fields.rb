class CreateStatsFields < ActiveRecord::Migration[5.2]

  def change
    add_column :contests, :stats, :json
    add_column :participants, :stats, :json
    add_column :matches, :stats, :json
  end

end
