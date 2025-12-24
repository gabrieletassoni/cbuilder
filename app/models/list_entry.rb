class ListEntry < ApplicationRecord
  include Api::ListEntry
  include RailsAdmin::ListEntry
  belongs_to :army_list, touch: true # Aggiorna updated_at della lista quando cambia l'entry
  belongs_to :profile

  validates :quantity, numericality: { greater_than: 0 }

  # Calcola il costo totale di questa entry (Costo Profilo * Quantità)
  def total_cost
    profile.total_cost * quantity
  end

  # Delegatori per facilitare l'accesso ai dati del fighter sottostante
  delegate :fighter, to: :profile
  delegate :is_character?, :rank, :keywords, :active_skills, to: :profile
end
