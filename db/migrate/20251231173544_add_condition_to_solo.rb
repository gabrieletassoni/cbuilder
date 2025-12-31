class AddConditionToSolo < ActiveRecord::Migration[7.2]
  def change
    add_column :solos, :condition, :string
  end
end
