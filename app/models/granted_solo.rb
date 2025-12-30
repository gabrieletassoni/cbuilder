class GrantedSolo < ApplicationRecord
  include Api::GrantedSolo
  include RailsAdmin::GrantedSolo

  belongs_to :affiliate, polymorphic: true
  belongs_to :solo

  def title
    solo&.name.to_s
  end
end
