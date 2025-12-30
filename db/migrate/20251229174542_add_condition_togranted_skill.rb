class AddConditionTograntedSkill < ActiveRecord::Migration[7.2]
  def change
    add_column :granted_skills, :condition, :string
  end
end
