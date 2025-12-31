class SkillTarget < ApplicationRecord
  include Api::SkillTarget
  include RailsAdmin::SkillTarget

  has_many :skills, dependent: :nullify
end
