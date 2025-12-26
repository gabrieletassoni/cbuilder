class AddValueToSkill < ActiveRecord::Migration[7.2]
  def change
    add_column :skills, :value, :string
    add_index :skills, :value

    # Remove has_value column if it exists
    if column_exists?(:skills, :has_value)
      remove_column :skills, :has_value
    end
  end
end
