class CreateAbilityCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :ability_categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :ability_categories, :name, unique: true
    add_index :ability_categories, :description

    create_join_table :skills, :ability_categories do |t|
      t.index [:skill_id, :ability_category_id], unique: true
    end
  end
end
