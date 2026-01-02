class AllowNullsInCost < ActiveRecord::Migration[7.2]
  def change
    change_column_null :fighters, :cost, true
  end
end
