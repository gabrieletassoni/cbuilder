# frozen_string_literal: true
# db/seeds/skills.rb
#
# NOTE:
# - This file contains the 19 fully generated skills with complete descriptions.
# - All remaining skills are included as explicit stubs with TODO descriptions,
#   preserving idempotency and category/value mappings.
# - Replace TODO blocks with finalized literal translations as needed.

PASSIVE = SkillCategory.find_by!(name: "passive")
ACTIVE  = SkillCategory.find_by!(name: "active")
STAR    = SkillCategory.find_by!(name: "*")

def upsert_skill(name:, description:, categories:, value: nil)
  skill = Skill.find_or_initialize_by(name: name)
  skill.description = description.strip
  skill.value = value
  skill.skill_categories = categories
  skill.save!
end

# ==== FULLY GENERATED (19) ====

upsert_skill(
  name: "Abominable",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    When a fighter must perform a Courage (COR) test against an Abominable opponent,
    or against a group containing at least one Abominable fighter, the test is rolled
    using 2d6 and only the lowest natural result is kept.

    If the fighter benefits from an effect allowing multiple dice and keeping the
    highest result, the two effects cancel out and the test is rolled normally.

    This ability has no effect if the Abominable fighter has a COR value, but applies
    if they gain a Fear (PAU) value, for example through War Cry.
  DESC
)

upsert_skill(
  name: "Relentless",
  categories: [PASSIVE],
  description: <<~DESC
    When a Relentless fighter is Killed, they are removed from the battlefield only
    at the end of the current phase.

    Until then they are considered Critically Wounded, cannot pursue, cannot be healed
    or sacrificed, and do not count for mission objectives.

    An army may include no more than 5 Relentless fighters per 200 points and no more
    than 75% of its total cost may consist of Relentless fighters.
  DESC
)

upsert_skill(
  name: "Hardened",
  categories: [PASSIVE],
  description: <<~DESC
    A Hardened fighter ignores the first negative modifier affecting any test they
    must perform during each combat.
  DESC
)

upsert_skill(
  name: "Alliance",
  value: "X",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    A fighter with this ability may ally with People X or Alliance X.
    They are considered a friendly fighter for all game purposes.
  DESC
)

upsert_skill(
  name: "Beloved by the Gods",
  categories: [PASSIVE],
  description: <<~DESC
    Once per game round, the fighter may reroll one failed test.
    The second result must be kept.
  DESC
)

upsert_skill(
  name: "Ambidextrous",
  categories: [PASSIVE],
  description: <<~DESC
    When an Ambidextrous fighter successfully defends, they gain one additional attack
    die that may be used in the same combat.

    If the attacker rolls an automatic failure, the defender may either keep the
    defense die or convert it into an additional attack die.
  DESC
)

upsert_skill(
  name: "Target",
  value: "X",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    Attacks targeting this fighter suffer a penalty of X to their attack rolls.
  DESC
)

upsert_skill(
  name: "Brutal",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    When this fighter inflicts damage, any successful hit inflicts one additional wound.
  DESC
)

upsert_skill(
  name: "Bestial Charge",
  categories: [PASSIVE],
  description: <<~DESC
    When charging, this fighter gains +1 Strength (STR) for the duration of the combat.
  DESC
)

upsert_skill(
  name: "Colossal",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    This fighter ignores penalties caused by terrain and may move over obstacles
    as if they were not present.
  DESC
)

upsert_skill(
  name: "Master Strike",
  value: "X",
  categories: [ACTIVE],
  description: <<~DESC
    When attacking, this fighter may convert up to X attack dice into automatic successes.
  DESC
)

upsert_skill(
  name: "Command",
  value: "X",
  categories: [ACTIVE, STAR],
  description: <<~DESC
    At the beginning of the round, this fighter may grant X allied fighters within range
    a bonus die for their next test.
  DESC
)

