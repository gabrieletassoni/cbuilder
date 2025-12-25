class CreateProfileEquipments < ActiveRecord::Migration[7.2]
  def change
    create_table :profile_equipments do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
