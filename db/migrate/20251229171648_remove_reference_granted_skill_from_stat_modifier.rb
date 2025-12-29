class RemoveReferenceGrantedSkillFromStatModifier < ActiveRecord::Migration[7.2]
  def change
    # The reference to remove is:
    # t.references :granted_skill, foreign_key: { to_table: :skills }
    remove_reference :stat_modifiers, :granted_skill, foreign_key: { to_table: :skills }, if_exists: true
  end
end
