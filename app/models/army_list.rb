class ArmyList < ApplicationRecord
  include Api::ArmyList
  include RailsAdmin::ArmyList
  belongs_to :user
  belongs_to :army
  belongs_to :game_format

  has_many :list_entries, dependent: :destroy
  has_many :fighters, through: :list_entries

  has_many :list_nexuses, dependent: :destroy
  has_many :nexuses, through: :list_nexuses

  # Callback per aggiornare la cache dei punti
  # before_save :update_points_cache

  # Validazioni Standard
  validates :name, presence: true

  # Validazioni Regolamento (Custom)
  validate :validate_points_limit
  validate :validate_model_count
  validate :validate_composition_rules

  # Scopes
  scope :published, -> { where(published: true) }
  scope :by_user, ->(user) { where(user: user) }

  # Metodo Pubblico: Calcolo Punti in tempo reale
  def calculate_total_points
    entries_cost = list_entries.sum(&:total_cost)
    nexus_cost = list_nexuses.sum { |ln| ln.nexus.cost * ln.quantity }
    entries_cost + nexus_cost
  end

  # Metodo Pubblico: Verifica validità completa
  def legal?
    valid?
  end

  private

  def update_points_cache
    self.total_points_cache = calculate_total_points
  end

  # --- VALIDAZIONI DELLE REGOLE ---

  def validate_points_limit
    if total_points_cache > game_format.max_points
      errors.add(:base, "Punti totali (#{total_points_cache}) eccedono il limite del formato (#{game_format.max_points}).")
    end
  end

  def validate_model_count
    # Somma delle quantità di tutte le entries
    total_models = list_entries.sum(:quantity)
    if total_models < game_format.min_models
      errors.add(:base, "Numero di modelli (#{total_models}) inferiore al minimo richiesto (#{game_format.min_models}).")
    end
  end

  def validate_composition_rules
    # Recuperiamo tutte le entries caricate in memoria per performance
    entries = list_entries.includes(profile: [:fighter, :stat_modifiers])

    # 1. Personaggi (Min/Max %)
    char_points = entries.select(&:is_character?).sum(&:total_cost)
    min_char = game_format.limit_points_for(:character_min, total_points_cache)
    max_char = game_format.limit_points_for(:character_max, total_points_cache)

    errors.add(:base, "Punti Personaggi insufficienti.") if char_points < min_char
    errors.add(:base, "Punti Personaggi eccessivi.") if char_points > max_char

    # 2. Macchine da Guerra
    wm_points = entries.select { |e| e.fighter.rank.name == "Macchina da Guerra" }.sum(&:total_cost)
    max_wm = game_format.limit_points_for(:war_machine, total_points_cache)
    errors.add(:base, "Punti Macchine da Guerra eccessivi.") if wm_points > max_wm

    # 3. Volo
    # Verifica l'abilità attiva 'Volo' sul profilo
    fly_points = entries.select { |e| e.active_skills.any? { |s| s.name == "Volo" } }.sum(&:total_cost)
    max_fly = game_format.limit_points_for(:flying, total_points_cache)
    errors.add(:base, "Punti Volanti eccessivi.") if fly_points > max_fly

    # 4. Esploratori (Numero e Punti)
    explorers = entries.select { |e| e.active_skills.any? { |s| s.name == "Esploratore" } }
    explorers_count = explorers.sum(&:quantity)

    if explorers_count > game_format.max_explorers
      errors.add(:base, "Troppi modelli Esploratori (#{explorers_count}). Max: #{game_format.max_explorers}.")
    end

    # 5. Duplicati per Profilo (Regola carte uguali)
    # Raggruppa per ID del profilo base (fighter_id)
    entries.group_by { |e| e.profile.fighter_id }.each do |fighter_id, grouped_entries|
      # In C5 il limite è solitamente sulle CARTE (entries), non sui modelli totali (quantity).
      # Se ho 2 carte di Arcieri (totale 6 modelli), conta come 2 carte.
      cards_count = grouped_entries.size
      if cards_count > game_format.max_duplicate_profiles
        fighter_name = grouped_entries.first.profile.fighter.name
        errors.add(:base, "Troppe carte per l'unità #{fighter_name} (Max: #{game_format.max_duplicate_profiles}).")
      end
    end
  end
end
