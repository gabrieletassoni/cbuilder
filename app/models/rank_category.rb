class RankCategory < ApplicationRecord
  include Api::RankCategory
  include RailsAdmin::RankCategory
  has_many :ranks, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
