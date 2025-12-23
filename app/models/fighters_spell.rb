class FightersSpell < ApplicationRecord
  include Api::FightersSpell
  include RailsAdmin::FightersSpell
  belongs_to :fighter
  belongs_to :spell
end
