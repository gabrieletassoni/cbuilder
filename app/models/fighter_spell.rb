class FighterSpell < ApplicationRecord
  include Api::FighterSpell
  include RailsAdmin::FighterSpell
  belongs_to :fighter
  belongs_to :spell
end
