Here is the unified, coherent document. The code remains in Rails/Ruby, but all descriptions, comments, and logic explanations have been translated into English to create a professional technical specification. The "fix" for the polymorphic associations has been integrated directly into the model definitions to ensure the code is bug-free from the start.

---

# Confrontation Builder - Playable Profile Management System

This document outlines how to implement a flexible system for managing playable profiles in a miniatures game like *Confrontation*, using Ruby on Rails. The system allows for the definition of fighter templates and playable instances (profiles), featuring a modifier engine based on dynamic requirements.

---

## PART 1: Terminal Commands

Copy and paste these commands into your Rails project terminal. These generators create the necessary Models and Migrations.

```bash
# 1. Lookup Tables (Dictionaries)
rails g model Army name:string description:text
rails g model Rank name:string value:integer
rails g model Size name:string base_wounds:integer base_power:integer base_dimensions:string
rails g model Path name:string description:text
rails g model Keyword name:string description:text
rails g model StatDefinition code:string label:string description:text
rails g model ModificationType code:string symbol:string description:text
rails g model MagicPath name:string element:string
rails g model Deity name:string

# 2. Core Entities
rails g model Affiliation name:string army:references bonus_description:text
rails g model Fighter name:string title:string army:references affiliation:references rank:references size:references path:references base_cost:integer is_character:boolean is_unique:boolean movement_ground:float movement_fly:float initiative:integer attack:integer strength:integer defence:integer resilience:integer aim:integer courage:integer fear:integer discipline:integer power:integer faith_create:integer faith_alter:integer faith_destroy:integer

# 3. Join Tables and Keywords
rails g migration CreateFightersKeywords fighter:references keyword:references

# 4. Equipment and Mysticism
rails g model Skill name:string description:text has_value:boolean
rails g model FighterSkill fighter:references skill:references value:integer
rails g model Spell name:string magic_path:references difficulty:string cost_string:string range:string duration:string effect:text
rails g model Miracle name:string deity:references aspects:string fervor:string difficulty:string range:string duration:string effect:text
rails g model Artifact name:string description:text cost:integer is_relic:boolean
rails g model Nexus name:string resistance:integer structure:integer cost:integer effect:text army:references

# Join Tables for Mysticism
rails g migration CreateFightersSpells fighter:references spell:references
rails g migration CreateFightersMiracles fighter:references miracle:references

# 5. Modification Engine and Requirements (Polymorphic)
rails g model Requirement restrictable:references{polymorphic} required_entity:references{polymorphic} check_type:string min_value:integer max_value:integer
rails g model StatModifier source:references{polymorphic} stat_definition:references modification_type:references value_integer:integer value_string:string granted_skill:references is_mandatory:boolean condition:string

# 6. The Playable Profile (The Instance)
rails g model Profile fighter:references affiliation:references custom_name:string
rails g model ProfileModifier profile:references stat_modifier:references

```

---

## PART 2: Optimized Database Schema

Replace the content of the files created in `db/migrate` with this consolidated code to ensure correct indices and constraints.

