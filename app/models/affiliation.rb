class Affiliation < ApplicationRecord
  include Api::Affiliation
  include RailsAdmin::Affiliation
  belongs_to :army
  has_many :affiliation_leaders, dependent: :destroy
  has_many :leaders, through: :affiliation_leaders, source: :fighter
  has_many :solos, dependent: :destroy
  # Il Lo Skill fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy
  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true
  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true
end
