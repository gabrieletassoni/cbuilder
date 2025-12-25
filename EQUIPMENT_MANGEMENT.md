Questa è un'ottima aggiunta. In *Confrontation*, la differenza tra "Equipaggiamento" (spesso standard o scambiabile come armi/armature) e "Artefatto" (oggetti magici unici) è sottile ma importante strutturalmente.

L'architettura che hai scelto (modello separato che agisce come "container" di modificatori e requisiti) si integra perfettamente con il sistema polimorfico che abbiamo già costruito.

Ecco i passaggi per integrare l'`Equipment`.

### 1. Generatori e Migrazioni

Dobbiamo creare il modello `Equipment` e le due tabelle di unione (una per il "setup base" del Fighter, una per la "customizzazione" del Profile).

```bash
# 1. Modello Equipment
# Agisce come Artifact ma rappresenta equipaggiamento mondano (Armi, Armature, Lanterne...)
rails g model Equipment name:string description:text cost:integer

# 2. Join Table Fighter <-> Equipment (Equipaggiamento Standard)
# Definisce cosa ha il modello "sulla carta" (es. Arciere ha Arco)
rails g migration CreateJoinTableFightersEquipment fighter equipment

# 3. Join Table Profile <-> Equipment (Equipaggiamento Scelto)
# Definisce cosa ha il modello "nella lista" (es. Arciere ha comprato Arco Lungo)
rails g migration CreateJoinTableProfilesEquipment profile equipment

```

### 2. Aggiornamento delle Migrazioni (Schema)

Ecco come devono apparire i file di migrazione per sfruttare gli indici corretti.

```ruby
# db/migrate/[TIMESTAMP]_create_equipment.rb
class CreateEquipment < ActiveRecord::Migration[7.0]
  def change
    create_table :equipment do |t|
      t.string :name, null: false
      t.text :description
      t.integer :cost, default: 0
      t.timestamps
    end
    add_index :equipment, :name
  end
end

# db/migrate/[TIMESTAMP]_create_join_table_fighters_equipment.rb
class CreateJoinTableFightersEquipment < ActiveRecord::Migration[7.0]
  def change
    create_join_table :fighters, :equipment do |t|
      t.index [:fighter_id, :equipment_id], name: 'idx_fighter_equip'
      t.index [:equipment_id, :fighter_id], name: 'idx_equip_fighter'
    end
  end
end

# db/migrate/[TIMESTAMP]_create_join_table_profiles_equipment.rb
class CreateJoinTableProfilesEquipment < ActiveRecord::Migration[7.0]
  def change
    create_join_table :profiles, :equipment do |t|
      t.index [:profile_id, :equipment_id], name: 'idx_profile_equip'
      t.index [:equipment_id, :profile_id], name: 'idx_equip_profile'
    end
  end
end

```

---

### 3. Aggiornamento dei Modelli

Dobbiamo integrare `Equipment` nel flusso di calcolo dei modificatori e dei requisiti.

#### A. Il Modello `Equipment.rb`

È un "Provider" di modifiche (come `Affiliation` o `Artifact`).

```ruby
class Equipment < ApplicationRecord
  # Relazioni N:M
  has_and_belongs_to_many :fighters # Equipaggiamento base
  has_and_belongs_to_many :profiles # Equipaggiamento scelto nella lista

  # L'equipaggiamento ha modificatori (es. "Spada: +2 FOR")
  has_many :stat_modifiers, as: :source, dependent: :destroy

  # L'equipaggiamento ha requisiti (es. "Solo Guerrieri")
  has_many :requirements, as: :restrictable, dependent: :destroy

  validates :name, presence: true

  # Verifica se un fighter può equipaggiarlo (Logica riutilizzata da Artifact)
  def equipable_by?(fighter)
    return true if requirements.empty?
    requirements.all? { |req| req.met_by?(fighter) }
  end
end

```

#### B. Il Modello `Fighter.rb` (Template)

```ruby
class Fighter < ApplicationRecord
  # ... altre associazioni ...
  
  # Equipaggiamento di default (scritto sulla carta)
  has_and_belongs_to_many :equipment
  
  # ...
end

```

#### C. Il Modello `Profile.rb` (Istanza e Calcolo)

Qui dobbiamo aggiornare la logica di calcolo per includere i bonus che derivano dall'equipaggiamento.

