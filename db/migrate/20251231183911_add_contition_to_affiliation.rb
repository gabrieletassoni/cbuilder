class AddContitionToAffiliation < ActiveRecord::Migration[7.2]
  def change
    add_column :affiliations, :condition, :string
  end
end
