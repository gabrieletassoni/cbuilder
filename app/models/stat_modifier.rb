class StatModifier < ApplicationRecord
  include Api::StatModifier
  include RailsAdmin::StatModifier
  belongs_to :source, polymorphic: true # Affiliation, Artifact, Spell...
  belongs_to :stat_definition
  belongs_to :modification_type
  belongs_to :granted_skill, class_name: "Skill", optional: true

  has_many :requirements, as: :restrictable, dependent: :destroy

  # Controlla se questo modificatore specifico si applica al combattente
  # Es. Un'affiliazione dà +1 FOR ai Guerrieri e +1 POT ai Maghi.
  # Questo metodo controlla se sei un Guerriero.
  def applies_to?(fighter)
    return true if requirements.empty?

    requirements.all? { |req| req.met_by?(fighter) }
  end
end
