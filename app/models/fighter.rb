class Fighter < ApplicationRecord
  include Api::Fighter
  include RailsAdmin::Fighter

  belongs_to :army
  belongs_to :rank
  belongs_to :size
  belongs_to :path, optional: true # Via d'alleanza
  belongs_to :affiliation, optional: true # Se è una variante specifica

  has_many :fighter_skills, dependent: :destroy
  has_many :skills, through: :fighter_skills
  has_and_belongs_to_many :keywords

  has_and_belongs_to_many :spells
  has_and_belongs_to_many :miracles

  has_many :requirements_as_target, class_name: "Requirement", as: :required_entity, dependent: :destroy

  has_many :profiles # Le istanze create dagli utenti

  validates :name, presence: true
  validates :base_cost, numericality: { greater_than_or_equal_to: 0 }

  # Metodo di utilità per leggere il valore raw dal DB
  def raw_stat(code)
    # Mappa i codici di StatDefinition alle colonne reali
    column = case code
      when "cost" then :base_cost
      when "mov" then :movement_ground
      when "for" then :strength
      else code.to_sym
      end
    self.send(column) || 0
  end
end
