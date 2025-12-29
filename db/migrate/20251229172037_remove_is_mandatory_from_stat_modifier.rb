class RemoveIsMandatoryFromStatModifier < ActiveRecord::Migration[7.2]
  def change
    remove_column :stat_modifiers, :is_mandatory, :boolean
  end
end
