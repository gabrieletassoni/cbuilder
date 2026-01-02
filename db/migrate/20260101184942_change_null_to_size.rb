class ChangeNullToSize < ActiveRecord::Migration[7.2]
  def change
    # The references to size must allow nulls
    change_column_null :fighters, :size_id, true
    # Also Rank references must allow nulls
    change_column_null :fighters, :rank_id, true
  end
end
