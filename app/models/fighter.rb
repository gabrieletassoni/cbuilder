class Fighter < ApplicationRecord
  include Api::Fighter
  include RailsAdmin::Fighter

  belongs_to :army
  belongs_to :rank
  belongs_to :size
  belongs_to :affiliation, optional: true # Se è una variante specifica

  has_many :fighters_skills, dependent: :destroy
  has_many :skills, through: :fighters_skills
  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :spells
  has_and_belongs_to_many :miracles
  # Equipaggiamento di default (scritto sulla carta)
  has_and_belongs_to_many :equipment

  has_many :requirements_as_target, class_name: "Requirement", as: :required_entity, dependent: :destroy

  has_many :profiles # Le istanze create dagli utenti

  has_many :affiliation_leaders
  has_many :led_affiliations, through: :affiliation_leaders, source: :affiliation

  validates :name, presence: true
  validates :base_cost, numericality: { greater_than_or_equal_to: 0 }
  validate :rank_compatibility_with_stats

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

  private
  def rank_compatibility_with_stats
    return unless rank && rank.rank_category

    category_code = rank.rank_category.code

    case category_code
    when 'mage'
      # Un rango da Mago richiede POT > 0
      if (power || 0) <= 0
        errors.add(:rank, "di tipo Mago richiede un valore di Potere (POT) superiore a 0.")
      end

    when 'faithful'
      # Un rango da Fedele richiede FEDE > 0
      total_faith = (faith_create || 0) + (faith_alter || 0) + (faith_destroy || 0)
      if total_faith <= 0
        errors.add(:rank, "di tipo Fedele richiede almeno un Aspetto della Fede.")
      end

    when 'warrior'
      # Opzionale: Un Guerriero Puro non dovrebbe avere magia o fede?
      # Regola C5: "I Guerrieri Puri sono privi di Potere e Fede"
      has_magic = (power || 0) > 0
      has_faith = ((faith_create || 0) + (faith_alter || 0) + (faith_destroy || 0)) > 0
      
      if has_magic || has_faith
        errors.add(:rank, "di tipo Guerriero Puro non può essere assegnato a un Mistico (POT o FEDE > 0).")
      end
    end
  end
end
