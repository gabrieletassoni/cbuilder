class GameFormat < ApplicationRecord
  include Api::GameFormat
  include RailsAdmin::GameFormat
  has_many :army_lists

  validates :name, presence: true
  validates :max_points, numericality: { greater_than: 0 }

  # Metodo Helper: Calcola il limite punti per una categoria in base al totale lista
  def limit_points_for(category, list_total_points)
    # Di solito le % sono sul totale del formato, non della lista corrente,
    # ma in C5 spesso si riferiscono al "formato di gioco" (es. 400pt).
    base = max_points

    percentage = case category
      when :character_min then min_character_percentage
      when :character_max then max_character_percentage
      when :war_machine then max_war_machine_percentage
      when :scout then max_scouts_percentage
      when :monster then max_monster_percentage
      when :flying then max_flying_percentage
      else 0
      end

    (base * percentage / 100.0).ceil
  end

  # Helper: Calcola il numero massimo di esploratori (Regola: 1 + 2 ogni 100pt)
  def max_explorers
    1 + (2 * (max_points / 100))
  end
end
