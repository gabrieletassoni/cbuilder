class AddStatToStatModifier < ActiveRecord::Migration[7.2]
  def change
    add_column :stat_modifiers, :stat, :string
    add_index :stat_modifiers, :stat
  end
end
