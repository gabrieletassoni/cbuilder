class GrantedSkill < ApplicationRecord
  include Api::GrantedSkill
  include RailsAdmin::GrantedSkill

  belongs_to :target, polymorphic: true # Affiliation, Artifact, Spell...
  belongs_to :skill
  # has_many :requirements, as: :restrictable, dependent: :destroy
  # accepts_nested_attributes_for :requirements, allow_destroy: true

  #Validations
  validates :skill, presence: true
  # Also validate that the value is filled only if the skill requires it (skill.value != nil in the skill definition)
  validate :value_presence_if_required

  def value_presence_if_required
    if skill&.value.present? && value.blank?
      errors.add(:value, I18n.t("activerecord.errors.models.granted_skill.attributes.value.required"))
    end
  end

  def title
    "#{skill&.name.to_s}#{value ? "/#{value}" : ""}"
  end
end
