class AddBaseDicePoolToFighter < ActiveRecord::Migration[7.2]
  def change
    add_column :fighters, :base_dice_pool, :integer, default: 2, null: false
  end
end
