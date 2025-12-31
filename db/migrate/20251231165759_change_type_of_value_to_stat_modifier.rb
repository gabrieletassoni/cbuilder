class ChangeTypeOfValueToStatModifier < ActiveRecord::Migration[7.2]
  def change
    change_column :stat_modifiers, :value, :string
  end
end
