class CreateGrantedCapabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :granted_capabilities do |t|
      t.references :capable, polymorphic: true, null: false, index: { name: "index_granted_capabilities_on_capable" }
      t.references :capability, null: false, foreign_key: true
      t.string :condition

      t.timestamps
    end
  end
end
