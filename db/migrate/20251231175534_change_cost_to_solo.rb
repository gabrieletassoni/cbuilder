class ChangeCostToSolo < ActiveRecord::Migration[7.2]
  def change
    change_column :solos, :cost, :string
  end
end
