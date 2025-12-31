class Affiliation < ApplicationRecord
  include Api::Affiliation
  include RailsAdmin::Affiliation
  belongs_to :army
  has_many :affiliation_leaders, dependent: :destroy
  has_many :leaders, through: :affiliation_leaders, source: :fighter
  has_many :solos, dependent: :destroy
  # Ha requisiti? Solitamente no, l'affiliazione si sceglie,
  # ma i suoi modificatori interni hanno requisiti (es. +1 POT solo se sei Mago).
end
