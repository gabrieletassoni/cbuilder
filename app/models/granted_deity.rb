class GrantedDeity < ApplicationRecord
  include Api::GrantedDeity
  include RailsAdmin::GrantedDeity

  belongs_to :worshiper, polymorphic: true
  belongs_to :deity

  def title
    deity&.name.to_s
  end
end
