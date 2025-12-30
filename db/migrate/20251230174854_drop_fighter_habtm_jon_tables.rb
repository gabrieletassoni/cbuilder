class DropFighterHabtmJonTables < ActiveRecord::Migration[7.2]
  def change
    drop_join_table :fighters, :spells
    drop_join_table :fighters, :miracles
    drop_join_table :fighters, :keywords
    drop_join_table :fighters, :equipment
    drop_join_table :list_entries, :equipment
    drop_join_table :profiles, :solos
  end
end
