class SetupInitialSchema < ActiveRecord::Migration[7.2]
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
    add_index :sizes, :name, unique: true

    create_table :paths do |t|
      t.string :name, null: false; t.text :description; t.timestamps
    end
    add_index :paths, :name, unique: true

    create_table :keywords do |t|
      t.string :name, null: false; t.text :description; t.timestamps
    end
    add_index :keywords, :name, unique: true

    # Fondamentale per il calcolo dinamico
    create_table :stat_definitions do |t|
      t.string :code, null: false  # es: 'strength', 'attack'
      t.string :label; t.text :description; t.timestamps
    end
    add_index :stat_definitions, :code, unique: true

    create_table :modification_types do |t|
      t.string :code, null: false # es: 'add', 'set', 'grant_skill'
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
    add_index :affiliations, [:army_id, :name] # Ricerca veloce per armata

    create_table :fighters do |t|
      t.string :name, null: false
      t.string :title
      t.references :army, null: false, foreign_key: true
      t.references :affiliation, foreign_key: true # Nullable (profili base)
      t.references :rank, null: false, foreign_key: true
      t.references :size, null: false, foreign_key: true
      t.references :path, foreign_key: true

      t.integer :base_cost, default: 0
      t.boolean :is_character, default: false
      t.boolean :is_base_profile, default: true

      # Stats (Nullable perché non tutti hanno tutto, es: macchine no DIS)
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
    add_index :skills, :name, unique: true

    create_table :fighter_skills do |t|
      t.references :fighter, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :value # La "X" dell'abilità
      t.timestamps
    end

    create_table :magic_paths do |t|
      t.string :name; t.string :element; t.timestamps
    end
    add_index :magic_paths, :name, unique: true

    create_table :deities do |t|
      t.string :name; t.timestamps
    end
    add_index :deities, :name, unique: true

    create_table :spells do |t|
      t.string :name, null: false
      t.references :magic_path, foreign_key: true
      t.string :difficulty; t.string :cost_string; t.string :range; t.string :duration; t.text :effect
      t.timestamps
    end
    add_index :spells, :name, unique: true

    create_table :miracles do |t|
      t.string :name, null: false
      t.references :deity, foreign_key: true
      t.string :aspects; t.string :fervor; t.string :difficulty; t.string :range; t.string :duration; t.text :effect
      t.timestamps
    end
    add_index :miracles, :name, unique: true

    # Tabelle unione per "Cosa sa lanciare di base questo guerriero"
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
    add_index :artifacts, :name, unique: true

    create_table :nexuses do |t|
      t.string :name, null: false
      t.integer :resistance; t.integer :structure; t.integer :cost
      t.text :effect
      t.references :army, foreign_key: true
      t.timestamps
    end
    add_index :nexuses, :name, unique: true

    # --- ENGINE DEI REQUISITI (Polimorfico) ---
    create_table :requirements do |t|
      t.references :restrictable, polymorphic: true, null: false, index: { name: "index_requirements_on_restrictable" }
      t.references :required_entity, polymorphic: true # Es. punta a un Army, Keyword, Path
      t.string :check_type, null: false # 'entity' o 'stat'
      t.integer :min_value # Per controlli stat (es. FOR > 5)
      t.integer :max_value
      t.string :stat_code # Se check_type è 'stat', quale stat controlliamo?
      t.timestamps
    end

    # --- ENGINE DEI MODIFICATORI (Polimorfico) ---
    create_table :stat_modifiers do |t|
      # Chi fornisce il bonus? (Affiliazione, Artefatto, Skill...)
      t.references :source, polymorphic: true, null: false, index: { name: "index_stat_modifiers_on_source" }

      t.references :stat_definition, foreign_key: true # Cosa modifico
      t.references :modification_type, null: false, foreign_key: true # Come modifico

      t.integer :value_integer
      t.string :value_string # Per casi speciali

      t.references :granted_skill, foreign_key: { to_table: :skills } # Se garantisce abilità
      t.boolean :is_mandatory, default: false # Se true, si applica auto (es. bonus affiliazione)
      t.string :condition # Descrizione testuale della condizione (es. "In carica")

      t.timestamps
    end

    # --- PROFILI GIOCABILI (ISTANZE) ---
    create_table :profiles do |t|
      t.references :fighter, null: false, foreign_key: true
      t.references :affiliation, foreign_key: true # L'affiliazione scelta per la lista
      t.string :custom_name
      t.timestamps
    end

    create_table :profile_modifiers do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :stat_modifier, null: false, foreign_key: true
      t.timestamps
    end
    # Evita di applicare lo stesso modificatore due volte allo stesso profilo
    add_index :profile_modifiers, [:profile_id, :stat_modifier_id], unique: true, name: "idx_uniq_prof_mod"
  end
end
