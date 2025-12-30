class GrantedEquipment < ApplicationRecord
  include Api::GrantedEquipment
  include RailsAdmin::GrantedEquipment

  belongs_to :owner, polymorphic: true
  belongs_to :equipment

  def title
    equipment&.name.to_s
  end
end
