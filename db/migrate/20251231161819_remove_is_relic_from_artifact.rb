class RemoveIsRelicFromArtifact < ActiveRecord::Migration[7.2]
  def change
    remove_column :artifacts, :is_relic, :boolean
  end
end