```ruby
# db/migrate/20230101000000_setup_confrontation_schema.rb

class SetupConfrontationSchema < ActiveRecord::Migration[7.0]
  def change
    # --- LOOKUP TABLES ---
    create_table :armies do |t|
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :armies, :name, unique: true

    create_table :ranks do |t|
      t.string :name, null: false
      t.integer :value, default: 1
      t.timestamps
    end
    add_index :ranks, :name, unique: true

    create_table :sizes do |t|
      t.string :name, null: false
      t.integer :base_wounds, default: 1
      t.integer :base_power, default: 1
      t.string :base_dimensions
      t.timestamps
    end
    
    create_table :paths do |t|
      t.string :name, null: false; t.text :description; t.timestamps
    end

    create_table :keywords do |t|
      t.string :name, null: false; t.text :description; t.timestamps
    end
    add_index :keywords, :name, unique: true

    # Fundamental for dynamic calculation
    create_table :stat_definitions do |t|
      t.string :code, null: false  # e.g.: 'strength', 'attack'
      t.string :label; t.text :description; t.timestamps
    end
    add_index :stat_definitions, :code, unique: true

    create_table :modification_types do |t|
      t.string :code, null: false # e.g.: 'add', 'set', 'grant_skill'
      t.string :symbol; t.text :description; t.timestamps
    end
    add_index :modification_types, :code, unique: true

    # --- CORE ENTITIES ---
    create_table :affiliations do |t|
      t.string :name, null: false
      t.references :army, null: false, foreign_key: true
      t.text :bonus_description
      t.timestamps
    end
    add_index :affiliations, [:army_id, :name] # Fast lookup per army

    create_table :fighters do |t|
      t.string :name, null: false
      t.string :title
      t.references :army, null: false, foreign_key: true
      t.references :affiliation, foreign_key: true # Nullable (base profiles)
      t.references :rank, null: false, foreign_key: true
      t.references :size, null: false, foreign_key: true
      t.references :path, foreign_key: true
      
      t.integer :base_cost, default: 0
      t.boolean :is_character, default: false
      t.boolean :is_base_profile, default: true
      
      # Stats (Nullable because not all entities have all stats, e.g., machines have no DIS)
      t.float :movement_ground; t.float :movement_fly
      t.integer :initiative; t.integer :attack; t.integer :strength; t.integer :defence; t.integer :resilience
      t.integer :aim; t.integer :courage; t.integer :fear; t.integer :discipline
      t.integer :power
      t.integer :faith_create; t.integer :faith_alter; t.integer :faith_destroy

      t.timestamps
    end
    add_index :fighters, :name
    add_index :fighters, [:army_id, :is_character]

    create_table :fighters_keywords, id: false do |t|
      t.references :fighter, null: false, foreign_key: true
      t.references :keyword, null: false, foreign_key: true
    end
    add_index :fighters_keywords, [:fighter_id, :keyword_id], unique: true

    # --- SKILLS & MAGIC ---
    create_table :skills do |t|
      t.string :name, null: false; t.text :description; t.boolean :has_value, default: false; t.timestamps
    end

    create_table :fighter_skills do |t|
      t.references :fighter, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :value # The "X" of the skill
      t.timestamps
    end

    create_table :magic_paths do |t|
      t.string :name; t.string :element; t.timestamps
    end
    create_table :deities do |t|
      t.string :name; t.timestamps
    end

    create_table :spells do |t|
      t.string :name, null: false
      t.references :magic_path, foreign_key: true
      t.string :difficulty; t.string :cost_string; t.string :range; t.string :duration; t.text :effect
      t.timestamps
    end

    create_table :miracles do |t|
      t.string :name, null: false
      t.references :deity, foreign_key: true
      t.string :aspects; t.string :fervor; t.string :difficulty; t.string :range; t.string :duration; t.text :effect
      t.timestamps
    end
    
    # Join tables for "What this fighter knows by default"
    create_join_table :fighters, :spells do |t|
      t.index [:fighter_id, :spell_id]
    end
    create_join_table :fighters, :miracles do |t|
      t.index [:fighter_id, :miracle_id]
    end

    # --- ARTIFACTS & NEXUS ---
    create_table :artifacts do |t|
      t.string :name, null: false
      t.text :description
      t.integer :cost, default: 0
      t.boolean :is_relic, default: false
      t.timestamps
    end

    create_table :nexus do |t|
      t.string :name, null: false
      t.integer :resistance; t.integer :structure; t.integer :cost
      t.text :effect
      t.references :army, foreign_key: true
      t.timestamps
    end

    # --- REQUIREMENTS ENGINE (Polymorphic) ---
    create_table :requirements do |t|
      t.references :restrictable, polymorphic: true, null: false, index: { name: 'index_requirements_on_restrictable' }
      t.references :required_entity, polymorphic: true # E.g., points to an Army, Keyword, Path
      t.string :check_type, null: false # 'entity' or 'stat'
      t.integer :min_value # For stat checks (e.g. STR > 5)
      t.integer :max_value
      t.string :stat_code # If check_type is 'stat', which stat do we check?
      t.timestamps
    end

    # --- MODIFIER ENGINE (Polymorphic) ---
    create_table :stat_modifiers do |t|
      # Who provides the bonus? (Affiliation, Artifact, Skill...)
      t.references :source, polymorphic: true, null: false, index: { name: 'index_stat_modifiers_on_source' }
      
      t.references :stat_definition, foreign_key: true # What gets modified
      t.references :modification_type, null: false, foreign_key: true # How it is modified
      
      t.integer :value_integer
      t.string :value_string # For special cases
      
      t.references :granted_skill, foreign_key: { to_table: :skills } # If it grants a skill
      t.boolean :is_mandatory, default: false # If true, applies automatically (e.g. affiliation bonus)
      t.string :condition # Text description of the condition (e.g. "While charging")
      
      t.timestamps
    end

    # --- PLAYABLE PROFILES (INSTANCES) ---
    create_table :profiles do |t|
      t.references :fighter, null: false, foreign_key: true
      t.references :affiliation, foreign_key: true # The chosen affiliation for the roster
      t.string :custom_name
      t.timestamps
    end

    create_table :profile_modifiers do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :stat_modifier, null: false, foreign_key: true
      t.timestamps
    end
    # Prevent applying the same modifier twice to the same profile
    add_index :profile_modifiers, [:profile_id, :stat_modifier_id], unique: true, name: 'idx_uniq_prof_mod'
  end
end

```

