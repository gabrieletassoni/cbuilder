class RenameSizeFieldsBaseForceBaseDimensionBaseWounds < ActiveRecord::Migration[7.2]
  def change
    rename_column :sizes, :base_force, :force
    rename_column :sizes, :base_dimensions, :dimension
    rename_column :sizes, :base_wounds, :wounds
  end
end
