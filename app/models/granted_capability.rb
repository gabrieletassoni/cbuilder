class GrantedCapability < ApplicationRecord
  include Api::GrantedCapability
  include RailsAdmin::GrantedCapability

  belongs_to :capable, polymorphic: true
  belongs_to :capability
end
