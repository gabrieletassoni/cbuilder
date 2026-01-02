class RenameBaseCostToCostInFighter < ActiveRecord::Migration[7.2]
  def change
    rename_column :fighters, :base_cost, :cost
    change_column_null :fighters, :cost, true
    # Set base_dice_pool to allow nulls and remove default
    change_column_null :fighters, :base_dice_pool, true
    change_column_default :fighters, :base_dice_pool, from: 2, to: nil
    # Do the same for the field one_card_every
    change_column_null :fighters, :one_card_every, true
    change_column_default :fighters, :one_card_every, from: 200, to: nil
    # Do the same for fighters_on_every_card
    change_column_null :fighters, :fighters_on_every_card, true
    change_column_default :fighters, :fighters_on_every_card, from: 1, to: nil
  end
end
