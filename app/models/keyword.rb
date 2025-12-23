class Keyword < ApplicationRecord
  include Api::Keyword
  include RailsAdmin::Keyword

  # Has many fighters through the join table
  has_many :fighters_keywords, dependent: :destroy
  has_many :fighters, through: :fighters_keywords

  has_many :requirements, as: :required_entity, dependent: :destroy
end
