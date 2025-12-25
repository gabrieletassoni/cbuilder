class CreateEquipment < ActiveRecord::Migration[7.2]
  def change
    create_table :equipment do |t|
      t.string :name
      t.text :description
      t.integer :cost

      t.timestamps
    end
  end
end
