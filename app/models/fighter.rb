class Fighter < ApplicationRecord
  include Api::Fighter
  include RailsAdmin::Fighter

  belongs_to :army, optional: true
  belongs_to :rank, optional: true
  belongs_to :size, optional: true
  belongs_to :affiliation, optional: true # Se è una variante specifica
  belongs_to :original, class_name: "Fighter", optional: true # Per le varianti specifiche

  has_and_belongs_to_many :keywords

  # Le liste in cui è incluso questo combattente
  has_many :list_entries, dependent: :destroy
  has_many :army_lists, through: :list_entries
  # The Self join original must have an has_many variants association
  has_many :variants, class_name: "Fighter", foreign_key: "original_id", dependent: :nullify

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
  # validates :cost, numericality: true
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
  # before_save do
  #   cost = self.base_cost || 0
  #   if cost <= 30
  #     self.fighters_on_every_card = 3
  #   elsif cost <= 50
  #     self.fighters_on_every_card = 2
  #   else
  #     self.fighters_on_every_card = 1
  #   end
  # end

  def display_name
    # If it is the original, just return the name + army + affiliation if presents, otherwise return name + army + affiliation and the granted things which make it unique
    # E.g. "Warrior of Light (Variant with Sword and Shield)"
    if original.nil?
      name_parts = [name]
      name_parts << army.name if army
      name_parts << affiliation.name if affiliation
      name_parts.join(" - ")
    else
      variant_parts = []
      variant_parts = granted_skills.map(&:skill).map(&:name) unless granted_skills.empty?
      "#{original.name} (#{variant_parts.join(", ")})"
    end
  end

  # Section for computed stats, skills, equipments, etc.
  # --------------------------------------------------------------
  # Compute the actual values taking into account stat_modifiers, granted equipments, granted_capabilities, granted_skills, granted_solos coming from keywords, armies, affiliations, skills, equipments, capabilities and artifacts both of this variant instance or the chain of variants up to the original one.
  # The skills, equipments, capabilities, solos are merged (union) from all the sources.
  # The stats are computed by starting from the base value and applying all the modifiers.
  # stat_modfiers are like:
  # Id	Value	Stat	Condition
  # 1	1	wounds	 -
  # 2	1	discipline	 -
  # 3	1	courage	 -
  # 4	1	discipline	keyword:13
  # 5	1	courage	keyword:14
  # 6	1	cost	 -
  # 7	-(rank+1)	cost	size:2 and (skill:23 or skill:6)
  # 8	=(nil)	one_card_every	 -
  # 9	-1	cost	 -
  # 10	-1	cost	 -
  # Also from the granted_ things can come a cost modification, which is also applied to the fighter cost (keep in mind that the cost is string in order to allow complex expressions).
  def total_cost
    # Costs coming from actual record
    base = cost || 0
    equipment_cost = granted_equipments.sum do |ge|
      ge.cost.to_i || 0
    end
    # Costs coming from granted capabilities
    capability_cost = granted_capabilities.sum do |gc|
      gc.cost.to_i || 0
    end
    # Costs coming from granted skills
    skill_cost = granted_skills.sum do |gs|
      gs.cost.to_i || 0
    end
    # Costs coming from granted solos
    solo_cost = granted_solos.sum do |gs|
      gs.cost.to_i || 0
    end
    
    base + capability_cost + skill_cost + solo_cost + equipment_cost
  end

  # CALCOLO STATISTICHE FINALI (Fusion)
  # Unisce i valori base con i bonus di affiliazione ed equipaggiamento profilo
  def current_value(stat_code)
    # 1. Partiamo dal valore base del combattente
    base_val = raw_stat(stat_code)

    # 2. Aggiungiamo i modificatori dell'affiliazione (se presente)
    if affiliation
      affiliation_mods = affiliation.stat_modifiers.where(stat_definition: StatDefinition.find_by(code: stat_code))
      affiliation_mods.select { |m| ["add", "sub"].include?(m.modification_type.code) }.each do |mod|
        val = mod.value_integer
        mod.modification_type.code == "add" ? base_val += val : base_val -= val
      end
    end

    # 3. Aggiungiamo i modificatori dell'equipaggiamento di profilo
    profile_modifiers = granted_equipments.flat_map(&:stat_modifiers)
    relevant_mods = profile_modifiers.select { |m| m.stat_definition.code == stat_code }
    relevant_mods.select { |m| ["add", "sub"].include?(m.modification_type.code) }.each do |mod|
      val = mod.value_integer
      mod.modification_type.code == "add" ? base_val += val : base_val -= val
    end

    [base_val, 0].max
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
