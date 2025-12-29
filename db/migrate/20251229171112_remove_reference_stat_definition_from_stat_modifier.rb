class RemoveReferenceStatDefinitionFromStatModifier < ActiveRecord::Migration[7.2]
  def change
    remove_reference :stat_modifiers, :stat_definition, null: false, foreign_key: true
  end
end
