class ProfileEquipment < ApplicationRecord
  include Api::ProfileEquipment
  include RailsAdmin::ProfileEquipment
  belongs_to :profile
  belongs_to :equipment
end
