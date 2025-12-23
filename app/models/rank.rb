class Rank < ApplicationRecord
  include Api::Rank
  include RailsAdmin::Rank
  has_many :fighters

  has_many :requirements, as: :required_entity, dependent: :destroy
end
