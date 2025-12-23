class FightersKeyword < ApplicationRecord
  include Api::FightersKeyword
  include RailsAdmin::FightersKeyword
  belongs_to :fighter
  belongs_to :keyword
end
