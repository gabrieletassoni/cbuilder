class Equipment < ApplicationRecord
  include Api::Equipment
  include RailsAdmin::Equipment
  # Relazioni N:M
  has_and_belongs_to_many :fighters # Equipaggiamento base
  has_and_belongs_to_many :profiles # Equipaggiamento scelto nella lista
  has_and_belongs_to_many :list_entries # Equipaggiamento Lista (NUOVO)

  # L'equipaggiamento ha modificatori (es. "Spada: +2 FOR")
  has_many :stat_modifiers, as: :source, dependent: :destroy

  # L'equipaggiamento ha requisiti (es. "Solo Guerrieri")
  has_many :requirements, as: :restrictable, dependent: :destroy

  validates :name, presence: true

  # Verifica se un fighter può equipaggiarlo (Logica riutilizzata da Artifact)
  def equipable_by?(fighter)
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
