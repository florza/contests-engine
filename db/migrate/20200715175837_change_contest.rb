class ChangeContest < ActiveRecord::Migration[5.2]
  def change
    change_column_null :contests, :last_action_at, false
  end
end
