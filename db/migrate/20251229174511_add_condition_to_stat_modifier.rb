class AddConditionToStatModifier < ActiveRecord::Migration[7.2]
  def change
    add_column :stat_modifiers, :condition, :string
  end
end
