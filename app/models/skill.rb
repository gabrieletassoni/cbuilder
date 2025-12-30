class Skill < ApplicationRecord
  include Api::Skill
  include RailsAdmin::Skill

  has_and_belongs_to_many :skill_categories

  # Il Lo Skill fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy
  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true
  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true

  # Il Solo può avere requisiti (es. "Solo Rango 2" o "Solo Personaggi")
  # has_many :requirements, as: :restrictable, dependent: :destroy

  def available_for_fighter?(fighter)
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
