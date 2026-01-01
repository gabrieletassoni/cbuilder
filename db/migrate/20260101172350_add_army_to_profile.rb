class AddArmyToProfile < ActiveRecord::Migration[7.2]
  def change
    add_reference :profiles, :army, null: true, foreign_key: true
  end
end
