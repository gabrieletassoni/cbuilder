class ModificationType < ApplicationRecord
  include Api::ModificationType
  include RailsAdmin::ModificationType

  validates :code, presence: true, uniqueness: true

  def title
    description rescue nil
  end
end
