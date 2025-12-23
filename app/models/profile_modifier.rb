class ProfileModifier < ApplicationRecord
  include Api::ProfileModifier
  include RailsAdmin::ProfileModifier
  belongs_to :profile
  belongs_to :stat_modifier
end
