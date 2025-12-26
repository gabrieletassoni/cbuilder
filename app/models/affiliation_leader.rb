class AffiliationLeader < ApplicationRecord
  belongs_to :affiliation
  belongs_to :fighter

  # Qui sta la magia: questa entità può essere la FONTE di modificatori
  has_many :stat_modifiers, as: :source, dependent: :destroy
end
