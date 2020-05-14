local format = format
local date = date
local pairs = pairs
local select = select
local tonumber = tonumber
local match = string.match
local strsplit = strsplit
local GetItemInfo = GetItemInfo
local RarityColor = ITEM_QUALITY_COLORS
local TotalGathered = 0
local LootMessage = (LOOT_ITEM_SELF:gsub("%%.*", ""))
local LootMatch = "([^|]+)|cff(%x+)|H([^|]+)|h%[([^%]]+)%]|h|r[^%d]*(%d*)"
local MouseIsOver = false

-- DB of items to track
local Tracked = {
	-- Herbs
	
	-- Classic
	[765] = true,     -- Silverleaf
	[785] = true,     -- Mageroyal
	[108318] = true,  -- Mageroyal Petal
	[2044] = true,    -- Dragon's Teeth
	[108329] = true,  -- Dragon's Teeth Stem
	[2447] = true,    -- Peacebloom
	[2449] = true,    -- Earthroot
	[108319] = true,  -- Earthroot Stem
	[2450] = true,    -- Briarthorn
	[108320] = true,  -- Briarthorn Bramble
	[2452] = true,    -- Swiftthistle
	[108321] = true,  -- Swiftthistle Leaf
	[2453] = true,    -- Bruiseweed
	[108322] = true,  -- Bruiseweed Stem
	[3355] = true,    -- Wild Steelbloom
	[108323] = true,  -- Wild Steelbloom Petal
	[3356] = true,    -- Kingsblood
	[108324] = true,  -- Kingsblood Petal
	[3357] = true,    -- Liferoot
	[108325] = true,  -- Liferoot Stem
	[3358] = true,    -- Khadgar's Whisker
	[108326] = true,  -- Khadgar's Whisker Stem
	[3369] = true,    -- Grave Moss
	[108327] = true,  -- Grave Moss Leaf
	[3818] = true,    -- Fadeleaf
	[108328] = true,  -- Fadeleaf Petal
	[3819] = true,    -- Wintersbite
	[3820] = true,    -- Stranglekelp
	[108330] = true,  -- Stranglekelp Blade
	[3821] = true,    -- Goldthorn
	[108331] = true,  -- Goldthorn Bramble
	[4625] = true,    -- Firebloom
	[108332] = true,  -- Firebloom Petal
	[8831] = true,    -- Purple Lotus
	[108333] = true,  -- Purple Lotus Petal
	[8836] = true,    -- Arthas' Tears
	[108334] = true,  -- Arthas' Tears Petal
	[8838] = true,    -- Sungrass
	[108335] = true,  -- Sungrass Stalk
	[8839] = true,    -- Blindweed
	[108336] = true,  -- Blindweed Stem
	[8845] = true,    -- Ghost Mushroom
	[108337] = true,  -- Ghost Mushroom Cap
	[8846] = true,    -- Gromsblood
	[108338] = true,  -- Gromsblood Leaf
	[13463] = true,   -- Dreamfoil
	[108339] = true,  -- Dreamfoil Blade
	[13466] = true,   -- Sorrowmoss
	[108342] = true,  -- Sorrowmoss Leaf
	[13464] = true,   -- Golden Sansam
	[108340] = true,  -- Golden Sansam Leaf
	[13465] = true,   -- Mountain Silversage
	[108341] = true,  -- Mountain Silversage Stalk
	[13466] = true,   -- Plaguebloom
	[13467] = true,   -- Icecap
	[108343] = true,  -- Icecap Cap
	[13468] = true,   -- Black Lotus
	[19726] = true,   -- Bloodvine
	
	-- The Burning Crusade
	[22785] = true,    -- Felweed
	[108344] = true,   -- Felweed Stalk
	[22786] = true,    -- Dreaming Glory
	[108345] = true,   -- Dreaming Glory Petal
	[22787] = true,    -- Ragveil
	[108346] = true,   -- Ragveil Cap
	[22788] = true,    -- Flame Cap
	[22789] = true,    -- Terocone
	[108347] = true,   -- Terocone Leaf
	[22790] = true,    -- Ancient Lichen
	[108348] = true,   -- Ancient Lichen Petal
	[22791] = true,    -- Netherbloom
	[108349] = true,   -- Netherbloom Leaf
	[22792] = true,    -- Nightmare Vine
	[108350] = true,   -- Nightmare Vine Stem
	[22793] = true,    -- Mana Thistle
	[108351] = true,   -- Mana Thistle Leaf
	[22794] = true,    -- Fel Lotus
	
	-- Wrath of the Lich King
	[36901] = true,    -- Goldclover
	[108352] = true,   -- Goldclover Leaf
	[36903] = true,    -- Adder's Tongue
	[108353] = true,   -- Adder's Tongue Stem
	[36904] = true,    -- Tiger Lily
	[108354] = true,   -- Tiger Lily Petal
	[36905] = true,    -- Lichbloom
	[108355] = true,   -- Lichbloom Stalk
	[36906] = true,    -- Icethorn
	[108356] = true,   -- Icethorn Bramble
	[36907] = true,    -- Talandra's Rose
	[108357] = true,   -- Talandra's Rose Petal
	[39721] = true,    -- Deadnettle
	[108358] = true,   -- Deadnettle Bramble
	[39970] = true,    -- Fire Leaf
	[108359] = true,   -- Fire Leaf Bramble
	[36908] = true,    -- Frost Lotus
	
	-- Cataclysm
	[52983] = true,    -- Cinderbloom
	[108360] = true,   -- Cinderbloom Petal
	[52984] = true,    -- Stormvine
	[108361] = true,   -- Stormvine Stalk
	[52985] = true,    -- Azshara's Veil
	[108362] = true,   -- Azshara's Veil Stem
	[52986] = true,    -- Heartblossom
	[108363] = true,   -- Heartblossom Petal
	[52987] = true,    -- Twilight Jasmine
	[108364] = true,   -- Twilight Jasmine Petal
	[52988] = true,    -- Whiptail
	[108365] = true,   -- Whiptail Stem
	
	-- Mists of Pandaria
	[72234] = true,    -- Green Tea Leaf
	[97619] = true,    -- Torn Green Tea Leaf
	[79010] = true,    -- Snow Lily
	[97622] = true,    -- Snow Lily Petal
	[72235] = true,    -- Silkweed
	[97621] = true,    -- Silkweed Stem
	[79011] = true,    -- Fool's Cap
	[97623] = true,    -- Fool's Cap Spores
	[72237] = true,    -- Rain Poppy
	[97620] = true,    -- Rain Poppy Petal
	[89639] = true,    -- Desecrated Herb
	[97624] = true,    -- Desecrated Herb Pod
	[72238] = true,    -- Golden Lotus
	
	-- Warlords of Draenor
	[109124] = true,   -- Frostweed
	[109624] = true,   -- Broken Frostweed Stem
	[109125] = true,   -- Fireweed
	[109625] = true,   -- Broken Fireweed Stem
	[109126] = true,   -- Gorgrond Flytrap
	[109626] = true,   -- Gorgrond Flytrap Ichor
	[109127] = true,   -- Starflower
	[109627] = true,   -- Starflower Petal
	[109128] = true,   -- Nagrand Arrowbloom
	[109628] = true,   -- Nagrand Arrowbloom Petal
	[109129] = true,   -- Talador Orchid
	[109629] = true,   -- Talador Orchid Petal
	[109130] = true,   -- Chameleon Lotus
	
	-- Legion
	[124101] = true,   -- Aethril
	[124102] = true,   -- Dreamleaf
	[124103] = true,   -- Foxflower
	[124104] = true,   -- Fjarnskaggl
	[124105] = true,   -- Starlight Rose
	
	-- Battle for Azeroth
	[152505] = true,   -- Riverbud
	[152506] = true,   -- Star Moss
	[152507] = true,   -- Akunda's Bite
	[152508] = true,   -- Winter's Kiss
	[152509] = true,   -- Siren's Pollen
	[152510] = true,   -- Anchor Weed
	[152511] = true,   -- Sea Stalk
	[168487] = true,   -- Zin'anthid
	
	-- Ore
	
	-- Classic
	[2770] = true,    -- Copper Ore
	[2771] = true,    -- Tin Ore
	[2775] = true,    -- Silver Ore
	[2772] = true,    -- Iron Ore
	[2776] = true,    -- Gold Ore
	[3858] = true,    -- Mithril Ore
	[7911] = true,    -- Truesilver Ore
	[10620] = true,   -- Thorium Ore
	
	-- The Burning Crusade
	[23424] = true,    -- Fel Iron Ore
	[23425] = true,    -- Adamantite Ore
	[23426] = true,    -- Khorium Ore
	
	-- Wrath of the Lich King
	[36909] = true,    -- Cobalt Ore
	[36912] = true,    -- Saronite Ore
	[36910] = true,    -- Titanium Ore
	
	-- Cataclysm
	[53038] = true,    -- Obsidium Ore
	[52185] = true,    -- Elementium Ore
	[52183] = true,    -- Pyrite Ore
	
	-- Mists of Pandaria
	[72092] = true,    -- Ghost Iron Ore
	[97512] = true,    -- Ghost Iron Nugget
	[72093] = true,    -- Kyparite
	[97546] = true,    -- Kyparite Fragment
	[72094] = true,    -- Black Trillium Ore
	[72103] = true,    -- White Trillium Ore
	
	-- Warlords of Draenor
	[109118] = true,   -- Blackrock Ore
	[109992] = true,   -- Blackrock Fragment
	[109119] = true,   -- True Iron Ore
	[109991] = true,   -- True Iron Nugget
	
	-- Legion
	[123918] = true,   -- Leystone Ore
	[123919] = true,   -- Felslate
	[151564] = true,   -- Empyrium
	
	-- Battle for Azeroth
	[152512] = true,   -- Monelite Ore
	[152513] = true,   -- Platinum Ore
	[152579] = true,   -- Storm Silver Ore
	[168185] = true,   -- Osmenite Ore
	
	-- Skins
	
	-- Classic
	[2934] = true,    -- Ruined Leather Scraps
	[2318] = true,    -- Light Leather
	[783] = true,     -- Light Hide
	[2319] = true,    -- Medium Leather
	[4232] = true,    -- Medium Hide
	[20649] = true,   -- Heavy Leather
	[4304] = true,    -- Thick Leather
	[8170] = true,    -- Rugged Leather
	[8171] = true,    -- Rugged Hide
	
	-- The Burning Crusade
	[25649] = true,    -- Knothide Leather Scraps
	[21887] = true,    -- Knothide Leather
	[23793] = true,    -- Heavy Knothide Leather
	[25700] = true,    -- Fel Scales
	[29539] = true,    -- Cobra Scales
	[25707] = true,    -- Fel Hide
	[25708] = true,    -- Thick Clefthoof Leather
	
	-- Wrath of the Lich King
	[33567] = true,    -- Borean Leather Scraps
	[33568] = true,    -- Borean Leather
	[38561] = true,    -- Jormungar Scale
	[38558] = true,    -- Nerubian Chitin
	[44128] = true,    -- Arctic Fur
	
	-- Cataclysm
	[52977] = true,    -- Savage Leather Scraps
	[52976] = true,    -- Savage Leather
	[56516] = true,    -- Heavy Savage Leather
	[52979] = true,    -- Blackened Dragonscale
	[52980] = true,    -- Pristine Hide
	[52982] = true,    -- Deepsea Scale
	
	-- Mists of Pandaria
	[72162] = true,    -- Sha-Touched Leather
	[72120] = true,    -- Exotic Leather
	[79101] = true,    -- Prismatic Scale
	[72163] = true,    -- Magnificent Hide
	
	-- Warlords of Draenor
	[110609] = true,   -- Raw Beast Hide
	[110610] = true,   -- Raw Beast Hide Scraps
	
	-- Legion
	[124116] = true,   -- Felhide
	[168649] = true,   -- Dredged Leather
	[168650] = true,   -- Cragscale
	
	-- Battle for Azeroth
	[152541] = true,   -- Coarse Leather
	[153050] = true,   -- Shimmerscale
	[154164] = true,   -- Blood-Stained Bone
	[154722] = true,   -- Tempest Hide
	[153051] = true,   -- Mistscale
	[154165] = true,   -- Calcified Bone
	
	-- Fish
	
	-- Classic
	[6291] = true,    -- Raw Brilliant Smallfish
	[6299] = true,    -- Sickly Looking Fish
	[6303] = true,    -- Raw Slitherskin Mackerel
	[6289] = true,    -- Raw Longjaw Mud Snapper
	[6317] = true,    -- Raw Loch Frenzy
	[6358] = true,    -- Oily Blackmouth
	[6361] = true,    -- Raw Rainbow Fin Albacore
	[21071] = true,   -- Raw Sagefish
	[6308] = true,    -- Raw Bristle Whisker Catfish
	[6359] = true,    -- Firefin Snapper
	[6362] = true,    -- Raw Rockscale Cod
	[4603] = true,    -- Raw Spotted Yellowtail
	[12238] = true,   -- Darkshore Grouper
	[13422] = true,   -- Stonescale Eel
	[13754] = true,   -- Raw Glossy Mightfish
	[13755] = true,   -- Winter Squid
	[13756] = true,   -- Raw Summer Bass
	[13757] = true,   -- Lightning Eel
	[13758] = true,   -- Raw Redgill
	[13759] = true,   -- Raw Nightfin Snapper
	[13760] = true,   -- Raw Sunscale Salmon
	[13888] = true,   -- Darkclaw Lobster
	[13889] = true,   -- Raw Whitescale Salmon
	[13893] = true,   -- Large Raw Mightfish
	[6522] = true,    -- Deviate Fish
	[8365] = true,    -- Raw Mithril Head Trout
	
	-- The Burning Crusade
	[27422] = true,   -- Barbed Gill Trout
	[27516] = true,   -- Enormous Barbed Gill Trout
	[27435] = true,   -- Figluster's Mudfish
	[27438] = true,   -- Golden Darter
	[27439] = true,   -- Furious Crawdad
	[27515] = true,   -- Huge Spotted Feltail
	[27437] = true,   -- Icefin Bluefish
	[21153] = true,   -- Raw Greater Sagefish
	[27425] = true,   -- Spotted Feltail
	[27429] = true,   -- Zangarian Sporefish
	[33823] = true,   -- Bloodfin Catfish
	[33824] = true,   -- Crescent-Tail Skullfish
	[27388] = true,   -- Mr. Pinchy
	
	-- Wrath of the Lich King
	[41808] = true,   -- Bonescale Snapper
	[41805] = true,   -- Borean Man O' War
	[41802] = true,   -- Imperial Manta Ray
	[41803] = true,   -- Rockfin Grouper
	[41807] = true,   -- Dragonfin Angelfish
	[41806] = true,   -- Musselback Sculpin
	[41814] = true,   -- Glassfin Minnow
	[41809] = true,   -- Glacial Salmon
	[41810] = true,   -- Fangtooth Herring
	[41813] = true,   -- Nettlefish
	[41812] = true,   -- Barrelhead Goby
	[36781] = true,   -- Darkwater Clam
	[41800] = true,   -- Deep Sea Monsterbelly
	[41801] = true,   -- Moonglow Cuttlefish
	[40199] = true,   -- Pygmy Suckerfish
	[43647] = true,   -- Shimmering Minnow
	[43646] = true,   -- Fountain Goldfish
	[43572] = true,   -- Magic Eater
	[43571] = true,   -- Sewer Carp
	[43652] = true,   -- Slippery Eel
	[45909] = true,   -- Giant Darkwater Clam
	[46109] = true,   -- Sea Turtle (Mount)
	[34484] = true,   -- Old Ironjaw
	[34486] = true,   -- Old Crafty
	
	-- Cataclysm
	[35285] = true,   -- Giant Sunfish
	[53062] = true,   -- Sharptooth
	[53063] = true,   -- Mountain Trout
	[53064] = true,   -- Highland Guppy
	[53065] = true,   -- Albino Cavefish
	[53066] = true,   -- Blackbelly Mudfish
	[53067] = true,   -- Striped Lurker
	[53068] = true,   -- Lavascale Catfish
	[53069] = true,   -- Murglesnout
	[53070] = true,   -- Fathom Eel
	[53071] = true,   -- Algaefin Rockfish
	[53072] = true,   -- Deepsea Sagefish
	
	-- Mists of Pandaria
	[74866] = true,    -- Golden Carp
	[74859] = true,    -- Emperor Salmon
	[74856] = true,    -- Jade Lungfish
	[74863] = true,    -- Jewel Danio
	[74865] = true,    -- Krasarang Paddlefish
	[74860] = true,    -- Redbelly Mandarin
	[74861] = true,    -- Tiger Gourami
	[74864] = true,    -- Reef Octopus
	[74857] = true,    -- Giant Mantis Shrimp
	[74866] = true,    -- Golden Carp
	[83064] = true,    -- Spinefish
	[88496] = true,    -- Sealed Crate
	
	-- Warlords of Draenor
	[111664] = true,   -- Abyssal Gulper Eel
	[111663] = true,   -- Blackwater Whiptail
	[111667] = true,   -- Blind Lake Sturgeon
	[111595] = true,   -- Crescent Saberfish
	[111668] = true,   -- Fat Sleeper
	[111669] = true,   -- Jawless Skulker
	[111666] = true,   -- Fire Ammonite
	[111665] = true,   -- Sea Scorpion
	[118565] = true,   -- Savage Piranha
	
	-- Legion
	[133607] = true,   -- Silver Mackerel
	[124107] = true,   -- Cursed Queenfish
	[124109] = true,   -- Highmountain Salmon
	[124108] = true,   -- Mossgill Perch
	[124110] = true,   -- Stormray
	[124111] = true,   -- Runescale Koi
	[124112] = true,   -- Black Barracuda
	[133725] = true,   -- Leyshimmer Blenny
	[133726] = true,   -- Nar'thalas Hermit
	[133727] = true,   -- Ghostly Queenfish
	[133733] = true,   -- Ancient Highmountain Salmon
	[133732] = true,   -- Coldriver Carp
	[133731] = true,   -- Mountain Puffer
	[133736] = true,   -- Thundering Stormray
	[133734] = true,   -- Oodelfjisk
	[133735] = true,   -- Graybelly Lobster
	[133730] = true,   -- Ancient Mossgill
	[133728] = true,   -- Terrorfin
	[133729] = true,   -- Thorned Flounder
	[133739] = true,   -- Tainted Runescale Koi
	[133738] = true,   -- Seerspine Puffer
	[133737] = true,   -- Magic-Eater Frog
	[133741] = true,   -- Seabottom Squid
	[133740] = true,   -- Axefish
	[133742] = true,   -- Ancient Black Barracuda
	
	-- Battle for Azeroth
	[152545] = true,   -- Frenzied Fangtooth
	[152546] = true,   -- Lane Snapper
	[152548] = true,   -- Tiragarde Perch
	[152543] = true,   -- Sand Shifter
	[152544] = true,   -- Slimy Mackerel
	[152549] = true,   -- Redtail Loach
	[152547] = true,   -- Great Sea Catfish
	[162515] = true,   -- Midnight Salmon
	[167562] = true,   -- Ionized Minnow
	[168646] = true,   -- Mauve Stinger
	[168302] = true,   -- Viper Fish
	[174327] = true,   -- Malformed Gnasher
	[174328] = true,   -- Aberrant Voidfin
	[174456] = true,   -- Gloop (Battle Pet)
	[163131] = true,   -- Great Sea Ray (Mount)
	
	-- Darkmoon Island
	[124669] = true,   -- Darkmoon Daggermaw
	
	-- Cooking
	
	-- Classic 
	[769] = true,      -- Chunk of Boar Meat
	[1015] = true,     -- Lean Wolf Flank
	[2674] = true,     -- Crawler Meat
	[2675] = true,     -- Crawler Claw
	[3173] = true,     -- Bear Meat
	[3685] = true,     -- Raptor Egg
	[3712] = true,     -- Turtle Meat
	[3731] = true,     -- Lion Meat
	[5503] = true,     -- Clam Meat
	[12037] = true,    -- Mystery Meat <3
	[12205] = true,    -- White Spider Meat
	[12207] = true,    -- Giant Egg
	[12184] = true,    -- Raptor Flesh
	[20424] = true,    -- Sandworm Meat
	
	-- The Burning Crusade
	[27674] = true,    -- Ravager Flesh
	[27678] = true,    -- Clefthoof Meat
	[27681] = true,    -- Warped Flesh
	[31670] = true,    -- Raptor Ribs
	[31671] = true,    -- Serpent Flesh
	[27681] = true,    -- Warped Flesh
	
	-- Wrath of the Lich King
	[35948] = true,    -- Savory Snowplum ?
	[35949] = true,    -- Tundra Berries ?
	[43012] = true,    -- Rhino Meat
	[43013] = true,    -- Chilled Meat
	
	-- Cataclysm
	[62779] = true,    -- Monstrous Claw
	[62780] = true,    -- Snake Eye
	[62781] = true,    -- Giant Turtle Tongue
	[62782] = true,    -- Dragon Flank
	[62783] = true,    -- Basilisk "Liver"
	[62784] = true,    -- Crocolisk Tail
	
	-- Mists of Pandaria
	[74834] = true,    -- Mushan Ribs
	[74838] = true,    -- Raw Crab Meat
	[75014] = true,    -- Raw Crocolisk Belly
	[74833] = true,    -- Raw Tiger Steak
	[74837] = true,    -- Raw Turtle Meat
	[74839] = true,    -- Wildfowl Breast
	[74840] = true,    -- Green Cabbage
	[74847] = true,    -- Jade Squash
	[74841] = true,    -- Juicycrunch Carrot
	[74842] = true,    -- Mogu Pumpkin
	[74849] = true,    -- Pink Turnip
	[74844] = true,    -- Red Blossom Leek
	[74843] = true,    -- Scallions
	[74848] = true,    -- Striped Melon
	[74850] = true,    -- White Turnip
	[74846] = true,    -- Witchberries
	[102541] = true,   -- Aged Balsamic Vinegar
	
	-- Warlords of Draenor
	[109131] = true,   -- Raw Clefthoof Meat
	[109132] = true,   -- Raw Talbuk Meat
	[109133] = true,   -- Rylak Egg
	[109134] = true,   -- Raw Elekk Meat
	[109135] = true,   -- Raw Riverbeast Meat
	[109136] = true,   -- Raw Boar Meat
	
	-- Legion
	[124121] = true,   -- Wildfowl Egg
	[124120] = true,   -- Leyblood
	[124119] = true,   -- Big Gamy Ribs
	[124118] = true,   -- Fatty Bearsteak
	[124117] = true,   -- Lean Shank
	
	-- Battle for Azeroth
	[160399] = true,   -- Wild Flour
	[160398] = true,   -- Choral Honey
	[160712] = true,   -- Powdered Sugar
	[160400] = true,   -- Foosaka
	[160710] = true,   -- Wild Berries
	[160709] = true,   -- Fresh Potato
	[174353] = true,   -- Questionable Meat
	[174328] = true,   -- Aberrant Voidfin
	[174327] = true,   -- Malformed Gnasher
	[168303] = true,   -- Rubbery Flank
	[168645] = true,   -- Moist Fillet
	
	-- Cloth
	
	-- Classic
	[2589] = true,     -- Linen Cloth
	[2592] = true,     -- Wool Cloth
	[4306] = true,     -- Silk Cloth
	[4338] = true,     -- Mageweave Cloth
	[14047] = true,    -- Runecloth
	[14256] = true,    -- Felcloth
	
	-- The Burning Crusade
	[21877] = true,    -- Netherweave Cloth
	
	-- Wrath of the Lich King
	[33470] = true,    -- Frostweave Cloth
	
	-- Cataclysm
	[53010] = true,    -- Embersilk Cloth
	
	-- Mists of Pandaria
	[72988] = true,    -- Windwool Cloth
	
	-- Legion
	[124437] = true,   -- Shal'dorei Silk
	
	-- Battle for Azeroth
	[152576] = true,   -- Tidespray Linen
	[152577] = true,   -- Deep Sea Satin
	[167738] = true,   -- Gilded Seaweave
	
	-- Archaeology
	
	-- Classic
	[52843] = true,    -- Dwarf Rune Stone
	[63127] = true,    -- Highborne Scroll
	[63128] = true,    -- Troll Tablet
	
	-- The Burning Crusade
	[64392] = true,    -- Orc Blood Text
	[64394] = true,    -- Draenei Tome
	
	-- Wrath of the Lich King
	[64395] = true,    -- Vrykul Rune Stick
	[64396] = true,    -- Nerubian Obelisk
	
	-- Cataclysm
	[64397] = true,    -- Tol'vir Hieroglyphic
	
	-- Mists of Pandaria
	[79869] = true,    -- Mogu Statue Piece
	[79868] = true,    -- Pandaren Pottery Shard
	[95373] = true,    -- Mantid Amber Sliver
	
	-- Legion
	[130903] = true,   -- Ancient Suramar Scroll
	[130904] = true,   -- Highmountain Ritual-Stone
	[130905] = true,   -- Mark of the Deceiver
	
	-- Battle for Azeroth
	[154989] = true,   -- Zandalari Idol
	[154990] = true,   -- Etched Drust Bone
	
	-- Enchanting
	
	-- Classic
	[10938] = true,    -- Lesser Magic Essence
	[10939] = true,    -- Greater Magic Essence
	[10940] = true,    -- Strange Dust
	[10998] = true,    -- Lesser Astral Essence
	[11082] = true,    -- Greater Astral Essence
	[11083] = true,    -- Soul Dust
	[11134] = true,    -- Lesser Mystic Essence
	[11135] = true,    -- Greater Mystic Essence
	[11137] = true,    -- Vision Dust
	[11174] = true,    -- Lesser Nether Essence
	[11175] = true,    -- Greater Nether Essence
	[11176] = true,    -- Dream Dust
	[11177] = true,    -- Small Radiant Shard
	[11178] = true,    -- Large Radiant Shard
	[14343] = true,    -- Small Brilliant Shard
	[14344] = true,    -- Large Brilliant Shard
	[16202] = true,    -- Lesser Eternal Essence
	[16203] = true,    -- Greater Eternal Essence
	[16204] = true,    -- Illusion Dust
	
	-- The Burning Crusade
	[22445] = true,    -- Arcane Dust
	[22447] = true,    -- Lesser Planar Essence
	[22446] = true,    -- Greater Planar Essence
	[22448] = true,    -- Small Prismatic Shard
	[22449] = true,    -- Large Prismatic Shard
	[22450] = true,    -- Void Crystal
	
	-- Wrath of the Lich King
	[34053] = true,    -- Small Dream Shard
	[34052] = true,    -- Dream Shard
	[34054] = true,    -- Infinite Dust
	[34055] = true,    -- Greater Cosmic Essence
	[34056] = true,    -- Lesser Cosmic Essence
	[34057] = true,    -- Abyss Crystal
	
	-- Cataclysm
	[52555] = true,    -- Hypnotic Dust
	[52718] = true,    -- Lesser Celestial Essence
	[52719] = true,    -- Greater Celestial Essence
	[52720] = true,    -- Small Heavenly Shard
	[52721] = true,    -- Heavenly Shard
	[52722] = true,    -- Maelstrom Crystal
	
	-- Mists of Pandaria
	[74249] = true,    -- Spirit Dust
	[74250] = true,    -- Mysterious Essence
	[80433] = true,    -- Blood Spirit
	[94289] = true,    -- Haunting Spirit
	[102218] = true,   -- Spirit of War
	[105718] = true,   -- Sha Crystal Fragment
	[74248] = true,    -- Sha Crystal
	
	-- Warlords of Draenor
	[162948] = true,   -- Enchanted Dust
	[169091] = true,   -- Luminous Shard
	[169092] = true,   -- Temporal Crystal
	
	-- Legion
	[124440] = true,   -- Arkhana
	[124441] = true,   -- Leylight Shard
	[124442] = true,   -- Chaos Crystal
	
	-- Battle for Azeroth
	[152875] = true,   -- Gloom Dust
	[152876] = true,   -- Umbra Shard
	[152877] = true,   -- Veiled Crystal
	
	-- Misc.
	
	-- Eggs
	[89155] = true,    -- Onyx Egg
	[32506] = true,    -- Netherwing Egg
	
	-- Tillers
	[79265] = true,    -- Blue Feather
	[79267] = true,    -- Lovely Apple
	[79268] = true,    -- Marsh Lily
	[79266] = true,    -- Jade Cat
	[79264] = true,    -- Ruby Shard
	[79269] = true,    -- Marsh Lily
	
	-- Rep
	[94226] = true,    -- Stolen Klaxxi Insignia
	[94223] = true,    -- Stolen Shado-Pan Insignia
	[94225] = true,    -- Stolen Celestial Insignia
	[94227] = true,    -- Stolen Golden Lotus Insignia
	
	-- Darkmoon Island
	[127141] = true,   -- Bloated Thresher
	[124670] = true,   -- Sealed Darkmoon Crate
	
	-- Noblegarden
	[45072] = true,    -- Brightly Colored Egg
	
	[174858] = true,   -- Gersahl Greens
}

