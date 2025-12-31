class AddSkillTargetToSkill < ActiveRecord::Migration[7.2]
  def change
    add_reference :skills, :skill_target, null: true, foreign_key: true
  end
end
