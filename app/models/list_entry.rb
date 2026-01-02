class ListEntry < ApplicationRecord
  include Api::ListEntry
  include RailsAdmin::ListEntry
  belongs_to :army_list, touch: true # Aggiorna updated_at della lista quando cambia l'entry
  belongs_to :fighter

  validates :quantity, numericality: { greater_than: 0 }

  # Calcola il costo totale di questa entry (Costo Profilo * Quantità)
  # CALCOLO COSTO TOTALE
  # (Costo Profilo Base + Costo Equipaggiamento Lista) * Quantità
  def total_cost
    unit_cost = profile.total_cost + added_equipment.sum(:cost)
    unit_cost * quantity
  end

  # CALCOLO STATISTICHE FINALI (Fusion)
  # Unisce i valori del profilo con i bonus dell'equipaggiamento di lista
  def current_value(stat_code)
    # 1. Partiamo dal valore calcolato del profilo (Fighter + Affiliazione + Equip Profilo)
    base_val = profile.current_value(stat_code)

    # 2. Raccogliamo i modificatori dell'equipaggiamento specifico della lista
    # Nota: Assumiamo che l'equipaggiamento abbia StatModifiers associati (definito nello step precedente)
    list_modifiers = added_equipment.flat_map(&:stat_modifiers)

    # 3. Filtriamo per la statistica richiesta
    relevant_mods = list_modifiers.select { |m| m.stat_definition.code == stat_code }

    # 4. Applichiamo i bonus (Solo ADD/SUB, ignoriamo SET per sicurezza sui layer superiori)
    relevant_mods.select { |m| ["add", "sub"].include?(m.modification_type.code) }.each do |mod|
      val = mod.value_integer
      mod.modification_type.code == "add" ? base_val += val : base_val -= val
    end

    [base_val, 0].max
  end

  # ABILITA' ATTIVE (Merge)
  def active_skills
    profile_skills = profile.active_skills
    # Aggiunge abilità conferite dall'equipaggiamento di lista (tramite StatModifier type: grant_skill)
    list_skills = added_equipment.flat_map(&:stat_modifiers)
                                 .map(&:granted_skill)
                                 .compact

    (profile_skills + list_skills).uniq
  end

  # Delegatori per facilitare l'accesso ai dati del fighter sottostante
  delegate :fighter, to: :profile
  delegate :is_character?, :rank, :keywords, :active_skills, to: :profile
end
