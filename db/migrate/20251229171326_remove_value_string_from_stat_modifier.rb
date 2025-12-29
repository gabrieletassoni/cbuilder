class RemoveValueStringFromStatModifier < ActiveRecord::Migration[7.2]
  def change
    remove_index :stat_modifiers, :value_string, if_exists: true
    remove_column :stat_modifiers, :value_string, :string
  end
end
