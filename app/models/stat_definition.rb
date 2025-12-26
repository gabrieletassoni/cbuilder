class StatDefinition < ApplicationRecord
  include Api::StatDefinition
  include RailsAdmin::StatDefinition

  validates :code, presence: true, uniqueness: true

  def title
    label rescue nil
  end
end
