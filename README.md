Ecco la documentazione tecnica unificata in inglese, strutturata come un `README.md` professionale per una Ruby Gem che incapsula la business logic del sistema (es. `confrontation_builder_core`).

Questa documentazione fonde i concetti dei tre file (Core, Equipment, Army List) in un'unica architettura coerente.

---

# Confrontation Builder Core (Gem)

This Gem encapsulates the business logic, database schema, and calculation engines for the *Confrontation* miniature game profile manager. It handles static entity definitions (Fighters, Equipment), dynamic instance creation (Profiles), stat calculations via a modifier engine, and army list validation.

## 1. Architecture Overview

The system is divided into three logical layers:

1. **The Catalog (Static Data):** Immutable rules defining Armies, Fighters, Ranks, Equipment, and base stats.
2. **The Engine (Dynamic Calculation):** A polymorphic system of `StatModifiers` and `Requirements` that alters stats dynamically based on context (Affiliations, Spells, Items).
3. **The Roster (User Data):** User-created instances (`Profile`) and roster organizations (`ArmyList`) validated against specific `GameFormats`.

---

## 2. Core Modules & Models

### A. The Catalog: Entities

These models represent the "Rulebook" data.

* **`Army`**: The top-level faction (e.g., "Griffin", "Wolfen").
* **`Fighter`**: The template for a miniature. Contains base stats (Movement, Attack, Strength, etc.) and `base_cost`.
* **`Rank` / `Size` / `Path**`: Categorization traits used for requirements (e.g., "Infantry", "Large", "Path of Darkness").
* **`Equipment`**: Mundane items (Weapons, Armor) that can be equipped by multiple fighters.
* **`Artifact`**: Unique magical items with specific costs and strict requirements.

### B. The Modification Engine

The core logic relies on `StatModifier` to calculate values dynamically without altering database records.

#### `StatModifier`

Polymorphic model representing a mathematical operation on a stat.

* **`source`**: The object providing the bonus (Affiliation, Artifact, Equipment, Spell).
* **`stat_definition`**: The target stat (e.g., `STR`, `COST`, `ATT`).
* **`modification_type`**: The operation:
* `SET`: Overrides the base value.
* `ADD` / `SUB`: Modifies the base value.


* **`value_integer`**: The numeric value of the modifier.
* **`condition`**: Textual description of conditional logic (e.g., "On Charge").

#### `Requirement`

Polymorphic model acting as a gatekeeper for interactions (equipping items, learning spells).

* **`restrictable`**: The object being restricted (e.g., an Artifact).
* **`check_type`**:
* `entity`: Checks against association (e.g., "Must be Wolfen").
* `stat`: Checks against numeric values (e.g., "STR > 4").



---

## 3. The Profile System (Instances)

The **`Profile`** model represents a specific instance of a `Fighter` customized by a user. It is the bridge between the static Catalog and the dynamic Roster.

### Logic Flow: `current_value(stat_code)`

The `Profile` calculates its final statistics in real-time by aggregating modifiers from all sources:

1. **Base Retrieval**: Fetches the raw value from the underlying `Fighter`.
2. **Collection**: Gathers `StatModifiers` from:
* **Affiliation**: Automatic modifiers based on faction sub-groups.
* **Equipment**: Weapons and armor assigned to the profile.
* **Artifacts**: Magic items assigned to the profile.
* **Manual**: Direct `ProfileModifiers` applied by the user.


3. **Filtration**:
* Checks `applies_to?(fighter)` on each modifier to ensure requirements are met.


4. **Calculation Order**:
* Apply `SET` modifiers first.
* Apply `ADD` and `SUB` modifiers subsequently.


5. **Output**: Returns the final integer (clamped to 0).

```ruby
# Example Usage
profile = Profile.create(fighter: griffin_spearman, affiliation: lodge_of_hod)
profile.equipment << heavy_shield # Adds +1 DEF modifier
profile.current_value('defence')  # Returns Base DEF + 1

```

---

## 4. Army List & Validation

The `ArmyList` model aggregates `Profiles` into a play-ready force, strictly validated against a `GameFormat`.

### `GameFormat` (Ruleset)

Defines the constraints for a tournament or game mode:

* `max_points`: Point limit (e.g., 400).
* `max_flying_percentage`: Max % of points spent on flyers.
* `max_duplicate_profiles`: Limit on identical cards.

### `ArmyList` (Composition)

* **`ListEntry`**: Join model linking `Profile` to `ArmyList` with a `quantity`.
* **`ListNexus`**: Join model for terrain/objectives elements.

### Validation Logic

The system enforces rules via custom validators in `ArmyList`:

1. **Points Check**: `total_points <= GameFormat.max_points`.
2. **Composition Check**: Calculates percentages dynamically (e.g., Characters, War Machines) and compares them against `GameFormat` limits.
3. **Unique Limitations**: Enforces "1 per army" or "max duplicates" rules based on the underlying Fighter ID.

---

## 5. Consolidated Database Schema

Below is the unified schema required to support the entire system, including Equipment management and Army Lists.