---

## PART 3: ActiveRecord Models

This section contains the application logic, including the necessary fixes for polymorphic associations to prevent "invalid association" errors.

### 1. The Template: `Fighter.rb`

```ruby
class Fighter < ApplicationRecord
  belongs_to :army
  belongs_to :rank
  belongs_to :size
  belongs_to :path, optional: true # Path of Alliance
  belongs_to :affiliation, optional: true # If it is a specific variant
  
  has_many :fighter_skills, dependent: :destroy
  has_many :skills, through: :fighter_skills
  has_and_belongs_to_many :keywords
  
  has_and_belongs_to_many :spells
  has_and_belongs_to_many :miracles
  
  has_many :profiles # Instances created by users

  # Allow specific artifacts to target specific fighters (e.g., "Kassar only")
  has_many :requirements_as_target, class_name: 'Requirement', as: :required_entity, dependent: :destroy

  validates :name, presence: true
  validates :base_cost, numericality: { greater_than_or_equal_to: 0 }

  # Utility method to read raw values from DB
  def raw_stat(code)
    # Maps StatDefinition codes to real columns
    column = case code
             when 'cost' then :base_cost
             when 'mov' then :movement_ground
             when 'for' then :strength
             else code.to_sym
             end
    self.send(column) || 0
  end
end

```

### 2. The Instance: `Profile.rb` (The Brain)

This model calculates final values by summing the base stats and modifiers.

```ruby
class Profile < ApplicationRecord
  belongs_to :fighter
  belongs_to :affiliation, optional: true
  
  has_many :profile_modifiers, dependent: :destroy
  has_many :stat_modifiers, through: :profile_modifiers

  # Callback: Applies mandatory affiliation modifiers upon creation
  after_create :apply_mandatory_affiliation_modifiers

  # Calculates the final value of a statistic
  def current_value(stat_code)
    base = fighter.raw_stat(stat_code)
    
    # Get applied modifiers impacting this stat
    mods = stat_modifiers.includes(:modification_type, :stat_definition)
                         .where(stat_definitions: { code: stat_code })
    
    # 1. Apply SET (overwrites)
    mods.select { |m| m.modification_type.code == 'set' }.each do |mod|
      base = mod.value_integer
    end

    # 2. Apply ADD and SUB
    mods.select { |m| ['add', 'sub'].include?(m.modification_type.code) }.each do |mod|
      if mod.modification_type.code == 'add'
        base += mod.value_integer
      else
        base -= mod.value_integer
      end
    end

    return base < 0 ? 0 : base # Never below zero
  end

  # Helper for total cost
  def total_cost
    current_value('cost')
  end

  # Returns active skills (base fighter skills + those granted by modifiers)
  def active_skills
    base_skills = fighter.skills.to_a
    granted_skills = stat_modifiers.where.not(granted_skill_id: nil).map(&:granted_skill)
    (base_skills + granted_skills).uniq
  end

  private

  def apply_mandatory_affiliation_modifiers
    return unless affiliation
    
    # Search for mandatory affiliation modifiers that meet the fighter's requirements
    affiliation.stat_modifiers.where(is_mandatory: true).each do |mod|
      if mod.applies_to?(fighter)
        self.profile_modifiers.create(stat_modifier: mod)
      end
    end
  end
end

```

### 3. The Modifier: `StatModifier.rb`

Manages conditional logic.

```ruby
class StatModifier < ApplicationRecord
  belongs_to :source, polymorphic: true # Affiliation, Artifact, Spell...
  belongs_to :stat_definition
  belongs_to :modification_type
  belongs_to :granted_skill, class_name: 'Skill', optional: true
  
  has_many :requirements, as: :restrictable, dependent: :destroy

  # Checks if this specific modifier applies to the fighter
  # E.g. An affiliation gives +1 STR to Warriors and +1 POW to Mages.
  # This method checks if you are a Warrior.
  def applies_to?(fighter)
    return true if requirements.empty?
    
    requirements.all? { |req| req.met_by?(fighter) }
  end
end

```

