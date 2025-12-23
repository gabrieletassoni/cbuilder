class FightersMiracle < ApplicationRecord
  include Api::FightersMiracle
  include RailsAdmin::FightersMiracle
  belongs_to :fighter
  belongs_to :miracle
end