--[[local TrackedItemTypes = {
	[7] = { -- LE_ITEM_CLASS_TRADEGOODS
		[5] = true, -- Cloth
		[6] = true, -- Leather
		[7] = true, -- Metal & Stone
		[8] = true, -- Cooking
		[9] = true, -- Herb
		--[12] = true, -- Enchanting
	},
	
	[15] = { -- LE_ITEM_CLASS_MISCELLANEOUS
		[2] = true, -- Companion Pets
		[3] = true, -- Holiday
		[5] = true, -- Mount
	},
}]]

-- Keep track of what we've gathered, how many nodes, and what quantity.
local Gathered = {}
local NumTypes = 0

-- Tooltip
local Tooltip = CreateFrame("GameTooltip", "GatheringTooltip", UIParent, "GameTooltipTemplate")
local TooltipFont = "Interface\\Addons\\Gathering\\PTSans.ttf"

local SetFont = function(self)
	for i = 1, self:GetNumRegions() do
		local Region = select(i, self:GetRegions())
		
		if (Region:GetObjectType() == "FontString" and not Region.Handled) then
			Region:SetFont(TooltipFont, 12)
			Region:SetShadowColor(0, 0, 0)
			Region:SetShadowOffset(1.25, -1.25)
			Region.Handled = true
		end
	end