```ruby
class Profile < ApplicationRecord
  # ... altre associazioni ...
  
  # Equipaggiamento effettivo (può differire dal fighter base se modificato)
  has_and_belongs_to_many :equipment
  
  # Callback: Quando creo un profilo, copio l'equipaggiamento base del Fighter
  after_create :copy_base_equipment

  # AGGIORNAMENTO LOGICA DI CALCOLO
  def current_value(stat_code)
    base = fighter.raw_stat(stat_code)
    
    # Raccogliamo TUTTI i modificatori da TUTTE le fonti
    # 1. Modificatori manuali diretti (ProfileModifier)
    # 2. Modificatori dall'Affiliazione (tramite ProfileModifier automatici)
    # 3. Modificatori dagli Artefatti (assumendo relazione :artifacts)
    # 4. Modificatori dall'Equipaggiamento (NUOVO)
    
    all_modifiers = stat_modifiers.to_a + 
                    equipment.flat_map(&:stat_modifiers) + 
                    artifacts.flat_map(&:stat_modifiers) # Se hai artifacts

    # Filtriamo quelli rilevanti per questa statistica
    relevant_mods = all_modifiers.select { |m| m.stat_definition.code == stat_code }
    
    # Filtriamo quelli i cui requisiti condizionali sono soddisfatti (es. "Solo se Mago")
    active_mods = relevant_modifiers.select { |m| m.applies_to?(fighter) }

    # Applica logica matematica (Set, Add, Sub)
    # 1. SET (Priorità)
    active_mods.select { |m| m.modification_type.code == 'set' }.each do |mod|
      base = mod.value_integer
    end

    # 2. ADD/SUB
    active_mods.select { |m| ['add', 'sub'].include?(m.modification_type.code) }.each do |mod|
      val = mod.value_integer
      mod.modification_type.code == 'add' ? base += val : base -= val
    end

    [base, 0].max
  end
  
  # Aggiornamento Costo Totale per includere costo equipaggiamento
  def total_cost
    base_calc = current_value('cost')
    equip_cost = equipment.sum(:cost)
    # artifact_cost = artifacts.sum(:cost)
    
    base_calc + equip_cost
  end

  private

  def copy_base_equipment
    # Copia l'equipaggiamento di default dal Fighter al Profile
    self.equipment = fighter.equipment
  end
end

```

---

### 4. File CSV per Importazione (`equipment.csv`)

Ecco alcuni esempi estratti dai documenti Daikinee e Divoratori, pronti per il seed.

```csv
name,cost,description,stat_modifiers_definitions,requirements_definitions
Arco Daikinee,0,"Arma da tiro standard Daikinee.",tir:set:3|for:add:4,""
Spada,0,"Arma da corpo a corpo standard.",,""
Mazza,0,"Arma da corpo a corpo contundente.",,""
Armatura Simbiotica,5,"Fornisce protezione e bonus simbiotici.",res:add:1|dif:add:1,Keyword:Daikinee:eq
Lame Dorsali,0,"Armi naturali dei Divoratori.",att:add:1,Keyword:Wolfen:eq
Catene del Massacro,0,"Catene specifiche per il culto del Massacro.",,Keyword:Guerriero:eq
Arco Lungo,3,"Gittata aumentata.",for:add:3,Stat:for_str:3:gt

```

*Nota: La colonna `stat_modifiers_definitions` nel CSV è un esempio di come potresti strutturare una stringa per creare i `StatModifier` associati durante il seed, dato che è una relazione 1:N.*

### 5. Aggiornamento `db/seeds.rb`

Ecco come gestire il seed dell'equipaggiamento e dei suoi modificatori.

```ruby
puts "--- Creazione Equipaggiamenti ---"

# 1. Creazione DEFINIZIONI STATISTICHE necessarie
for_def = StatDefinition.find_or_create_by!(code: 'for_str', label: 'Forza')
res_def = StatDefinition.find_or_create_by!(code: 'res', label: 'Resistenza')
add_mod = ModificationType.find_by(code: 'add')

# 2. Creazione EQUIPAGGIAMENTO
# Esempio: Armatura Simbiotica (Daikinee) - Costo 5, +1 RES
symbio_armor = Equipment.create!(
  name: "Armatura Simbiotica", 
  cost: 5, 
  description: "Armatura vivente che aumenta la protezione."
)

# 3. Creazione MODIFICATORE collegato all'Equipaggiamento
StatModifier.create!(
  source: symbio_armor,       # Polimorfico: qui punta all'Equip
  stat_definition: res_def,   # Modifica RES
  modification_type: add_mod, # Aggiunge
  value_integer: 1            # Valore 1
)

# 4. Creazione REQUISITO collegato all'Equipaggiamento
# Solo Daikinee possono averla
daikinee_kw = Keyword.find_by(name: "Daikinee") # Assumendo esista tra le keywords
if daikinee_kw
  Requirement.create!(
    restrictable: symbio_armor,
    required_entity: daikinee_kw, # Deve avere keyword Daikinee
    check_type: 'entity'
  )
end

puts "Equipaggiamenti creati."

```

### Riassunto Funzionale

Con questa modifica:

1. **Fighter Base**: Quando crei un Fighter (es. Arciere), gli associ nel seed l'equipaggiamento `Arco`.
2. **Creazione Profilo**: Quando l'utente crea una lista con l'Arciere, il sistema copia automaticamente `Arco` nel `Profile`.
3. **Personalizzazione**: L'utente può rimuovere `Arco` e aggiungere `Arco Lungo` (se i `Requirement` dell'Arco Lungo sono soddisfatti, es. FOR > 3).
4. **Calcolo**: Il metodo `current_value` vedrà che c'è un `Arco Lungo` associato al profilo, troverà il suo `StatModifier` (es. +3 FOR nel tiro), verificherà che sia applicabile e lo sommerà alle statistiche.
