class CreateSkillTargets < ActiveRecord::Migration[7.2]
  def change
    create_table :skill_targets do |t|
      t.string :name

      t.timestamps
    end
    add_index :skill_targets, :name, unique: true
  end
end
