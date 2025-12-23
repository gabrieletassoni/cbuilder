class Army < ApplicationRecord
  include Api::Army
  include RailsAdmin::Army
  has_many :fighters
  has_many :affiliations
  has_many :artifacts
  # Aggiungi questo:
  has_many :requirements, as: :required_entity, dependent: :destroy
end
