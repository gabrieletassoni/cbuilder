class GrantedSkill < ApplicationRecord
  include Api::GrantedSkill
  include RailsAdmin::GrantedSkill

  belongs_to :target, polymorphic: true # Affiliation, Artifact, Spell...
  belongs_to :skill
  has_many :requirements, as: :restrictable, dependent: :destroy
  accepts_nested_attributes_for :requirements, allow_destroy: true

  def title
    "#{skill&.name.to_s}#{value ? "/#{value}" : ""}"
  end
end
