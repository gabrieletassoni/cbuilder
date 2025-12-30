class CreateGrantedDeities < ActiveRecord::Migration[7.2]
  def change
    create_table :granted_deities do |t|
      t.references :worshiper, polymorphic: true, null: false, index: { name: "index_granted_deities_on_worshiper" }
      t.references :deity, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
