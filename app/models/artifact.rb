class Artifact < ApplicationRecord
  include Api::Artifact
  include RailsAdmin::Artifact
  # Il Solo fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy
  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true
  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true

  # Chi può equipaggiarlo?
  def equipable_by?(fighter)
    # Se non ci sono requisiti, è generico per tutti
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
