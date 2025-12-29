class RemoveConditionFromStatModifier < ActiveRecord::Migration[7.2]
  def change
    remove_column :stat_modifiers, :condition, :string
  end
end
