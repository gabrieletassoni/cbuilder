class FighterMiracle < ApplicationRecord
  include Api::FighterMiracle
  include RailsAdmin::FighterMiracle
  belongs_to :fighter
  belongs_to :miracle
end
