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

  # Callback: Applica i bonus obbligatori dell'affiliazione alla creazione
  after_create :apply_mandatory_affiliation_modifiers

  # Helper per sapere se è usato
  def used_in_lists?
    list_entries.exists?
  end

  # Calcola il valore finale di una statistica
  def current_value(stat_code)
    base = fighter.raw_stat(stat_code)

    # Ottieni i modificatori applicati che impattano questa stat
    mods = stat_modifiers.includes(:modification_type, :stat_definition)
                         .where(stat_definitions: { code: stat_code })

    # 1. Applica i SET (sovrascritture)
    mods.select { |m| m.modification_type.code == "set" }.each do |mod|
      base = mod.value_integer
    end

    # 2. Applica ADD e SUB
    mods.select { |m| ["add", "sub"].include?(m.modification_type.code) }.each do |mod|
      if mod.modification_type.code == "add"
        base += mod.value_integer
      else
        base -= mod.value_integer
      end
    end

    return base < 0 ? 0 : base # Mai sotto zero
  end

  # Helper per il costo totale
  def total_cost
    current_value("cost")
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
end
