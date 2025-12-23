class Size < ApplicationRecord
  include Api::Size
  include RailsAdmin::Size
  has_many :fighters
  # Aggiungi questo:
  has_many :requirements, as: :required_entity, dependent: :destroy
end
