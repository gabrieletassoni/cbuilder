class AddConditionToArtifact < ActiveRecord::Migration[7.2]
  def change
    add_column :artifacts, :condition, :string
  end
end
