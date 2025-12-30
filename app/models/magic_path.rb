class MagicPath < ApplicationRecord
  include Api::MagicPath
  include RailsAdmin::MagicPath
  has_many :spells, dependent: :destroy
  validates :name, presence: true, uniqueness: true
end
