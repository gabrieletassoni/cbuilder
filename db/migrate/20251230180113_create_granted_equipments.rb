class CreateGrantedEquipments < ActiveRecord::Migration[7.2]
  def change
    create_table :granted_equipments do |t|
      t.references :owner, polymorphic: true, null: false, index: { name: "index_granted_equipments_on_owner" }
      t.references :equipment, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
