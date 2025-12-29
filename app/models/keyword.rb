class Keyword < ApplicationRecord
  include Api::Keyword
  include RailsAdmin::Keyword

  # Has many fighters through the join table
  has_and_belongs_to_many :fighters

  # Il Solo fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy
  has_many :granted_skills, as: :target, dependent: :destroy

  # has_many :requirements, as: :required_entity, dependent: :destroy

  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true
  accepts_nested_attributes_for :granted_skills, allow_destroy: true
  # accepts_nested_attributes_for :requirements, allow_destroy: true
end
