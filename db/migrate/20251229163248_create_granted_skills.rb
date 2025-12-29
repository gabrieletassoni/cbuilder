class CreateGrantedSkills < ActiveRecord::Migration[7.2]
  def change
    create_table :granted_skills do |t|
      t.references :target, polymorphic: true, null: false, index: { name: "index_granted_skills_on_target" }

      t.references :skill

      t.timestamps
    end
  end
end
