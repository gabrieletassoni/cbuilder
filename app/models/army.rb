class Army < ApplicationRecord
  include Api::Army
  include RailsAdmin::Army

  belongs_to :path, optional: true # Via d'alleanza

  has_many :fighters
  has_many :affiliations
  has_many :artifacts
  has_many :miracles
  has_many :spells
  has_many :nexuses
end