end

-- Main frame
local Frame = CreateFrame("Frame", nil, UIParent)
Frame:SetSize(140, 28)
Frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
Frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
Frame:SetBackdropColor(0, 0, 0, 1)
Frame:EnableMouse(true)
Frame:SetMovable(true)
Frame:SetClampedToScreen(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetScript("OnDragStart", Frame.StartMoving)
Frame:SetScript("OnDragStop", Frame.StopMovingOrSizing)

Frame.Text = Frame:CreateFontString(nil, "OVERLAY")
Frame.Text:SetPoint("CENTER", Frame, "CENTER", 0, 0)
Frame.Text:SetJustifyH("CENTER")
Frame.Text:SetFont(TooltipFont, 14)
Frame.Text:SetText("Gathering")

local Timer = CreateFrame("Frame", "GatheringTimer")

local SecondsPerItem = {}
local Seconds = 0
local Elapsed = 0

local ClearStats = function()
	wipe(Gathered)
	NumTypes = 0
	TotalGathered = 0
	
	for key in pairs(SecondsPerItem) do
		SecondsPerItem[key] = 0
	end
end

local OnEnter = function(self)
	if (TotalGathered == 0) then
		return
	end
	
	MouseIsOver = true
	
	local Count = 0
	
	Tooltip:SetOwner(self, "ANCHOR_NONE")
	Tooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	Tooltip:ClearLines()
	
	Tooltip:AddLine("Gathering")
	Tooltip:AddLine(" ")
	
	for SubType, Info in pairs(Gathered) do
		Tooltip:AddLine(SubType, 1, 1, 0)
		Count = Count + 1
		
		for Name, Value in pairs(Info) do
			local Rarity = select(3, GetItemInfo(Name))
			local Hex = "|cffFFFFFF"
			
			if Rarity then
				Hex = RarityColor[Rarity].hex
			end
			
			if SecondsPerItem[Name] then
				local PerHour = (((Value / SecondsPerItem[Name]) * 60) * 60)
				
				Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s/Hr)", Value, format("%.0f", PerHour)), 1, 1, 1, 1, 1, 1)
			else
				Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), Value, 1, 1, 1, 1, 1, 1)
			end
		end
		
		if (Count ~= NumTypes) then
			Tooltip:AddLine(" ")
		end
	end
	
	local PerHour = (((TotalGathered / Seconds) * 60) * 60)
	
	Tooltip:AddLine(" ")
	Tooltip:AddDoubleLine("Total Gathered:", format("%s", TotalGathered))
	Tooltip:AddDoubleLine("Total Average Per Hour:", format("%.0f", PerHour))
	Tooltip:AddLine(" ")
	Tooltip:AddLine("Left click: Toggle timer")
	Tooltip:AddLine("Right click: Reset data")
	
	SetFont(Tooltip)
	
	Tooltip:Show()
