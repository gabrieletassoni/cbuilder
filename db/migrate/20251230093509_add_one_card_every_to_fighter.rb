class AddOneCardEveryToFighter < ActiveRecord::Migration[7.2]
  def change
    add_column :fighters, :one_card_every, :integer, default: 200, null: true
    add_column :fighters, :fighters_on_every_card, :integer, default: 1, null: false
  end
end
