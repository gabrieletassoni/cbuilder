def upsert_stat_modifier(skill:, stat_code:, value:)
  StatModifier.find_or_create_by!(
    source: skill,
    stat_definition: StatDefinition.find_by!(code: stat_code),
    modification_type: ModificationType.find_by!(code: value.positive? ? "bonus" : "malus"),
    value_integer: value,
  )
end

skill = Skill.find_by!(name: "Vivacity")
upsert_stat_modifier(skill: skill, stat_code: "INI", value: 1)
skill = Skill.find_by!(name: "Resilience")
upsert_stat_modifier(skill: skill, stat_code: "RES", value: 1)
skill = Skill.find_by!(name: "Fine Blade")
upsert_stat_modifier(skill: skill, stat_code: "ATT", value: 1)
skill = Skill.find_by!(name: "Speed")
upsert_stat_modifier(skill: skill, stat_code: "MOV", value: 1)
skill = Skill.find_by!(name: "Awareness")
upsert_stat_modifier(skill: skill, stat_code: "INI", value: 1)
skill = Skill.find_by!(name: "Precision")
upsert_stat_modifier(skill: skill, stat_code: "ATT", value: 1)
skill = Skill.find_by!(name: "Rough")
upsert_stat_modifier(skill: skill, stat_code: "ATT", value: -1)
skill = Skill.find_by!(name: "Vulnerable")
upsert_stat_modifier(skill: skill, stat_code: "DIF", value: -1)
