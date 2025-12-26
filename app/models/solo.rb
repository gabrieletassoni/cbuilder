class Solo < ApplicationRecord
  include Api::Solo
  include RailsAdmin::Solo
  belongs_to :affiliation

  # Relazione N:M con i Profili
  has_and_belongs_to_many :profiles

  # Il Solo fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy

  # Il Solo può avere requisiti (es. "Solo Rango 2" o "Solo Personaggi")
  has_many :requirements, as: :restrictable, dependent: :destroy

  validates :name, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }

  # Verifica se un fighter può acquisire questo Solo
  # Nota: Non controlliamo qui l'affiliazione, quella è controllata nel Profilo
  def available_for_fighter?(fighter)
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
