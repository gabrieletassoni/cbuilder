class Path < ApplicationRecord
  include Api::Path
  include RailsAdmin::Path
  has_many :fighters
  # Aggiungi questo:
  has_many :requirements, as: :required_entity, dependent: :destroy
end
