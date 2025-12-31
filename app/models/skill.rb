class Skill < ApplicationRecord
  include Api::Skill
  include RailsAdmin::Skill

  belongs_to :skill_target, optional: true
  has_and_belongs_to_many :skill_categories

  # Il Lo Skill fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy
  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true
  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true
end
