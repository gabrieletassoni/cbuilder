class CreateGrantedMagicPaths < ActiveRecord::Migration[7.2]
  def change
    create_table :granted_magic_paths do |t|
      t.references :mage, polymorphic: true, null: false, index: { name: "index_granted_magic_paths_on_mage" }
      t.references :magic_path, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
