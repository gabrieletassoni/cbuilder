class DropFightersSkill < ActiveRecord::Migration[7.2]
  def change
    drop_table :fighters_skills
  end
end
