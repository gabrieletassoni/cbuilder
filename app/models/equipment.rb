class Equipment < ApplicationRecord
  include Api::Equipment
  include RailsAdmin::Equipment
  # Relazioni N:M

  # L'equipaggiamento ha modificatori (es. "Spada: +2 FOR")
  has_many :stat_modifiers, as: :source, dependent: :destroy
  accepts_nested_attributes_for :stat_modifiers, allow_destroy: true

  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true

  # L'equipaggiamento ha requisiti (es. "Solo Guerrieri")
  has_many :requirements, as: :restrictable, dependent: :destroy

  validates :name, presence: true

  # Verifica se un fighter può equipaggiarlo (Logica riutilizzata da Artifact)
  def equipable_by?(fighter)
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
