class FighterKeyword < ApplicationRecord
  include Api::FighterKeyword
  include RailsAdmin::FighterKeyword
  belongs_to :fighter
  belongs_to :keyword
end
