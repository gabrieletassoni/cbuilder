class AbilityCategory < ApplicationRecord
  include Api::AbilityCategory
  include RailsAdmin::AbilityCategory
  has_and_belongs_to_many :skills
end
