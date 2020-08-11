class RefactorContesttypeFields < ActiveRecord::Migration[5.2]
  def change
    # own field for ResultParams, separated from ctype_params
    add_column :contests, :result_params, :json

    Contest.all.each do |c|
      c.result_params = { 'winning_sets' => c.nbr_sets }
      if c.contesttype_params && c.contesttype_params['points']
        c.result_params['points'] = c.contesttype_params['points']
        c.contesttype_params.delete('points')
        c.save
      end
    end

    # nbr_sets becomes an attribute in result_params
    remove_column :contests, :nbr_sets, :integer

    # contesttype(_params) becomes ctype to be shorter
    rename_column :contests, :contesttype, :ctype
    rename_column :contests, :contesttype_params, :ctype_params
    rename_column :participants, :contesttype_params, :ctype_params
    rename_column :matches, :contesttype_params, :ctype_params

    # json-field userdata in all tables, not only Matches
    add_column :users, :userdata, :json
    add_column :contests, :userdata, :json
    add_column :participants, :userdata, :json
  end
end
