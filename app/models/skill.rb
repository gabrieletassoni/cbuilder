class Skill < ApplicationRecord
  include Api::Skill
  include RailsAdmin::Skill

  has_and_belongs_to_many :ability_categories

  # Il Solo fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy

  # Il Solo può avere requisiti (es. "Solo Rango 2" o "Solo Personaggi")
  has_many :requirements, as: :restrictable, dependent: :destroy

  def available_for_fighter?(fighter)
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
