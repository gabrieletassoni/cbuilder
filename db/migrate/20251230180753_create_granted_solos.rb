class CreateGrantedSolos < ActiveRecord::Migration[7.2]
  def change
    create_table :granted_solos do |t|
      t.references :affiliate, polymorphic: true, null: false, index: { name: "index_granted_solos_on_affiliate" }
      t.references :solo, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
