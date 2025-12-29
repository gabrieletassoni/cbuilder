class RenameValueIntegerToValueFromStatModifier < ActiveRecord::Migration[7.2]
  def change
    rename_column :stat_modifiers, :value_integer, :value
    # Set Type to Float
    change_column :stat_modifiers, :value, :float
  end
end
