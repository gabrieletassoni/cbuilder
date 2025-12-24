# Espansione del Costruttore di Liste d'Armata
### 1. Nuova Struttura Logica

1. **`GameFormat`**: Contiene le regole di validazione (es. "400 Punti", "Max 1 Esploratore").
2. **`Profile` (Blueprint)**: La tua configurazione salvata (es. Fighter + Artefatti specifici). Appartiene all'Utente. È riutilizzabile.
3. **`ArmyList` (Contenitore)**: La lista specifica per una partita.
4. **`ListEntry` (Join Table)**: Collega un `Profile` a una `ArmyList`. Qui definiamo la **quantità** di quel profilo nella lista specifica.
5. **`ListNexus`**: Collega i Nexus alla lista.

---

### 2. Comandi di Generazione (Aggiornati)

Esegui questi comandi per creare le nuove entità e le tabelle di unione con gli indici appropriati.

```bash
# 1. Il Formato di Gioco (Regole)
rails g model GameFormat name:string:index min_points:integer max_points:integer min_models:integer min_character_percentage:integer max_character_percentage:integer max_war_machine_percentage:integer max_monster_percentage:integer max_flying_percentage:integer max_duplicate_profiles:integer

# 2. La Lista d'Armata (Contenitore)
rails g model ArmyList name:string description:text user:references army:references game_format:references published:boolean:index total_points_cache:integer

# 4. Tabella di Unione (Entry nella Lista)
rails g model ListEntry army_list:references profile:references quantity:integer

# 5. Tabella di Unione per i Nexus
rails g model ListNexus army_list:references nexus:references quantity:integer

```

---

### 3. Migrazioni Ottimizzate (Schema)

Ecco il codice per le migrazioni, con **indici compositi** per garantire velocità nelle query complesse e integrità dei dati.

```ruby
# db/migrate/[TIMESTAMP]_create_army_builder_core.rb

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
    add_index :army_lists, :army_id

    # --- AGGIORNAMENTO PROFILI (Blueprint) ---
    # Assumendo che la tabella 'profiles' esista dai step precedenti
    # Rimuoviamo la dipendenza dalla lista e aggiungiamo l'utente
    unless column_exists?(:profiles, :user_id)
      add_reference :profiles, :user, foreign_key: true
    end
    if column_exists?(:profiles, :army_list_id)
      remove_column :profiles, :army_list_id
    end

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

```

---

### 4. Modelli ActiveRecord Completi

Ecco i modelli con tutta la logica di validazione richiesta dal manuale.

#### `app/models/user.rb`

```ruby
class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associazioni
  has_many :profiles, dependent: :destroy   # La "Caserma" dell'utente
  has_many :army_lists, dependent: :destroy # Le liste create

  validates :email, presence: true, uniqueness: true
end

```

#### `app/models/game_format.rb`

Incapsula le regole del manuale per non disperderle nel codice.

```ruby
class GameFormat < ApplicationRecord
  has_many :army_lists

  validates :name, presence: true
  validates :max_points, numericality: { greater_than: 0 }

  # Metodo Helper: Calcola il limite punti per una categoria in base al totale lista
  def limit_points_for(category, list_total_points)
    # Di solito le % sono sul totale del formato, non della lista corrente, 
    # ma in C5 spesso si riferiscono al "formato di gioco" (es. 400pt).
    base = max_points 
    
    percentage = case category
                 when :character_min then min_character_percentage
                 when :character_max then max_character_percentage
                 when :war_machine   then max_war_machine_percentage
                 when :scout         then max_scouts_percentage
                 when :monster       then max_monster_percentage
                 when :flying        then max_flying_percentage
                 else 0
                 end
    
    (base * percentage / 100.0).ceil
  end

  # Helper: Calcola il numero massimo di esploratori (Regola: 1 + 2 ogni 100pt)
  def max_explorers
    1 + (2 * (max_points / 100))
  end
end

```

#### `app/models/list_entry.rb`

Il collegamento tra Lista e Profilo.

```ruby
class ListEntry < ApplicationRecord
  belongs_to :army_list, touch: true # Aggiorna updated_at della lista quando cambia l'entry
  belongs_to :profile

  validates :quantity, numericality: { greater_than: 0 }

  # Calcola il costo totale di questa entry (Costo Profilo * Quantità)
  def total_cost
    profile.total_cost * quantity
  end

  # Delegatori per facilitare l'accesso ai dati del fighter sottostante
  delegate :fighter, to: :profile
  delegate :is_character?, :rank, :keywords, :active_skills, to: :profile
end

```

#### `app/models/army_list.rb`

Il modello principale che orchestra la validazione.