upsert_skill(
  name: "Mutagenic",
  value: "X",
  categories: [ACTIVE],
  description: <<~DESC
    Mutagenic/X grants temporary bonuses to characteristics.

    At the beginning of each turn, before the Tactics roll, gain one Mutagenic die for
    every full or partial 100 army points of allied fighters with this ability still in play.

    Each die is immediately assigned to a fighter with Mutagenic/X.
    A fighter may receive only one Mutagenic die per turn unless otherwise specified.

    Roll the die and add X to the natural result to obtain bonus points.
    A natural 1 is an automatic failure.

    Bonus points may increase MOV, INI, ATT, STR, DIF, and RES.
    Bonuses last until the end of the turn.
  DESC
)

upsert_skill(
  name: "Strike Sequence",
  value: "X",
  categories: [ACTIVE],
  description: <<~DESC
    After resolving an attack, this fighter may immediately perform X additional attacks
    against the same target.
  DESC
)

upsert_skill(
  name: "Savage",
  value: "X",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    When this fighter charges, they gain X additional attack dice for the combat.
  DESC
)

upsert_skill(
  name: "Swordsman",
  categories: [ACTIVE],
  description: <<~DESC
    Once per combat, this fighter may reroll one failed attack roll.
  DESC
)

upsert_skill(
  name: "Flight",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    A flying fighter may move over terrain and other fighters without penalty and
    cannot be engaged except by flying opponents.
  DESC
)

upsert_skill(
  name: "Vulnerable",
  categories: [PASSIVE, STAR],
  description: <<~DESC
    Attacks against this fighter gain one additional attack die.
  DESC
)

upsert_skill(
  name: "Vivacity",
  categories: [PASSIVE],
  description: <<~DESC
    This fighter gains +1 Initiative (INI).
  DESC
)

# ==== STUBS FOR REMAINING SKILLS (TODO DESCRIPTIONS) ====

STUBS = [
  ["Hardened", PASSIVE, nil],
  ["Awareness", PASSIVE, nil],
  ["Precision", PASSIVE, nil],
  ["Speed", ACTIVE, nil],
  ["Resilience", PASSIVE, nil],
  ["Rough", PASSIVE, nil],
  ["Scout", PASSIVE, nil],
  ["Focus", PASSIVE, nil],
  ["Fortune", ACTIVE, nil],
  ["War Cry", PASSIVE, "X"],
  ["Rallying Cry", ACTIVE, nil],
  ["Warrior-Mage", PASSIVE, nil],
  ["Healing", ACTIVE, "X"],
  ["Iconoclast", PASSIVE, nil],
  ["Enlightened", PASSIVE, nil],
  ["Aquatic", PASSIVE, nil],
  ["Immortal", PASSIVE, "X"],
  ["Immunity", PASSIVE, "X"],
  ["Relentless Pursuit", ACTIVE, "X"],
  ["Infiltration", PASSIVE, "X"],
  ["Unfazed", PASSIVE, "X"],
  ["Unyielding", PASSIVE, nil],
  ["Survival Instinct", PASSIVE, nil],
  ["Mercenary", PASSIVE, nil],
  ["Aim", ACTIVE, nil],
  ["Warrior-Monk", PASSIVE, nil],
  ["Parry", PASSIVE, nil],
  ["Pariah", PASSIVE, nil],
  ["Predictable", PASSIVE, nil],
  ["Recovery", PASSIVE, "X"],
  ["Resolve", ACTIVE, "X"],
  ["Selenite", PASSIVE, nil],
  ["Outcast", PASSIVE, nil],
  ["Spirit of X", PASSIVE, "X"],
  ["Strategist", PASSIVE, nil],
  ["Thaumaturge", PASSIVE, nil],
  ["Sharpshooter", PASSIVE, nil],
  ["Assault Shot", ACTIVE, nil],
  ["Born Killer", PASSIVE, nil]
]

STUBS.each do |name, cat, value|
  upsert_skill(
    name: name,
    value: value,
    categories: [cat].compact,
    description: <<~DESC
      TODO: Literal description to be filled from Abilities.pdf.
    DESC
  )
end
