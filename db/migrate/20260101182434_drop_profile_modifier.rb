class DropProfileModifier < ActiveRecord::Migration[7.2]
  def change
    # In list entries change the reference to profile making it point to fighter instead of profile.
    # This is because profile_modifiers are being removed and profiles will no longer exist.
    remove_reference :list_entries, :profile, foreign_key: true
    add_reference :list_entries, :fighter, null: false, foreign_key: true

    # Drop the profile_modifiers and profiles tables
    drop_table :profile_modifiers
    drop_table :profiles
  end
end
