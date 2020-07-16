class ChangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :participants, :token_write, :string, limit: 32, null: false, default: ''
    add_column :participants, :group_params, :json, null: false, default: {}
    add_column :participants, :ko_params, :json, null: false, default: {}

    #remove_column :participants, :group, :integer
    #remove_column :participants, :grp_start, :integer
    #remove_column :participants, :grp_pos, :integer
    #remove_column :participants, :ko_tableau, :integer
    #remove_column :participants, :ko_start, :integer
    #remove_column :participants, :ko_pos :integer

    change_column_default :contests, :last_action_at,
                            from: "2020-07-11 10:25:20",
                            to: -> { 'CURRENT_TIMESTAMP' }
  end
end
