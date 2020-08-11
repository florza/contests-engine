class RefactorParamFields < ActiveRecord::Migration[5.2]

  # In earlier migrations, JSON-fields where defined with
  #
  #   default: {}, null: false
  #
  # This seems not to work any more but creates a default value in schema.rb of:
  #
  #   "\"\\\"\\\\\\\"\\\\\\\\\\\\\\\"\\\..." (262141 characters long!!!)
  #
  # Therefore, the fields were defined as nullable with no default

  # By the way: The definition of all 3 fields in the three tables with
  #   default: "", null: false
  # ended in having 3 different (!!!) default definitions in schema.rb:
  # contests: ""
  # participants: "\"\\\"\\\\\\\...",  262141 characters
  # matches: "\"\\\"\\\\\\\"" (i.e. only a short subset of the above)
  # Is the generated default choosen randomly?


  def change
    add_column :contests, :ctype_params, :json

    add_column :participants, :ctype_params, :json
    remove_column :participants, :group_params, :json
    remove_column :participants, :ko_params, :json
    remove_column :participants, :group, :integer
    remove_column :participants, :grp_start, :integer
    remove_column :participants, :grp_pos, :integer
    remove_column :participants, :ko_tableau, :integer
    remove_column :participants, :ko_start, :integer
    remove_column :participants, :ko_pos, :integer

    add_column :matches, :ctype_params, :json
    remove_column :matches, :params, :json
  end

end
