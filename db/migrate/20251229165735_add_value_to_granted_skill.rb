class AddValueToGrantedSkill < ActiveRecord::Migration[7.2]
  def change
    add_column :granted_skills, :value, :string
    add_index :granted_skills, :value
  end
end