### 4. The Validator: `Requirement.rb`

The heart of the system's flexibility. **Note:** `optional: true` is included here to prevent Rails association errors when requirements are purely stat-based (numeric) rather than entity-based.

```ruby
class Requirement < ApplicationRecord
  belongs_to :restrictable, polymorphic: true
  
  # IMPORTANT: optional: true allows requirements that are just numeric checks (e.g. Strength > 5)
  belongs_to :required_entity, polymorphic: true, optional: true

  # Verifies if the fighter meets this requirement
  def met_by?(fighter)
    if check_type == 'stat'
      check_stat_requirement(fighter)
    else
      check_entity_requirement(fighter)
    end
  end

  private

  def check_entity_requirement(fighter)
    case required_entity_type
    when 'Keyword'
      fighter.keywords.include?(required_entity)
    when 'Rank'
      # E.g.: Requires rank >= Veteran (value 2)
      # Simplified direct equality here for clarity, but logic >= can be implemented
      fighter.rank == required_entity
    when 'Path'
      fighter.path == required_entity
    when 'Army'
      fighter.army == required_entity
    when 'Fighter'
      # Reserved for specific characters (e.g. Kassar)
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

```

### 5. Equipables: `Artifact.rb`

Artifacts also use requirements to check purchasing eligibility.

```ruby
class Artifact < ApplicationRecord
  has_many :stat_modifiers, as: :source, dependent: :destroy
  has_many :requirements, as: :restrictable, dependent: :destroy

  # Who can equip this?
  def equipable_by?(fighter)
    # If no requirements, it is generic for everyone
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end

```

### 6. Grouping Entity: `Affiliation.rb`

```ruby
class Affiliation < ApplicationRecord
  belongs_to :army
  has_many :stat_modifiers, as: :source, dependent: :destroy
  # Usually has no requirements itself (the affiliation is chosen), 
  # but its internal modifiers have requirements (e.g. +1 POW only if you are a Mage).
end

```

---

## PART 4: Polymorphic Interface Setup

To ensure `Requirement` works correctly with `required_entity` (Polymorphic), the target models must define the inverse relationship. Update the following models to include the interface.

**`app/models/keyword.rb`**

```ruby
class Keyword < ApplicationRecord
  has_and_belongs_to_many :fighters
  has_many :requirements, as: :required_entity, dependent: :destroy
end

```

**`app/models/rank.rb`**

```ruby
class Rank < ApplicationRecord
  has_many :fighters
  has_many :requirements, as: :required_entity, dependent: :destroy
end

```

**`app/models/path.rb`**

```ruby
class Path < ApplicationRecord
  has_many :fighters
  has_many :requirements, as: :required_entity, dependent: :destroy
end

```

**`app/models/army.rb`**

```ruby
class Army < ApplicationRecord
  has_many :fighters
  has_many :affiliations
  has_many :artifacts
  has_many :requirements, as: :required_entity, dependent: :destroy
end

```

**`app/models/size.rb`**

```ruby
class Size < ApplicationRecord
  has_many :fighters
  has_many :requirements, as: :required_entity, dependent: :destroy
end

```

---

## PART 5: Example Workflow

This architecture satisfies all requirements: no hardcoded enums, non-destructive dynamic calculation, granular conditional bonuses, and high performance.

1. **Seed**: Import CSV data into the database.
2. **Scenario**: Create a profile for the fighter "Kassar".
3. **Affiliation**: Assign the affiliation "The Eclipse".
4. **Callback**: Rails detects that "The Eclipse" has a mandatory modifier (e.g., *Scourge*) and checks if it applies to Kassar. If yes, it creates a `ProfileModifier`.
5. **User Action**: The user adds the "Obsidian Dagger".
* System checks: `Artifact.find_by(name: 'Obsidian...').equipable_by?(kassar_fighter)`.
* The artifact requirement states: `required_entity: Kassar`.
* Check passes. The artifact is added.
* The artifact has a `StatModifier` ("Grants Assassin"). A `ProfileModifier` is created.


6. **View**: In the frontend view, you display `profile.current_value('attack')` and `profile.active_skills`.
