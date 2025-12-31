class RenameBonusDescriptionToDescriptionInAffiliation < ActiveRecord::Migration[7.2]
  def change
    rename_column :affiliations, :bonus_description, :description
  end
end
