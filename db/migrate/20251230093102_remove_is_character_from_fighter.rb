class RemoveIsCharacterFromFighter < ActiveRecord::Migration[7.2]
  def change
    remove_column :fighters, :is_character, :boolean
  end
end