```ruby
ActiveRecord::Schema.define(version: 2023_01_01_000000) do

  # --- LOOKUPS & DICTIONARIES ---
  create_table "armies", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
  end

  create_table "ranks", force: :cascade do |t|
    t.string "name", null: false; t.integer "value"
  end

  create_table "stat_definitions", force: :cascade do |t|
    t.string "code", null: false; t.string "label" # e.g., 'STR', 'MOV'
  end

  create_table "modification_types", force: :cascade do |t|
    t.string "code", null: false # 'add', 'set', 'sub'
  end

  # --- CORE ENTITIES ---
  create_table "fighters", force: :cascade do |t|
    t.string "name", null: false
    t.references "army", null: false
    t.references "rank", null: false
    t.references "size", null: false
    t.integer "base_cost", default: 0
    # Physical Stats
    t.integer "initiative"; t.integer "attack"; t.integer "strength"
    t.integer "defence"; t.integer "resilience"; t.integer "aim"
    t.integer "wounds"
    t.timestamps
  end

  # --- EQUIPMENT & ITEMS ---
  create_table "equipment", force: :cascade do |t|
    t.string "name", null: false
    t.integer "cost", default: 0
    t.string "category" # Weapon, Armor, Item
  end
  
  # Join table for "Default Equipment" on a Fighter
  create_join_table :fighters, :equipment do |t|
    t.index [:fighter_id, :equipment_id]
  end

  create_table "artifacts", force: :cascade do |t|
    t.string "name", null: false
    t.integer "cost", default: 0
    t.boolean "is_relic", default: false
  end

  # --- ENGINE: MODIFIERS & REQUIREMENTS ---
  create_table "requirements", force: :cascade do |t|
    t.references "restrictable", polymorphic: true # Who has this requirement?
    t.references "required_entity", polymorphic: true, optional: true
    t.string "check_type" # 'stat' or 'entity'
    t.string "stat_code"
    t.integer "min_value"
    t.integer "max_value"
  end

  create_table "stat_modifiers", force: :cascade do |t|
    t.references "source", polymorphic: true # Equipment, Affiliation, Artifact
    t.references "stat_definition"
    t.references "modification_type"
    t.integer "value_integer"
    t.boolean "is_mandatory", default: false
    t.string "condition"
  end

  # --- USER DATA: PROFILES ---
  create_table "profiles", force: :cascade do |t|
    t.references "user", null: false
    t.references "fighter", null: false
    t.references "affiliation"
    t.string "custom_name"
    t.timestamps
  end

  # Join table for "Chosen Equipment" on a Profile
  create_join_table :profiles, :equipment

  create_table "profile_modifiers", force: :cascade do |t|
    t.references "profile", null: false
    t.references "stat_modifier", null: false
  end

  # --- USER DATA: ARMY LISTS ---
  create_table "game_formats", force: :cascade do |t|
    t.string "name"
    t.integer "max_points"
    t.integer "max_character_percentage"
    t.integer "max_duplicate_profiles"
  end

  create_table "army_lists", force: :cascade do |t|
    t.references "user", null: false
    t.references "game_format", null: false
    t.references "army", null: false
    t.string "name"
    t.integer "total_points_cache", default: 0
    t.boolean "published", default: false
    t.timestamps
  end

  create_table "list_entries", force: :cascade do |t|
    t.references "army_list", null: false
    t.references "profile", null: false
    t.integer "quantity", default: 1
  end
end

```

---

## 6. Key Model Implementation Details

### Profile: The Calculation Hub

```ruby
class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :fighter
  belongs_to :affiliation, optional: true
  
  has_many :profile_modifiers, dependent: :destroy
  has_many :stat_modifiers, through: :profile_modifiers
  has_and_belongs_to_many :equipment

  after_create :copy_base_equipment

  def current_value(stat_code)
    # 1. Start with Base Stat
    base = fighter.raw_stat(stat_code)
    
    # 2. Aggregating Modifiers from all sources
    # Note: Includes Affiliation, Equipment, Artifacts, and manual ProfileModifiers
    sources = stat_modifiers.to_a + equipment.flat_map(&:stat_modifiers)
    
    relevant_mods = sources.select do |m| 
      m.stat_definition.code == stat_code && m.applies_to?(fighter)
    end

    # 3. Apply 'SET' modifiers (Priority)
    relevant_mods.select { |m| m.modification_type.code == 'set' }.each do |mod|
      base = mod.value_integer
    end

    # 4. Apply 'ADD'/'SUB' modifiers
    relevant_mods.select { |m| ['add', 'sub'].include?(m.modification_type.code) }.each do |mod|
      val = mod.value_integer
      mod.modification_type.code == 'add' ? base += val : base -= val
    end

    [base, 0].max
  end

  def total_cost
    base_calc = current_value('cost')
    equip_cost = equipment.sum(:cost)
    base_calc + equip_cost
  end

  private

  def copy_base_equipment
    self.equipment = fighter.equipment
  end
end

```

### ArmyList: Validations

```ruby
class ArmyList < ApplicationRecord
  belongs_to :game_format
  has_many :list_entries
  
  validate :validate_points_limit
  validate :validate_composition_rules

  def calculate_total_points
    list_entries.sum(&:total_cost)
  end

  private

  def validate_points_limit
    if calculate_total_points > game_format.max_points
      errors.add(:base, "Total points exceed the format limit.")
    end
  end

  def validate_composition_rules
    # Example: Character Percentage Limit
    total_pts = calculate_total_points
    char_pts = list_entries.select(&:is_character?).sum(&:total_cost)
    
    limit = (game_format.max_points * game_format.max_character_percentage / 100.0)
    
    if char_pts > limit
      errors.add(:base, "Character points limit exceeded.")
    end
    
    # Further validations (War Machines, Duplicates) follow similar patterns...
  end
end

```
