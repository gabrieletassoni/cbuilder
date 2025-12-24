class ListNexus < ApplicationRecord
  include Api::ListNexus
  include RailsAdmin::ListNexus
  belongs_to :army_list
  belongs_to :nexus
end
