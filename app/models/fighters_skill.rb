class FightersSkill < ApplicationRecord
  include Api::FightersSkill
  include RailsAdmin::FightersSkill
  belongs_to :fighter
  belongs_to :skill
end
