class Solo < ApplicationRecord
  include Api::Solo
  include RailsAdmin::Solo
  belongs_to :affiliation

  # Il Solo fornisce bonus (es. +1 AUDACIA) tramite StatModifier
  has_many :stat_modifiers, as: :source, dependent: :destroy
  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true
  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true

  validates :name, presence: true

  # Verifica se un fighter può acquisire questo Solo
  # Nota: Non controlliamo qui l'affiliazione, quella è controllata nel Profilo
  def available_for_fighter?(fighter)
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
