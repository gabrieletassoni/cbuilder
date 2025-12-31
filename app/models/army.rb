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

  # Il Lo Skill fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy
  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true
  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true
end
