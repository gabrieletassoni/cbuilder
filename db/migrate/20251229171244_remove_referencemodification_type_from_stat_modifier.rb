class RemoveReferencemodificationTypeFromStatModifier < ActiveRecord::Migration[7.2]
  def change
    remove_reference :stat_modifiers, :modification_type, null: false, foreign_key: true
  end
end
