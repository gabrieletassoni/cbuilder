class AddCostAndRemoveToGrantedModels < ActiveRecord::Migration[7.2]
  def change
    add_column :granted_capabilities, :cost, :string
    add_column :granted_capabilities, :remove, :boolean, default: false

    add_column :granted_equipments, :cost, :string
    add_column :granted_equipments, :remove, :boolean, default: false

    add_column :granted_skills, :cost, :string
    add_column :granted_skills, :remove, :boolean, default: false

    add_column :granted_magic_paths, :cost, :string
    add_column :granted_magic_paths, :remove, :boolean, default: false

    add_column :granted_deities, :cost, :string
    add_column :granted_deities, :remove, :boolean, default: false

    add_column :granted_solos, :cost, :string
    add_column :granted_solos, :remove, :boolean, default: false
  end
end
