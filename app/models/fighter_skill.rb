class FighterSkill < ApplicationRecord
  include Api::FighterSkill
  include RailsAdmin::FighterSkill
  belongs_to :fighter
  belongs_to :skill
end
