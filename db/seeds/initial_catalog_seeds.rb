ModificationType.upsert_all([
  {id: 1, code: "add", symbol: "+", description: "Add to Value", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 2, code: "sub", symbol: "-", description: "Subtract from Value", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 3, code: "set", symbol: "=", description: "Set Value", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 4, code: "append", symbol: "→", description: "Add to List", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 5, code: "remove", symbol: "←", description: "Remove from List", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
StatDefinition.upsert_all([
  {id: 1, code: "movement_ground", label: "Movement ground", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 2, code: "movement_fly", label: "Movement fly", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 3, code: "initiative", label: "Initiative", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 4, code: "attack", label: "Attack", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 5, code: "strength", label: "Strength", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 6, code: "defence", label: "Defence", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 7, code: "resilience", label: "Resilience", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 8, code: "aim", label: "Aim", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 9, code: "courage", label: "Courage", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 10, code: "fear", label: "Fear", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 11, code: "discipline", label: "Discipline", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 12, code: "power", label: "Power", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 13, code: "faith_create", label: "Faith create", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 14, code: "faith_alter", label: "Faith alter", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 15, code: "faith_destroy", label: "Faith destroy", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 16, code: "base_dice_pool", label: "Base dice pool", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 17, code: "skills", label: "Skills", description: nil, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
Size.upsert_all([
  {id: 1, name: "Small", base_wounds: 4, base_force: 1, base_dimensions: "25 x 25 mm", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 2, name: "Medium", base_wounds: 4, base_force: 1, base_dimensions: "25 x 25 mm", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 3, name: "Cavalry", base_wounds: 5, base_force: 2, base_dimensions: "25 x 50 mm", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 4, name: "Creature", base_wounds: 5, base_force: 2, base_dimensions: "37.5 x 37.5 mm", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 5, name: "Enormous", base_wounds: 6, base_force: 3, base_dimensions: "50 x 50 mm", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 6, name: "Colossal", base_wounds: 7, base_force: 4, base_dimensions: "100 x 100 mm", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 7, name: "Gigantic", base_wounds: 8, base_force: 5, base_dimensions: "150 x 150 mm", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
Path.upsert_all([
  {id: 1, name: "The Ways of Light", description: "Protecting the innocent, seeking perfection, serving the cause of Peace: these are the ideals of Light. The people that have sworn loyalty to it have set their cultural differences aside and are taking coordinated action to save the continent of Aarklash from the invasion of Darkness. The valiant protectors of Light must not fail: the flames of hope are at once the treasure they safekeep and the source of their fabulous powers.", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 2, name: "The Meanders of Darkness", description: "Chaos, corruption and death crawl in the wake of the people gathered under the banner of Darkness. Some wish to build empires or desire forbidden powers. Others hunger for slaughter or for vengeance. Whatever their reasons and their legitimacy, they have all chosen to serve uncontrollable forces to reach their ends, After centuries of being hunted and punished, the lords of Darkness are uniting their forces to conquer Aarklash and leave it to the powers of the Void", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 3, name: "The Paths of Destiny", description: "Many people of Aarklash are subjected neither to Light nor to Darkness. Desired by many, the nations of Destiny must continuously struggle to maintain their independence and protect the fragile balance that rules the world. Strictly speaking, they don't form an alliance and sometimes even confront each other. Yet the people of Destiny could very well play a decisive role in the battles of the Age of Darkness.", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 4, name: "The free city of Cadwallon", description: "In the midst of the conflict between Light and Darkness, the free city of Cadwallon stands as a beacon of neutrality and commerce. Governed by a council of merchants and scholars, Cadwallon thrives on trade and diplomacy, offering refuge to those seeking to escape the ravages of war. Its strategic location and fortified walls make it a vital hub for information and resources, attracting adventurers and opportunists alike.", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 5, name: "The Immortals of Aarklash", description: "Legends speak of the Immortals, ancient beings who have transcended the mortal coil to become eternal guardians of Aarklash. These enigmatic figures are said to possess unparalleled wisdom and power, intervening in the affairs of mortals only when the balance of the world is at stake. The Immortals are revered and feared in equal measure, their true motives shrouded in mystery as they watch over the unfolding saga of Light and Darkness.", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
RankCategory.upsert_all([
  {id: 1, name: "Pure Warrior", code: "warrior", description: "Pure Warriors (no Magic or Faith requirements).", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 2, name: "Mage", code: "mage", description: "Users of Magic (POW).", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 3, name: "Faithful", code: "faithful", description: "Users of Miracles (FAITH).", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
SkillCategory.upsert_all([
  {id: 1, name: "active", description: "Active abilities have no effect and cannot be used if the fighter who has them is Rotten. Their usage must be declared.", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 2, name: "passive", description: "Passive abilities are always effective (unless effects explicitly deny their activation).", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 3, name: "*", description: "Abilities marked with an (*) are included or excluded from some game effects.", created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
Rank.upsert_all([
  {id: 1, name: "Irregular", value: 0, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 2, name: "Regular", value: 1, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 3, name: "Veteran", value: 1, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 4, name: "Creature", value: 1, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 5, name: "War Machine", value: 1, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 6, name: "Special", value: 2, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 7, name: "Elite", value: 2, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 8, name: "Living Legend", value: 3, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 9, name: "Major Ally", value: 4, rank_category_id: 1, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 10, name: "Initiate", value: 1, rank_category_id: 2, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 11, name: "Adept", value: 2, rank_category_id: 2, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 12, name: "Master", value: 3, rank_category_id: 2, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 13, name: "Virtuoso", value: 4, rank_category_id: 2, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 14, name: "Devotee", value: 1, rank_category_id: 3, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 15, name: "Zealot", value: 2, rank_category_id: 3, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 16, name: "Dean", value: 3, rank_category_id: 3, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"},
  {id: 17, name: "Avatar", value: 4, rank_category_id: 3, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
Army.upsert_all([
  {id: 1, name: "Devourers of Vile-Tis", description: "One day, a meteor fell in the forest of Caer Laen, and from that strange stone emerged a wounded God, filled with hatred for the other deities: the Beast. The Beast met Ellis, a great Wolfen leader, and revealed to him the truth about his and his Wolfen brothers' origins. He revealed the plan of the goddess Yllia, an evil deity who hated her children and was ready to sacrifice them all in the final battle of Ragnarok. Shocked but strengthened by a new awareness, Ellis united under a single banner all those seeking vengeance against the Gods and Yllia, and marches on in search of vengeance.", path_id: 2, created_at: "2025-12-27T17:04:53Z", updated_at: "2025-12-27T17:04:53Z"}
])
