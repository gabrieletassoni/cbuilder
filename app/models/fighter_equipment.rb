class FighterEquipment < ApplicationRecord
  include Api::FighterEquipment
  include RailsAdmin::FighterEquipment
  belongs_to :fighter
  belongs_to :equipment
end
