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
  # ----------------------------------------------------------
  # CALCOLO STATISTICHE (Refactoring)
  # ----------------------------------------------------------
  def current_value(stat_code)
    base = fighter.raw_stat(stat_code)

    # 1. Recuperiamo tutti i modificatori attivi (metodo helper sotto)
    mods = all_active_modifiers

    # 2. Filtriamo per la statistica richiesta
    relevant_mods = mods.select { |m| m.stat_definition&.code == stat_code }

    # 3. Applica logica matematica (Set, Add, Sub)
    # Priorità ai SET (es. "Forza diventa 6")
    relevant_mods.select { |m| m.modification_type.code == "set" }.each do |mod|
      base = mod.value_integer
    end

    # Poi ADD e SUB
    relevant_mods.select { |m| ["add", "sub"].include?(m.modification_type.code) }.each do |mod|
      val = mod.value_integer
      mod.modification_type.code == "add" ? base += val : base -= val
    end

    [base, 0].max
  end

  # ----------------------------------------------------------
  # CALCOLO ABILITÀ ATTIVE (Versione Integrata)
  # ----------------------------------------------------------
  def active_skills
    # 1. Partiamo dalle abilità base del combattente
    base_skills = fighter.skills.to_a

    # 2. Recuperiamo tutti i modificatori attivi (da Equip, Solo, Affiliazione...)
    mods = all_active_modifiers

    # 3. Troviamo le abilità AGGIUNTE (grant_skill)
    granted_skills = mods.select { |m| m.modification_type.code == "grant_skill" }
                         .map(&:granted_skill)
                         .compact

    # 4. Troviamo le abilità RIMOSSE (remove_skill)
    # Esempio: Un Solo potrebbe dire "Perdi Furia Guerriera"
    removed_skill_ids = mods.select { |m| m.modification_type.code == "remove_skill" }
                            .map(&:granted_skill_id)
                            .compact

    # 5. Unione e Sottrazione
    # (Base + Garantite) - Rimosse
    all_skills = (base_skills + granted_skills).uniq
    all_skills.reject { |s| removed_skill_ids.include?(s.id) }
  end

  # Helper per il costo totale
  def total_cost
    base_calc = current_value("cost")
    equip_cost = equipment.sum(:cost)
    artifact_cost = artifacts.sum(:cost)
    solos_cost = solos.sum(:cost) # <--- NUOVO: Costo dei Solo

    base_calc + equip_cost + artifact_cost + solos_cost
  end

  private

  # ----------------------------------------------------------
  # HELPER PER RACCOGLIERE I MODIFICATORI
  # ----------------------------------------------------------
  def all_active_modifiers
    # Raccoglie i modificatori da tutte le fonti possibili
    # Usa flat_map per ottenere un array piatto di StatModifier
    potential_modifiers = stat_modifiers.to_a + # Diretti sul profilo
                          equipment.flat_map(&:stat_modifiers) + # Da Equipaggiamento
                          solos.flat_map(&:stat_modifiers) + # Da Solo
                          # artifacts.flat_map(&:stat_modifiers) +      # Da Artefatti (se usati)
                          (affiliation ? affiliation.stat_modifiers : []) # Da Affiliazione

    # Filtra solo quelli che soddisfano i requisiti del combattente
    # (es. "Bonus solo se Mago")
    potential_modifiers.select { |mod| mod.applies_to?(fighter) }
  end

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

  def solos_must_match_affiliation
    return if solos.empty?

    if affiliation.nil?
      errors.add(:solos, "non possono essere aggiunti a un profilo senza affiliazione.")
    else
      invalid_solos = solos.select { |s| s.affiliation_id != affiliation_id }
      if invalid_solos.any?
        names = invalid_solos.map(&:name).join(", ")
        errors.add(:solos, "include elementi non validi per l'affiliazione #{affiliation.name}: #{names}")
      end
    end
  end

  def solos_requirements_must_be_met
    solos.each do |solo|
      unless solo.available_for_fighter?(fighter)
        errors.add(:solos, "#{solo.name} non soddisfa i requisiti per questo combattente.")
      end
    end
  end
end
