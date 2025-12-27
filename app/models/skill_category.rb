class SkillCategory < ApplicationRecord
  include Api::SkillCategory
  include RailsAdmin::SkillCategory
  has_and_belongs_to_many :skills
end
