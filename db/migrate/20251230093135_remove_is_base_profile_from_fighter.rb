class RemoveIsBaseProfileFromFighter < ActiveRecord::Migration[7.2]
  def change
    remove_column :fighters, :is_base_profile, :boolean
  end
end