end

local OnLeave = function()
	if Tooltip.Forced then
		return
	end
	
	MouseIsOver = false
	
	Tooltip:Hide()
end

local TimerUpdate = function(self, ela)
	Elapsed = Elapsed + ela
	
	if (Elapsed >= 1) then
		Seconds = Seconds + 1
		
		for key in pairs(SecondsPerItem) do
			SecondsPerItem[key] = SecondsPerItem[key] + 1
		end
		
		Frame.Text:SetText(date("!%X", Seconds))
		
		-- TT update
		if MouseIsOver then
			OnLeave()
			OnEnter(Frame)
		end
		
		Elapsed = 0
	end
end

local Start = function()
	if (not strfind(Frame.Text:GetText(), "%d:%d%d:%d%d")) then
		Frame.Text:SetText("0:00:00")
	end
	
	Timer:SetScript("OnUpdate", TimerUpdate)
	Frame.Text:SetTextColor(0, 1, 0)
end

local Stop = function()
	Timer:SetScript("OnUpdate", nil)
	Frame.Text:SetTextColor(1, 0, 0)
end

local Toggle = function()
	if (not Timer:GetScript("OnUpdate")) then
		Start()
	else
		Stop()
	end
end

local Reset = function()
	Timer:SetScript("OnUpdate", nil)

	ClearStats()
	
	Seconds = 0
	Elapsed = 0
	
	Frame.Text:SetTextColor(1, 1, 1)
	Frame.Text:SetText(date("!%X", Seconds))
