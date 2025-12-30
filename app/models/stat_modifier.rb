class StatModifier < ApplicationRecord
  include Api::StatModifier
  include RailsAdmin::StatModifier
  belongs_to :source, polymorphic: true # Affiliation, Artifact, Spell...

  def title
    # The stat can be + or - value, so we show it accordingly
    "#{stat} #{value.positive? ? "+" : ""}#{value}"
  end

  # Controlla se questo modificatore specifico si applica al combattente
  # Es. Un'affiliazione dà +1 FOR ai Guerrieri e +1 POT ai Maghi.
  # Questo metodo controlla se sei un Guerriero.
  def applies_to?(fighter)
    return true if requirements.empty?

    requirements.all? { |req| req.met_by?(fighter) }
  end
end
