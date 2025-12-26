puts "Seeding Data into DB from cbuilder"

# App Name
Settings.app_name = "S-ciànter Confrontation Builder"

# code,symbol,description
# add,+
# sub,-
# set,=
# append,Aggiungi (per liste)
# remove,Rimuovi (per liste)
ModificationType.find_or_create_by(code: "add") do |mt|
  mt.symbol = "+"
  mt.description = "Add to Value"
end
ModificationType.find_or_create_by(code: "sub") do |mt|
  mt.symbol = "-"
  mt.description = "Subtract from Value"
end
ModificationType.find_or_create_by(code: "set") do |mt|
  mt.symbol = "="
  mt.description = "Set Value"
end
ModificationType.find_or_create_by(code: "append") do |mt|
  mt.symbol = "→"
  mt.description = "Add to List"
end
ModificationType.find_or_create_by(code: "remove") do |mt|
  mt.symbol = "←"
  mt.description = "Remove from List"
end
puts "Seeding Data into DB from cbuilder - DONE"

# Stat Definition
# code,label
# cost,Costo in Punti
# mov,Movimento
# att,Attacco
# for,Forza
# res,Resistenza
# skills,Abilità (Speciale)
[
  "movement_ground",
  "movement_fly",
  "initiative",
  "attack",
  "strength",
  "defence",
  "resilience",
  "aim",
  "courage",
  "fear",
  "discipline",
  "power",
  "faith_create",
  "faith_alter",
  "faith_destroy",
  "skills",
].each do |code|
  StatDefinition.find_or_create_by(code: code) do |sd|
    sd.label = code.humanize
  end
end
puts "Seeding Stat Definitions into DB - DONE"
# Size
# name,base_wounds,base_force,base_dimensions
# Small,4,1,25 x 25 mm
# Medium,4,1,25 x 25 mm
# Large Cavalry,5,2,25 x 50 mm
# Large Creature,5,2,37.5 x 37.5 mm
# Very Large Enormous,6,3,50 x 50 mm
# Very Large Colossal,7,4,100 x 100 mm
# Very Large Gargantuan,8,5,150 x 150 mm
[
  { name: "Small", base_wounds: 4, base_force: 1, base_dimensions: "25 x 25 mm" },
  { name: "Medium", base_wounds: 4, base_force: 1, base_dimensions: "25 x 25 mm" },
  { name: "Cavalry", base_wounds: 5, base_force: 2, base_dimensions: "25 x 50 mm" },
  { name: "Creature", base_wounds: 5, base_force: 2, base_dimensions: "37.5 x 37.5 mm" },
  { name: "Enormous", base_wounds: 6, base_force: 3, base_dimensions: "50 x 50 mm" },
  { name: "Colossal", base_wounds: 7, base_force: 4, base_dimensions: "100 x 100 mm" },
  { name: "Gigantic", base_wounds: 8, base_force: 5, base_dimensions: "150 x 150 mm" },
].each do |size_attrs|
  Size.find_or_create_by(name: size_attrs[:name]) do |s|
    s.base_wounds = size_attrs[:base_wounds]
    s.base_force = size_attrs[:base_force]
    s.base_dimensions = size_attrs[:base_dimensions]
  end
end
puts "Seeding Sizes into DB - DONE"

# Ranks
# name,value
[
  # Warriors
  { name: "Irregular", value: 1 },
  { name: "Regular", value: 1 },
  { name: "Veteran", value: 1 },
  { name: "Creature", value: 1 },
  { name: "Special", value: 2 },
  { name: "Elite", value: 2 },
  { name: "Living Legend", value: 3 },
  { name: "Major Ally", value: 4 },
  # Mages
  { name: "Initiate", value: 1 },
  { name: "Adept", value: 2 },
  { name: "Master", value: 3 },
  { name: "Virtuoso", value: 4 },
  # Faithful
  { name: "Devout", value: 1 },
  { name: "Zealot", value: 2 },
  { name: "Dean", value: 3 },
  { name: "Avatar", value: 4 },
].each do |rank_attrs|
  Rank.find_or_create_by(name: rank_attrs[:name]) do |r|
    r.value = rank_attrs[:value]
  end
end
puts "Seeding Ranks into DB - DONE"
# Paths of alliance
# name,description
[
  { name: "The Ways of Light", description: "Protecting the innocent, seeking perfection, serving the cause of Peace: these are the ideals of Light. The people that have sworn loyalty to it have set their cultural differences aside and are taking coordinated action to save the continent of Aarklash from the invasion of Darkness. The valiant protectors of Light must not fail: the flames of hope are at once the treasure they safekeep and the source of their fabulous powers." },
  { name: "The Meanders of Darkness", description: "Chaos, corruption and death crawl in the wake of the people gathered under the banner of Darkness. Some wish to build empires or desire forbidden powers. Others hunger for slaughter or for vengeance. Whatever their reasons and their legitimacy, they have all chosen to serve uncontrollable forces to reach their ends, After centuries of being hunted and punished, the lords of Darkness are uniting their forces to conquer Aarklash and leave it to the powers of the Void" },
  { name: "The Paths of Destiny", description: "Many people of Aarklash are subjected neither to Light nor to Darkness. Desired by many, the nations of Destiny must continuously struggle to maintain their independence and protect the fragile balance that rules the world. Strictly speaking, they don't form an alliance and sometimes even confront each other. Yet the people of Destiny could very well play a decisive role in the battles of the Age of Darkness." },
  { name: "The free city of Cadwallon", description: "In the midst of the conflict between Light and Darkness, the free city of Cadwallon stands as a beacon of neutrality and commerce. Governed by a council of merchants and scholars, Cadwallon thrives on trade and diplomacy, offering refuge to those seeking to escape the ravages of war. Its strategic location and fortified walls make it a vital hub for information and resources, attracting adventurers and opportunists alike." },
  { name: "The Immortals of Aarklash", description: "Legends speak of the Immortals, ancient beings who have transcended the mortal coil to become eternal guardians of Aarklash. These enigmatic figures are said to possess unparalleled wisdom and power, intervening in the affairs of mortals only when the balance of the world is at stake. The Immortals are revered and feared in equal measure, their true motives shrouded in mystery as they watch over the unfolding saga of Light and Darkness." },
].each do |path_attrs|
  Path.find_or_create_by(name: path_attrs[:name]) do |p|
    p.description = path_attrs[:description]
  end
end
puts "Seeding Paths into DB - DONE"