```ruby
class ArmyList < ApplicationRecord
  belongs_to :user
  belongs_to :army
  belongs_to :game_format
  
  has_many :list_entries, dependent: :destroy
  has_many :profiles, through: :list_entries
  
  has_many :list_nexuses, dependent: :destroy
  has_many :nexuses, through: :list_nexuses

  # Callback per aggiornare la cache dei punti
  before_save :update_points_cache

  # Validazioni Standard
  validates :name, presence: true

  # Validazioni Regolamento (Custom)
  validate :validate_points_limit
  validate :validate_model_count
  validate :validate_composition_rules

  # Scopes
  scope :published, -> { where(published: true) }
  scope :by_user, ->(user) { where(user: user) }

  # Metodo Pubblico: Calcolo Punti in tempo reale
  def calculate_total_points
    entries_cost = list_entries.sum(&:total_cost)
    nexus_cost = list_nexuses.sum { |ln| ln.nexus.cost * ln.quantity }
    entries_cost + nexus_cost
  end

  # Metodo Pubblico: Verifica validità completa
  def legal?
    valid?
  end

  private

  def update_points_cache
    self.total_points_cache = calculate_total_points
  end

  # --- VALIDAZIONI DELLE REGOLE ---

  def validate_points_limit
    if total_points_cache > game_format.max_points
      errors.add(:base, "Punti totali (#{total_points_cache}) eccedono il limite del formato (#{game_format.max_points}).")
    end
  end

  def validate_model_count
    # Somma delle quantità di tutte le entries
    total_models = list_entries.sum(:quantity) 
    if total_models < game_format.min_models
      errors.add(:base, "Numero di modelli (#{total_models}) inferiore al minimo richiesto (#{game_format.min_models}).")
    end
  end

  def validate_composition_rules
    # Recuperiamo tutte le entries caricate in memoria per performance
    entries = list_entries.includes(profile: [:fighter, :stat_modifiers])

    # 1. Personaggi (Min/Max %)
    char_points = entries.select(&:is_character?).sum(&:total_cost)
    min_char = game_format.limit_points_for(:character_min, total_points_cache)
    max_char = game_format.limit_points_for(:character_max, total_points_cache)

    errors.add(:base, "Punti Personaggi insufficienti.") if char_points < min_char
    errors.add(:base, "Punti Personaggi eccessivi.") if char_points > max_char

    # 2. Macchine da Guerra
    wm_points = entries.select { |e| e.fighter.rank.name == 'Macchina da Guerra' }.sum(&:total_cost)
    max_wm = game_format.limit_points_for(:war_machine, total_points_cache)
    errors.add(:base, "Punti Macchine da Guerra eccessivi.") if wm_points > max_wm

    # 3. Volo
    # Verifica l'abilità attiva 'Volo' sul profilo
    fly_points = entries.select { |e| e.active_skills.any? { |s| s.name == 'Volo' } }.sum(&:total_cost)
    max_fly = game_format.limit_points_for(:flying, total_points_cache)
    errors.add(:base, "Punti Volanti eccessivi.") if fly_points > max_fly

    # 4. Esploratori (Numero e Punti)
    explorers = entries.select { |e| e.active_skills.any? { |s| s.name == 'Esploratore' } }
    explorers_count = explorers.sum(&:quantity)
    
    if explorers_count > game_format.max_explorers
      errors.add(:base, "Troppi modelli Esploratori (#{explorers_count}). Max: #{game_format.max_explorers}.")
    end
    
    # 5. Duplicati per Profilo (Regola carte uguali)
    # Raggruppa per ID del profilo base (fighter_id)
    entries.group_by { |e| e.profile.fighter_id }.each do |fighter_id, grouped_entries|
      # In C5 il limite è solitamente sulle CARTE (entries), non sui modelli totali (quantity).
      # Se ho 2 carte di Arcieri (totale 6 modelli), conta come 2 carte.
      cards_count = grouped_entries.size 
      if cards_count > game_format.max_duplicate_profiles
        fighter_name = grouped_entries.first.profile.fighter.name
        errors.add(:base, "Troppe carte per l'unità #{fighter_name} (Max: #{game_format.max_duplicate_profiles}).")
      end
    end
  end
end

```

#### `app/models/profile.rb` (Il Blueprint nella Libreria)

Dobbiamo assicurarci che il profilo sappia di essere un blueprint.

```ruby
class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :fighter
  belongs_to :affiliation, optional: true
  
  has_many :profile_modifiers, dependent: :destroy
  has_many :stat_modifiers, through: :profile_modifiers
  
  # Relazione con le liste in cui è usato
  has_many :list_entries, dependent: :destroy
  has_many :army_lists, through: :list_entries

  # Metodi di calcolo costo e stat (definiti nelle risposte precedenti)
  # ...
  
  # Helper per sapere se è usato
  def used_in_lists?
    list_entries.exists?
  end
end

```

---

### Esempio di Utilizzo nel Controller

Ecco come gestiresti la creazione di una lista sfruttando questa architettura.

```ruby
# app/controllers/army_lists_controller.rb
class ArmyListsController < ApplicationController
  def add_unit
    @army_list = current_user.army_lists.find(params[:id])
    
    # 1. Trova il profilo dalla libreria dell'utente o creane uno al volo dal fighter
    if params[:profile_id]
      @profile = current_user.profiles.find(params[:profile_id])
    else
      # Creazione al volo di un profilo base non customizzato
      fighter = Fighter.find(params[:fighter_id])
      @profile = Profile.create!(user: current_user, fighter: fighter, custom_name: fighter.name)
    end

    # 2. Crea o incrementa l'entry nella lista
    entry = @army_list.list_entries.find_or_initialize_by(profile: @profile)
    entry.quantity += 1
    
    if entry.save
      @army_list.save # Triggera il ricalcolo della cache e le validazioni
      redirect_to @army_list, notice: "Unità aggiunta."
    else
      redirect_to @army_list, alert: "Errore nell'aggiunta."
    end
  end
end

```

### Riassunto dei Vantaggi

1. **Separazione Netta**: Le regole (`GameFormat`) sono separate dai dati (`ArmyList`). Puoi aggiungere nuovi formati di torneo senza toccare il codice.
2. **Riusabilità**: L'utente può creare il suo "Kassar Perfetto" (Profilo) una volta sola e aggiungerlo a 10 liste diverse (`ListEntry`). Se l'utente modifica il Profilo (es. cambia l'artefatto), tutte le liste si aggiornano, ma la struttura della lista rimane integra.
3. **Performance**: L'uso di `total_points_cache` e il caricamento eager (`includes`) nelle validazioni previene query N+1 pesanti durante il controllo di legalità.
4. **Sicurezza**: I dati statici (`Fighter`) sono immutabili per l'utente, mentre i dati dinamici (`Profile`, `ArmyList`) sono scoped per `user_id`.