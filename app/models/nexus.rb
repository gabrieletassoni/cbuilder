class Nexus < ApplicationRecord
  include Api::Nexus
  include RailsAdmin::Nexus
  belongs_to :army
end
