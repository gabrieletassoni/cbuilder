class ChangeArmyToFighter < ActiveRecord::Migration[7.2]
  def change
    # Currently the army references has null: false, so we need to allow nulls first
    change_column_null :fighters, :army_id, true
  end
end
