class Spell < ApplicationRecord
  include Api::Spell
  include RailsAdmin::Spell
  belongs_to :magic_path
  belongs_to :army, optional: true
end
