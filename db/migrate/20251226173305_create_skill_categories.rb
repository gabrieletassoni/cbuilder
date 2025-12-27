class CreateSkillCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :skill_categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :skill_categories, :name, unique: true
    add_index :skill_categories, :description

    create_join_table :skills, :skill_categories do |t|
      t.index [:skill_id, :skill_category_id], unique: true
    end
  end
end
