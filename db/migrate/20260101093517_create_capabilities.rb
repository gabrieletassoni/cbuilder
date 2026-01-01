class CreateCapabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :capabilities do |t|
      t.string :name
      t.references :army, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
    add_index :capabilities, :name
    add_index :capabilities, :description
  end
end
