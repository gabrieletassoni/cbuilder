class GrantedMagicPath < ApplicationRecord
  include Api::GrantedMagicPath
  include RailsAdmin::GrantedMagicPath

  belongs_to :mage, polymorphic: true
  belongs_to :magic_path

  def title
    magic_path&.name.to_s
  end
end
