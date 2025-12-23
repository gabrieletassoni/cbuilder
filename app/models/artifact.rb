class Artifact < ApplicationRecord
  include Api::Artifact
  include RailsAdmin::Artifact
  has_many :stat_modifiers, as: :source, dependent: :destroy
  has_many :requirements, as: :restrictable, dependent: :destroy

  # Chi può equipaggiarlo?
  def equipable_by?(fighter)
    # Se non ci sono requisiti, è generico per tutti
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end
