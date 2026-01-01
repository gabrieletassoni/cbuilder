class Fighter < ApplicationRecord
  include Api::Fighter
  include RailsAdmin::Fighter

  belongs_to :army, optional: true
  belongs_to :rank
  belongs_to :size
  belongs_to :affiliation, optional: true # Se è una variante specifica

  has_and_belongs_to_many :keywords

  has_many :granted_capabilities, as: :capable, dependent: :destroy
  accepts_nested_attributes_for :granted_capabilities, allow_destroy: true
  has_many :granted_equipments, as: :owner, dependent: :destroy
  accepts_nested_attributes_for :granted_equipments, allow_destroy: true
  has_many :granted_skills, as: :target, dependent: :destroy
  accepts_nested_attributes_for :granted_skills, allow_destroy: true
  has_many :granted_magic_paths, as: :mage, dependent: :destroy
  accepts_nested_attributes_for :granted_magic_paths, allow_destroy: true
  has_many :granted_deities, as: :worshiper, dependent: :destroy
  accepts_nested_attributes_for :granted_deities, allow_destroy: true

  has_many :affiliation_leaders
  has_many :led_affiliations, through: :affiliation_leaders, source: :affiliation

  validates :name, presence: true
  validates :base_cost, numericality: { greater_than_or_equal_to: 0 }
  # validate :rank_compatibility_with_stats

  # Compute the number of fighters for each card following these rules:
  # Numero di Combattenti per Carta
  # Il numero delle miniature di un profilo identico, attivate dalla stessa carta, è limitato secondo la seguente
  # regola basata sul costo. Gli artefatti e i costi addizionali come auree, Solo/X e costi di affiliazione alle liste
  # tematiche non vengono considerati per determinare il numero di combattenti rappresentati da una carta, a
  # meno di indicazioni contrarie.
  # ●​ da 0 a 30 p.a.: fino a combattenti 3 per carta;
  # ●​ da 31 a 50 p.a.: fino a 2 combattenti per carta;
  # ●​ sopra i 50 p.a.: 1 combattente per carta;
  # ●​ Leggenda Vivente non Personaggio: 1 per armata;
  # Fanno eccezione i Musici ed i Porta-Stendardo che:
  # -​ se non formano uno Stato Maggiore possono essere al massimo schierati 2 per carta o, se costano
  # più di 50 p.a., 1 per carta;
  # -​ se formano uno Stato Maggiore sono 1 per carta.
  # Una carta non deve necessariamente vedere associati ad essa il massimo di combattenti che può
  # rappresentare.
  # Before every save, apply this rule and update the fighters_on_every_card field
  before_save do
    cost = self.base_cost || 0
    if cost <= 30
      self.fighters_on_every_card = 3
    elsif cost <= 50
      self.fighters_on_every_card = 2
    else
      self.fighters_on_every_card = 1
    end
  end

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
    when "mage"
      # Un rango da Mago richiede POT > 0
      if (power || 0) <= 0
        errors.add(:rank, "di tipo Mago richiede un valore di Potere (POT) superiore a 0.")
      end
    when "faithful"
      # Un rango da Fedele richiede FEDE > 0
      total_faith = (faith_create || 0) + (faith_alter || 0) + (faith_destroy || 0)
      if total_faith <= 0
        errors.add(:rank, "di tipo Fedele richiede almeno un Aspetto della Fede.")
      end
    when "warrior"
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
