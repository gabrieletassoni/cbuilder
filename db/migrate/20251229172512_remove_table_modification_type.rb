class RemoveTableModificationType < ActiveRecord::Migration[7.2]
  def change
    drop_table :modification_types, if_exists: true
  end
end
