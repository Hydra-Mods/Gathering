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
	
	-- Vanilla
	[765] = true,     -- Silverleaf
	[785] = true,     -- Mageroyal
	[2447] = true,    -- Peacebloom
	[2449] = true,    -- Earthroot
	[2450] = true,    -- Briarthorn
	[2452] = true,    -- Swiftthistle
	[2453] = true,    -- Bruiseweed
	[3355] = true,    -- Wild Steelbloom
	[3356] = true,    -- Kingsblood
	[3357] = true,    -- Liferoot
	[3358] = true,    -- Khadgar's Whisker
	[3369] = true,    -- Grave Moss
	[3818] = true,    -- Fadeleaf
	[3819] = true,    -- Wintersbite
	[3820] = true,    -- Stranglekelp
	[3821] = true,    -- Goldthorn
	[4625] = true,    -- Firebloom
	[8831] = true,    -- Purple Lotus
	[8836] = true,    -- Arthas' Tears
	[8838] = true,    -- Sungrass
	[8839] = true,    -- Blindweed
	[8845] = true,    -- Ghost Mushroom
	[8846] = true,    -- Gromsblood
	[13463] = true,   -- Dreamfoil
	[13464] = true,   -- Golden Sansam
	[108340] = true,  -- Golden Sansam Leaf
	[13465] = true,   -- Mountain Silversage
	[13466] = true,   -- Plaguebloom
	[13467] = true,   -- Icecap
	[13468] = true,   -- Black Lotus
	[19726] = true,   -- Bloodvine
	
	-- The Burning Crusade
	[22785] = true,    -- Felweed
	[22786] = true,    -- Dreaming Glory
	[22787] = true,    -- Ragveil
	[22788] = true,    -- Flame Cap
	[22789] = true,    -- Terocone
	[22790] = true,    -- Ancient Lichen
	[22791] = true,    -- Netherbloom
	[22792] = true,    -- Nightmare Vine
	[22793] = true,    -- Mana Thistle
	[22794] = true,    -- Fel Lotus
	
	-- Wrath of the Lich King
	[36901] = true,    -- Goldclover
	[36903] = true,    -- Adder's Tongue
	[36904] = true,    -- Tiger Lily
	[36905] = true,    -- Lichbloom
	[36906] = true,    -- Icethorn
	[36907] = true,    -- Talandra's Rose
	[36908] = true,    -- Frost Lotus
	[39721] = true,    -- Deadnettle
	
	-- Cataclysm
	[52983] = true,    -- Cinderbloom
	[52984] = true,    -- Stormvine
	[52985] = true,    -- Azshara's Veil
	[52986] = true,    -- Heartblossom
	[52987] = true,    -- Twilight Jasmine
	[52988] = true,    -- Whiptail
	
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
	
	-- Ore
	
	-- Vanilla
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
	
	-- Skins
	
	-- Vanilla
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
	
	-- Fish
	
	-- Vanilla
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
	
	-- Darkmoon Island
	[124669] = true,   -- Darkmoon Daggermaw
	
	-- Cloth
	
	-- Vanilla
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
	
	-- Archaeology
	
	-- Vanilla
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