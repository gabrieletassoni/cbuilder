class Requirement < ApplicationRecord
  include Api::Requirement
  include RailsAdmin::Requirement
  belongs_to :restrictable, polymorphic: true
  belongs_to :required_entity, polymorphic: true, optional: true # Es. punta a un Keyword specifico

  # Verifica se il fighter soddisfa questo requisito
  def met_by?(fighter)
    if check_type == "stat"
      check_stat_requirement(fighter)
    else
      check_entity_requirement(fighter)
    end
  end

  private

  def check_entity_requirement(fighter)
    case required_entity_type
    when "Keyword"
      fighter.keywords.include?(required_entity)
    when "Rank"
      # Esempio: Richiede rango >= Veterano (valore 2)
      # Nota: qui semplifico uguaglianza diretta per chiarezza,
      # ma potresti implementare logica >= basata sui valori dei rank
      fighter.rank == required_entity
    when "Path"
      fighter.path == required_entity
    when "Army"
      fighter.army == required_entity
    when "Fighter"
      # Riservato a personaggio specifico (es. Kassar)
      fighter == required_entity
    else
      false
    end
  end

  def check_stat_requirement(fighter)
    val = fighter.raw_stat(stat_code)
    return false if min_value && val < min_value
    return false if max_value && val > max_value
    true
  end
end
