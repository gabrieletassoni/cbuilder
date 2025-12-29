class RemoveTableStatDefinition < ActiveRecord::Migration[7.2]
  def change
    drop_table :stat_definitions, if_exists: true
  end
end
