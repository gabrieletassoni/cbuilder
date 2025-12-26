class Profile < ApplicationRecord
  include Api::Profile
  include RailsAdmin::Profile
  belongs_to :fighter
  belongs_to :affiliation, optional: true

  has_many :profile_modifiers, dependent: :destroy
  has_many :stat_modifiers, through: :profile_modifiers

  # Relazione con le liste in cui è usato
  has_many :list_entries, dependent: :destroy
  has_many :army_lists, through: :list_entries

  # Equipaggiamento effettivo (può differire dal fighter base se modificato)
  has_and_belongs_to_many :equipment

  # Callback: Applica i bonus obbligatori dell'affiliazione alla creazione
  after_create :apply_mandatory_affiliation_modifiers
  # Callback: Quando creo un profilo, copio l'equipaggiamento base del Fighter
  after_create :copy_base_equipment

  # Helper per sapere se è usato
  def used_in_lists?
    list_entries.exists?
  end

  # Calcola il valore finale di una statistica
  # AGGIORNAMENTO LOGICA DI CALCOLO
  def current_value(stat_code)
    base = fighter.raw_stat(stat_code)

    # Raccogliamo TUTTI i modificatori da TUTTE le fonti
    # 1. Modificatori manuali diretti (ProfileModifier)
    # 2. Modificatori dall'Affiliazione (tramite ProfileModifier automatici)
    # 3. Modificatori dagli Artefatti (assumendo relazione :artifacts)
    # 4. Modificatori dall'Equipaggiamento (NUOVO)

    all_modifiers = stat_modifiers.to_a +
                    equipment.flat_map(&:stat_modifiers) +
                    artifacts.flat_map(&:stat_modifiers) # Se hai artifacts

    # Filtriamo quelli rilevanti per questa statistica
    relevant_mods = all_modifiers.select { |m| m.stat_definition.code == stat_code }

    # Filtriamo quelli i cui requisiti condizionali sono soddisfatti (es. "Solo se Mago")
    active_mods = relevant_mods.select { |m| m.applies_to?(fighter) }

    # Applica logica matematica (Set, Add, Sub)
    # 1. SET (Priorità)
    active_mods.select { |m| m.modification_type.code == "set" }.each do |mod|
      base = mod.value_integer
    end

    # 2. ADD/SUB
    active_mods.select { |m| ["add", "sub"].include?(m.modification_type.code) }.each do |mod|
      val = mod.value_integer
      mod.modification_type.code == "add" ? base += val : base -= val
    end

    [base, 0].max
  end

  # Helper per il costo totale
  def total_cost
    base_calc = current_value("cost")
    equip_cost = equipment.sum(:cost)
    # artifact_cost = artifacts.sum(:cost)

    base_calc + equip_cost
  end

  # Ritorna le abilità attive (quelle del fighter + quelle garantite dai modificatori)
  def active_skills
    base_skills = fighter.skills.to_a
    granted_skills = stat_modifiers.where.not(granted_skill_id: nil).map(&:granted_skill)
    (base_skills + granted_skills).uniq
  end

  private

  def apply_mandatory_affiliation_modifiers
    return unless affiliation

    # Cerca modificatori dell'affiliazione che sono obbligatori e soddisfano i requisiti del fighter
    affiliation.stat_modifiers.where(is_mandatory: true).each do |mod|
      if mod.applies_to?(fighter)
        self.profile_modifiers.create(stat_modifier: mod)
      end
    end
  end

  def copy_base_equipment
    # Copia l'equipaggiamento di default dal Fighter al Profile
    self.equipment = fighter.equipment
  end
end
