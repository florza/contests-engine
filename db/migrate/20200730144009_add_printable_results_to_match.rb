class AddPrintableResultsToMatch < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :result_1_vs_2, :string
    add_column :matches, :result_2_vs_1, :string
  end
end
