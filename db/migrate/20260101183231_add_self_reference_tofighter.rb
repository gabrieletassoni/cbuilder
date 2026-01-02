class AddSelfReferenceTofighter < ActiveRecord::Migration[7.2]
  def change
    # The Self Reference must be called parent_id
    add_reference :fighters, :original, foreign_key: { to_table: :fighters }
  end
end
