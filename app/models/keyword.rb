class Keyword < ApplicationRecord
  include Api::Keyword
  include RailsAdmin::Keyword

  # Has many fighters through the join table
  has_and_belongs_to_many :fighters

  has_many :requirements, as: :required_entity, dependent: :destroy
end