end

local Update = function(self, event, msg)
	if (not msg) then
		return
	end
	
	if (InboxFrame:IsVisible() or (GuildBankFrame and GuildBankFrame:IsVisible())) then -- Ignore useless info
		return
	end
	
	local PreMessage, _, ItemString, Name, Quantity = match(msg, LootMatch)
	local LinkType, ID = strsplit(":", ItemString)
	
	if (PreMessage ~= LootMessage) then
		return
	end
	
	ID = tonumber(ID)
	Quantity = tonumber(Quantity) or 1
	local Type, SubType, _, _, _, _, ClassID, SubClassID = select(6, GetItemInfo(ID))
	
	-- Check that we want to track the type of item
	--if (TrackedItemTypes[ClassID] and not TrackedItemTypes[ClassID][SubClassID]) then
	if (not Tracked[ID]) then
		return
	end
	
	if (not Gathered[SubType]) then
		Gathered[SubType] = {}
		NumTypes = NumTypes + 1
	end
	
	if (not Gathered[SubType][Name]) then
		Gathered[SubType][Name] = 0
	end
	
	if (not SecondsPerItem[Name]) then
		SecondsPerItem[Name] = 0
	end
	
	Gathered[SubType][Name] = Gathered[SubType][Name] + Quantity
	TotalGathered = TotalGathered + Quantity -- For Gathered/Hour stat
	
	if (not Timer:GetScript("OnUpdate")) then
		Start()
	end
	
	-- TT update
	if MouseIsOver then
		OnLeave()
		OnEnter(self)
	end
end

local OnMouseUp = function(self, button)
	if (button == "LeftButton") then
		Toggle()
	elseif (button == "RightButton") then
		Reset()
	elseif (button == "MiddleButton") then
		if (Tooltip.Forced == true) then
			Tooltip.Forced = false
		else
			Tooltip.Forced = true
		end
	end
end

Frame:RegisterEvent("CHAT_MSG_LOOT")
Frame:SetScript("OnEvent", Update)
Frame:SetScript("OnEnter", OnEnter)
Frame:SetScript("OnLeave", OnLeave)
Frame:SetScript("OnMouseUp", OnMouseUp)