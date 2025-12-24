class CreateArmyBuilderCore < ActiveRecord::Migration[7.0]
  def change
    # --- FORMATI DI GIOCO ---
    create_table :game_formats do |t|
      t.string :name, null: false
      t.integer :min_points, default: 0
      t.integer :max_points, null: false
      t.integer :min_models, default: 0
      # Percentuali (es. 50 per 50%)
      t.integer :min_character_percentage, default: 0
      t.integer :max_character_percentage, default: 50
      t.integer :max_war_machine_percentage, default: 30
      t.integer :max_monster_percentage, default: 30
      t.integer :max_flying_percentage, default: 65
      t.integer :max_scouts_percentage, default: 75
      t.integer :max_scouts_number, default: 9
      t.integer :max_duplicate_profiles, default: 1 # Regola 1 ogni 200pt
      t.timestamps
    end
    add_index :game_formats, :name, unique: true

    # --- LISTE D'ARMATA ---
    create_table :army_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :army, null: false, foreign_key: true
      t.references :game_format, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :published, default: false
      t.integer :total_points_cache, default: 0 # Cache per performance
      t.timestamps
    end
    # Indice per trovare velocemente le liste pubbliche o quelle di un utente
    add_index :army_lists, [:user_id, :published]
    # add_index :army_lists, :army_id

    # --- AGGIORNAMENTO PROFILI (Blueprint) ---
    # Assumendo che la tabella 'profiles' esista dagli step precedenti
    # Rimuoviamo la dipendenza dalla lista e aggiungiamo l'utente
    # unless column_exists?(:profiles, :user_id)
    #   add_reference :profiles, :user, foreign_key: true
    # end
    # if column_exists?(:profiles, :army_list_id)
    #   remove_column :profiles, :army_list_id
    # end

    # --- ENTRIES DELLA LISTA (JOIN TABLE PROFILI) ---
    create_table :list_entries do |t|
      t.references :army_list, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.timestamps
    end
    # Un profilo non dovrebbe apparire due volte nella stessa lista (aumentare la quantità invece)
    add_index :list_entries, [:army_list_id, :profile_id], unique: true

    # --- ENTRIES NEXUS (JOIN TABLE NEXUS) ---
    create_table :list_nexuses do |t|
      t.references :army_list, null: false, foreign_key: true
      t.references :nexus, null: false, foreign_key: { to_table: :nexuses }
      t.integer :quantity, default: 1
      t.timestamps
    end
    add_index :list_nexuses, [:army_list_id, :nexus_id], unique: true
  end
end
