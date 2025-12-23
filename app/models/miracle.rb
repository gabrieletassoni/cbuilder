class Miracle < ApplicationRecord
  include Api::Miracle
  include RailsAdmin::Miracle
  belongs_to :deity
end
