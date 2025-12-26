class Rank < ApplicationRecord
  include Api::Rank
  include RailsAdmin::Rank
  belongs_to :rank_category
  has_many :fighters

  has_many :requirements, as: :required_entity, dependent: :destroy

  # Delegatore utile per accedere velocemente al codice categoria
  delegate :code, to: :rank_category, prefix: :category # rank.category_code

  validates :name, presence: true
  validates :value, presence: true
end
