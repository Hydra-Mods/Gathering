local date = date
local next = next
local select = select
local max = math.max
local floor = floor
local format = format
local tonumber = tonumber
local match = string.match
local GetTime = GetTime
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild
local GetItemInfo = GetItemInfo
local GetNumGroupMembers = GetNumGroupMembers
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local LootMatch = "([^|]+)|cff(%x+)|H([^|]+)|h%[([^%]]+)%]|h|r[^%d]*(%d*)"
local Locale = GetLocale()
local MaxWidgets = 11
local MaxSelections = 8
local BlankTexture = "Interface\\AddOns\\Gathering\\Assets\\HydraUIBlank.tga"
local BarTexture = "Interface\\AddOns\\Gathering\\Assets\\HydraUI4.tga"
local GameVersion = select(4, GetBuildInfo())
local AddOnVersion = GetAddOnMetadata("Gathering", "Version")
local AddOnNum = tonumber(AddOnVersion)
local CT = ChatThrottleLib
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local Textures = SharedMedia:HashTable("statusbar")
local Fonts = SharedMedia:HashTable("font")
local Gathering = CreateFrame("Frame", "Gathering_Header", UIParent, "BackdropTemplate")
local Me = UnitName("player")
local ReplicateItems, GetNumReplicateItems, GetReplicateItemInfo
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local ChannelCD = {}

Gathering.DefaultSettings = {
	-- Tracking
	["track-ore"] = true,
	["track-herbs"] = true,
	["track-leather"] = true,
	["track-cooking"] = true,
	["track-cloth"] = true,
	["track-jewelcrafting"] = true,
	["track-enchanting"] = true,
	["track-reagents"] = true,
	["track-consumable"] = true,
	["track-holiday"] = true,
	["track-quest"] = false,
	["track-xp"] = true,

	-- Functionality
	["ignore-bop"] = false, -- Ignore bind on pickup gear. IE: ignore BoP loot on a raid run, but show BoE's for the auction house
	["hide-idle"] = false, -- Hide the tracker frame while not running
	["show-tooltip"] = false, -- Show tooltip data about item prices

	-- Styling
	["window-font"] = SharedMedia.DefaultMedia.font, -- Set the font

	-- Functionality
	IgnoreBOP = false, -- Ignore bind on pickup gear. IE: ignore BoP loot on a raid run, but show BoE's for the auction house
	HideIdle = false, -- Hide the tracker frame while not running
	ShowTooltip = false, -- Show tooltip data about item prices
	IgnoreMailItems = false, -- Ignore items that arrived through mail
	IgnoreMailMoney = false, -- Ignore money that arrived through mail
	ShowTooltipHelp = true, -- Display helpful information in the tooltip (Left click to toggle, right click to reset)
	DisplayMode = "TIME", -- TOTAL; Display total gathered, GPH; display gold per hour, GOLD; display gold collected, TIME; display timer

	-- Styling
	WindowFont = SharedMedia.DefaultMedia.font, -- Set the font
	WindowHeight = 24,
	WindowWidth = 130,
}

if C_Container then
	GetContainerNumSlots = C_Container.GetContainerNumSlots
	GetContainerItemID = C_Container.GetContainerItemID
	GetContainerItemInfo = C_Container.GetContainerItemInfo
end

if (C_AuctionHouse and C_AuctionHouse.ReplicateItems) then
	ReplicateItems = C_AuctionHouse.ReplicateItems
	GetNumReplicateItems = C_AuctionHouse.GetNumReplicateItems
	GetReplicateItemInfo = C_AuctionHouse.GetReplicateItemInfo
end

local ValidMessages = {
	[LOOT_ITEM_SELF:gsub("%%.*", "")] = true,
	[LOOT_ITEM_PUSHED_SELF:gsub("%%.*", "")] = true,
}

SharedMedia:Register("font", "PT Sans", "Interface\\Addons\\Gathering\\Assets\\PTSans.ttf")
SharedMedia:Register("statusbar", "HydraUI 4", BarTexture)

local L = {}

if (Locale == "deDE") then -- German
	L["Total Gathered:"] = "Gesammelt total:"
	L["Total Average Per Hour:"] = "Gesamtdurchschnitt pro Stunde:"
	L["Total Value:"] = "Gesamtwert:"
	L["Left click: Toggle timer"] = "Linksklick: Timer anhalten/fortsetzen"
	L["Right click: Reset data"] = "Rechtsklick: Daten zur\195\188cksetzen"
	L["Hr"] = "Std."

	L["Ore"] = "Erz"
	L["Herbs"] = "Kr\195\164uter"
	L["Leather"] = "Leder"
	L["Cloth"] = "Stoffe"
	L["Enchanting"] = "Verzaubern"
	L["Reagents"] = "Reagenzien"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignoriere Items, welche beim aufheben Seelengebunden werden"
	L["Show tooltip data"] = "Zeige Tooltip Daten"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Preis pro Einheit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "esES") then -- Spanish (Spain)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "esMX") then -- Spanish (Mexico)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "frFR") then -- French
	L["Total Gathered:"] = "Total recueilli:"
	L["Total Average Per Hour:"] = "Moyenne totale par heure:"
	L["Total Value:"] = "Valeur totale:"
	L["Left click: Toggle timer"] = "Clic gauche : Minuterie on/off"
	L["Right click: Reset data"] = "Clic droit : Réinitialisation des données"
	L["Hr"] = "Hr"

	L["Ore"] = "Minerai"
	L["Herbs"] = "Herbes"
	L["Leather"] = "Cuir"
	L["Cloth"] = "Tissu"
	L["Enchanting"] = "Enchanteur"
	L["Reagents"] = "Réactifs"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignorer les objets liés au ramassage"
	L["Show tooltip data"] = "Afficher les données de l'infobulle"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Prix par unité: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "itIT") then -- Italian
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "koKR") then -- Korean
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "ptBR") then -- Portuguese (Brazil)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "ruRU") then -- Russian
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "zhCN") then -- Chinese (Simplified)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
elseif (Locale == "zhTW") then -- Chinese (Traditional/Taiwan)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
else
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"

	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Reagents"] = "Reagents"
	L["Cooking"] = "Cooking"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Consumables"] = "Consumables"
	L["Holiday"] = "Holiday"
	L["Quests"] = "Quests"
	L["XP"] = "Experience"

	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["Show tooltip data"] = "Show tooltip data"
	L["Show tooltip help"] = "Show tooltip help"
	L["Price per unit: %s"] = "Price per unit: %s"
	L["Ignore mail items"] = "Ignore mail items"
	L["Ignore mail gold"] = "Ignore mail gold"
	L["Display Mode"] = "Display Mode"
	L["Gold"] = "Gold"
	L["GPH"] = "GPH"
	L["Time"] = "Time"
	L["Total"] = "Total"
	L["GPH: %s"] = "GPH: %s"
	L["Total: %s"] = "Total: %s"

	L["Hide while idle"] = "Hide while idle"
	L["Ignore items"] = "Ignore items"
	L["Unignore items"] = "Unignore items"
	L["%s is now being ignored."] = "%s is now being ignored."
	L["%s is now being unignored."] = "%s is now being unignored."

	L["Set Font"] = "Set Font"
	L["Set Width"] = "Set Width"
	L["Set Height"] = "Set Height"
	L["Discord"] = "Discord"
	L["Recently Gathered: "] = "Recently Gathered: "
	L["Gathering Scan"] = "Gathering Scan"
	L["Are you sure you would like to reset current data?"] = "Are you sure you would like to reset current data?"
end

local DisplayModes = {
	[L["Time"]] = "TIME",
	[L["GPH"]] = "GPH",
	[L["Gold"]] = "GOLD",
	[L["Total"]] = "TOTAL",
}

local Outline = {
	bgFile = BlankTexture,
}

-- Header
Gathering:SetPoint("TOP", UIParent, 0, -100)
Gathering:EnableMouse(true)
Gathering:SetMovable(true)
Gathering:SetUserPlaced(true)
Gathering.SentGroup = false
Gathering.SentInstance = false
Gathering.LastYell = 0
Gathering.Int = 1

function Gathering:CreateWindow()
	self:SetSize(self.Settings.WindowWidth, self.Settings.WindowHeight)
	self:SetBackdrop({bgFile = BlankTexture, edgeFile = BlankTexture, edgeSize = 1})
	self:SetBackdropColor(0.2, 0.2, 0.2, 0.85)
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetClampedToScreen(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)

	-- Text
	self.Text = self:CreateFontString(nil, "OVERLAY")
	self.Text:SetPoint("CENTER", self, 0, 0)
	self.Text:SetJustifyH("CENTER")
	self.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 14, "")

	if (self.Settings.DisplayMode == "TIME") then
		self.Text:SetText(date("!%X", 0))
	elseif (self.Settings.DisplayMode == "GPH") then
		self.Text:SetFormattedText(L["GPH: %s"], self:CopperToGold(0))
		self.Int = 2
	elseif (self.Settings.DisplayMode == "GOLD") then
		self.Text:SetText(self:CopperToGold(0))
	elseif (self.Settings.DisplayMode == "TOTAL") then
		self.Text:SetFormattedText(L["Total: %s"], 0)
	end

	-- Tooltip
	self.Tooltip = CreateFrame("GameTooltip", "Gathering Tooltip", UIParent, "GameTooltipTemplate")
	self.Tooltip:SetFrameLevel(10)

	self.Tooltip.Backdrop = CreateFrame("Frame", nil, self.Tooltip, "BackdropTemplate")
	self.Tooltip.Backdrop:SetAllPoints(Gathering.Tooltip)
	self.Tooltip.Backdrop:SetBackdrop({bgFile = BlankTexture})
	self.Tooltip.Backdrop:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
	self.Tooltip.Backdrop:SetFrameStrata("TOOLTIP")
	self.Tooltip.Backdrop:SetFrameLevel(1)

	-- Data
	self.Gathered = {}
	self.TotalGathered = 0
	self.Elapsed = 0
	self.Seconds = 0
	self.GoldValue = GetMoney() or 0
	self.GoldGained = 0
	self.GoldTimer = 0
	self.LastXP = UnitXP("player")
	self.LastMax = UnitXPMax("player")
	self.XPGained = 0
end

function Gathering:FormatFullTime(seconds)
	local Days = floor(seconds / 86400)
	local Hours = floor((seconds % 86400) / 3600)
	local Mins = floor((seconds % 3600) / 60)

	if (Days > 0) then
		return format("%dd", Days)
	elseif (Hours > 0) then
		return format("%dh %sm", Hours, Mins)
	elseif (Mins > 0) then
		return format("%sm", Mins)
	else
		return format("%ss", floor(seconds))
	end
end

function Gathering:Comma(number)
	if (not number) then
		return
	end

   	local Left, Number = match(floor(number + 0.5), "^([^%d]*%d)(%d+)(.-)$")

	return Left and Left .. string.reverse(gsub(string.reverse(Number), "(%d%d%d)", "%1,")) or number
end

-- Generic counting of basic numbers
function Gathering:AddStat(stat, value)
	if (not GatheringStats) then
		GatheringStats = {}
	end

	if (not GatheringStats[stat]) then
		GatheringStats[stat] = 0
	end

	GatheringStats[stat] = GatheringStats[stat] + value
end

-- Generic counting of item types
function Gathering:AddItemStat(id, value)
	if (not GatheringItemStats) then
		GatheringItemStats = {}
	end

	if (not GatheringItemStats[id]) then
		GatheringItemStats[id] = 0
	end

	GatheringItemStats[id] = GatheringItemStats[id] + value
end

Gathering.TrackedItemTypes = {
	[Enum.ItemClass.Consumable] = {},
	[Enum.ItemClass.Weapon] = {},
	[Enum.ItemClass.Armor] = {},
	[Enum.ItemClass.Tradegoods] = {},
	[Enum.ItemClass.Miscellaneous] = {},
	[Enum.ItemClass.Questitem] = {},
}

function Gathering:UpdateWeaponTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Axe1H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Axe2H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Bows] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Guns] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Mace1H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Mace2H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Polearm] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Sword1H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Sword2H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Warglaive] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Staff] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Bearclaw] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Catclaw] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Unarmed] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Generic] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Dagger] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Thrown] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Crossbow] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Wand] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Fishingpole] = value
end

function Gathering:UpdateArmorTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Generic] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Cloth] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Leather] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Mail] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Plate] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Cosmetic] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Shield] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Libram] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Idol] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Totem] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Sigil] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Relic] = value
end

function Gathering:UpdateJewelcraftingTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][4] = value
end

function Gathering:UpdateClothTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][5] = value
end

function Gathering:UpdateLeatherTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][6] = value
end

function Gathering:UpdateOreTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][7] = value
end

function Gathering:UpdateCookingTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][0] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][8] = value
end

function Gathering:UpdateHerbTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][9] = value
end

function Gathering:UpdateEnchantingTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][12] = value
end

function Gathering:UpdateHolidayTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Holiday] = value
end

function Gathering:UpdateMountTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Mount] = value
end

function Gathering:UpdateConsumableTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][1] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][2] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][3] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][4] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][5] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][6] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][7] = value
end

function Gathering:UpdateReagentTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Reagent] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][10] = value
end

function Gathering:UpdateOtherTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Other] = value
end

function Gathering:UpdateQuestTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Questitem][0] = value
end

local ScrollIgnoredItems = function(self)
	local First = false

	for i = 1, #self.IgnoredItems do
		if (i >= self.Offset) and (i < self.Offset + 10) then
			if (not First) then
				self.IgnoredItems[i]:SetPoint("TOPLEFT", self.IgnoredList, 4, -4)
				First = true
			else
				self.IgnoredItems[i]:SetPoint("TOPLEFT", self.IgnoredItems[i-1], "BOTTOMLEFT", 0, -2)
			end

			self.IgnoredItems[i]:Show()
		else
			self.IgnoredItems[i]:Hide()
		end
	end
end

function Gathering:AddIgnoredItem(text)
	if (text == "") then
		return
	end

	local ID = tonumber(text)
	local Page = Gathering:GetPage("Ignore")
	local Name, Link = GetItemInfo(ID or text)

	if ID then
		if GatheringIgnore[ID] then
			print(Link .. " is already ignored")

			return
		end

		GatheringIgnore[ID] = true

		print(format(ERR_IGNORE_ADDED_S, Link or Name))
	else
		if GatheringIgnore[text] then
			print(text .. " is already ignored")

			return
		end

		GatheringIgnore[text] = true

		print(format(ERR_IGNORE_ADDED_S, Link or text))
	end

	if (Name and Link) then
		local Line = CreateFrame("Frame", nil, Page, "BackdropTemplate")
		Line:SetSize(Page.IgnoredList:GetWidth() - 24, 22)
		Line.Item = ID

		Line.Text = Line:CreateFontString(nil, "OVERLAY")
		Line.Text:SetFont(SharedMedia:Fetch("font", Gathering.Settings["window-font"]), 12, "")
		Line.Text:SetPoint("LEFT", Line, 5, 0)
		Line.Text:SetJustifyH("LEFT")
		Line.Text:SetShadowColor(0, 0, 0)
		Line.Text:SetShadowOffset(1, -1)
		Line.Text:SetText(Link)

		Line.CloseButton = CreateFrame("Frame", nil, Line)
		Line.CloseButton:SetPoint("RIGHT", Line, 0, 0)
		Line.CloseButton:SetSize(24, 24)
		Line.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
		Line.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
		Line.CloseButton:SetScript("OnMouseUp", function(self) Gathering:RemoveIgnoredItem(self:GetParent().Item) end)

		Line.CloseButton.Texture = Line.CloseButton:CreateTexture(nil, "OVERLAY")
		Line.CloseButton.Texture:SetPoint("CENTER", Line.CloseButton, 0, -0.5)
		Line.CloseButton.Texture:SetTexture("Interface\\AddOns\\Gathering\\Assets\\HydraUIClose.tga")

		tinsert(Page.IgnoredItems, Line)

		Page.ScrollBar:SetMinMaxValues(1, math.max(1, #Page.IgnoredItems - 9))

		ScrollIgnoredItems(Page)
	end
end

function Gathering:RemoveIgnoredItem(text)
	if ((not GatheringIgnore) or (text == "")) then
		return
	end

	local ID = tonumber(text)

	if ID then
		GatheringIgnore[ID] = nil
	else
		GatheringIgnore[text] = nil
	end

	local Name, Link = GetItemInfo(ID)

	if Link then
		print(format(L["%s is now being unignored."], Link))
	else
		print(format(L["%s is now being unignored."], text))
	end

	local Page = Gathering:GetPage("Ignore")

	for i = 1, #Page.IgnoredItems do
		if (Page.IgnoredItems[i].Item == ID) then
			Page.IgnoredItems[i]:Hide()

			table.remove(Page.IgnoredItems, i)

			Page.ScrollBar:SetMinMaxValues(1, math.max(1, #Page.IgnoredItems - 9))

			ScrollIgnoredItems(Page)

			return
		end
	end
end

function Gathering:SetFrameWidth(text)
	Gathering:SetWidth(tonumber(self:GetText()))
end

function Gathering:SetFrameHeight(text)
	Gathering:SetHeight(tonumber(self:GetText()))
end

function Gathering:ToggleTimerPanel(value)
	if (value and (not Gathering:GetScript("OnUpdate"))) then
		Gathering:Hide()
	else
		Gathering:Show()
	end
end

function Gathering:UpdateTooltipFont()
	local Font = SharedMedia:Fetch("font", self.Settings["window-font"], "")

	if self.Tooltip.NineSlice then
		self.Tooltip.NineSlice:Hide()
	end

	for i = 1, self.Tooltip:GetNumRegions() do
		local Region = select(i, self.Tooltip:GetRegions())

		if (Region:GetObjectType() == "FontString") then
			Region:SetFont(Font, 12)
			Region:SetShadowColor(0, 0, 0)
			Region:SetShadowOffset(1, -1)
		end
	end
end

function Gathering:CopperToGold(copper)
	local Gold = floor(copper / (100 * 100))
	local Silver = floor((copper - (Gold * 100 * 100)) / 100)
	local Copper = floor(copper % 100)
	local Separator = ""
	local String = ""

	if (Gold > 0) then
		String = Gold .. "|cffffe02eg|r"
		Separator = " "
	end

	if (Silver > 0) then
		String = String .. Separator .. Silver .. "|cffd6d6d6s|r"
		Separator = " "
	end

	if (Copper > 0 or String == "") then
		String = String .. Separator .. Copper .. "|cfffc8d2bc|r"
	end

	return String
end

function Gathering:OnUpdate(ela)
	self.Elapsed = self.Elapsed + ela

	if (self.Elapsed >= self.Int) then
		self.Seconds = self.Seconds + self.Int

		if (self.Settings.DisplayMode == "TIME") then
			self.Text:SetText(date("!%X", self.Seconds))
		elseif (self.Settings.DisplayMode == "GPH") then
			if (self.GoldGained > 0) then
				self.Text:SetFormattedText(L["GPH: %s"], self:CopperToGold(floor((self.GoldGained / max(GetTime() - self.GoldTimer, 1)) * 60 * 60)))
			end
		end

		if self.MouseIsOver then
			self:OnLeave()
			self:OnEnter()
		end

		self.Elapsed = 0
	end
end

function Gathering:StartTimer()
	if (self.Settings["hide-idle"] and not self:IsVisible()) then
		self:Show()
	end

	self:SetScript("OnUpdate", self.OnUpdate)
end

function Gathering:PauseTimer()
	self:SetScript("OnUpdate", nil)
end

function Gathering:ToggleTimer()
	if (self.Settings.DisplayMode ~= "TIME") then
		return
	end

	if (not self:GetScript("OnUpdate")) then
		self:StartTimer()
	else
		self:PauseTimer()
	end
end

function Gathering:Reset()
	self:SetScript("OnUpdate", nil)

	wipe(self.Gathered)

	self.TotalGathered = 0
	self.Seconds = 0
	self.Elapsed = 0
	self.GoldValue = GetMoney() or 0
	self.GoldGained = 0
	self.GoldTimer = 0
	self.LastXP = UnitXP("player")
	self.LastMax = UnitXPMax("player")
	self.XPGained = 0
	self.XPStartTime = GetTime()

	if (self.Settings.DisplayMode == "TIME") then
		self.Text:SetText(date("!%X", 0))
	elseif (self.Settings.DisplayMode == "GPH") then
		self.Text:SetFormattedText(L["GPH: %s"], self:CopperToGold(0))
		self.Int = 2
	elseif (self.Settings.DisplayMode == "GOLD") then
		self.Text:SetText(self:CopperToGold(0))
	elseif (self.Settings.DisplayMode == "TOTAL") then
		self.Text:SetFormattedText(L["Total: %s"], 0)
	end

	if self.MouseIsOver then
		self:OnLeave()
	end

	if self.Settings["hide-idle"] then
		self:Hide()
	end
end

function Gathering:OnResetAccept()
	Gathering:ToggleResetPopup()
	Gathering:Reset()

	self.Text:SetPoint("CENTER", self, 0, -0.5)
end

function Gathering:OnResetCancel()
	Gathering:ToggleResetPopup()

	self.Text:SetPoint("CENTER", self, 0, -0.5)
end

function Gathering:PopupButtonOnEnter()
	self.Text:SetTextColor(1, 1, 0)
end

function Gathering:PopupButtonOnLeave()
	self.Text:SetTextColor(1, 1, 1)
end

function Gathering:PopupButtonOnMouseDown()
	self.Text:SetPoint("CENTER", self, 1, -1.5)
end

function Gathering:ToggleResetPopup()
	if (not self.Popup) then
		local Popup = CreateFrame("Frame", nil, self, "BackdropTemplate")
		Popup:SetSize(240, 80)
		Popup:SetPoint("CENTER", UIParent, 0, 120)
		Popup:SetBackdrop({bgFile = BlankTexture, edgeFile = BlankTexture, edgeSize = 1})
		Popup:SetBackdropColor(0.2, 0.2, 0.2, 0.85)
		Popup:SetBackdropBorderColor(0, 0, 0)
		Popup:SetClampedToScreen(true)
		Popup:RegisterForDrag("LeftButton")
		Popup:SetScript("OnDragStart", Popup.StartMoving)
		Popup:SetScript("OnDragStop", Popup.StopMovingOrSizing)

		Popup.Text = Popup:CreateFontString(nil, "OVERLAY")
		Popup.Text:SetPoint("TOP", Popup, 0, -4)
		Popup.Text:SetSize(234, 40)
		Popup.Text:SetJustifyH("CENTER")
		Popup.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 14, "")
		Popup.Text:SetText(L["Are you sure you would like to reset current data?"])

		Popup.Accept = CreateFrame("Frame", nil, Popup, "BackdropTemplate")
		Popup.Accept:SetSize(114, 20)
		Popup.Accept:SetPoint("BOTTOMLEFT", Popup, 4, 4)
		Popup.Accept:SetBackdrop({bgFile = BlankTexture, edgeFile = BlankTexture, edgeSize = 1})
		Popup.Accept:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
		Popup.Accept:SetBackdropBorderColor(0, 0, 0)
		Popup.Accept:SetScript("OnMouseUp", self.OnResetAccept)
		Popup.Accept:SetScript("OnEnter", self.PopupButtonOnEnter)
		Popup.Accept:SetScript("OnLeave", self.PopupButtonOnLeave)
		Popup.Accept:SetScript("OnMouseDown", self.PopupButtonOnMouseDown)

		Popup.Accept.Text = Popup.Accept:CreateFontString(nil, "OVERLAY")
		Popup.Accept.Text:SetPoint("CENTER", Popup.Accept, 0, -0.5)
		Popup.Accept.Text:SetJustifyH("CENTER")
		Popup.Accept.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 14, "")
		Popup.Accept.Text:SetText(RESET)

		Popup.Cancel = CreateFrame("Frame", nil, Popup, "BackdropTemplate")
		Popup.Cancel:SetSize(114, 20)
		Popup.Cancel:SetPoint("LEFT", Popup.Accept, "RIGHT", 4, 0)
		Popup.Cancel:SetBackdrop({bgFile = BlankTexture, edgeFile = BlankTexture, edgeSize = 1})
		Popup.Cancel:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
		Popup.Cancel:SetBackdropBorderColor(0, 0, 0)
		Popup.Cancel:SetScript("OnMouseUp", self.OnResetCancel)
		Popup.Cancel:SetScript("OnEnter", self.PopupButtonOnEnter)
		Popup.Cancel:SetScript("OnLeave", self.PopupButtonOnLeave)
		Popup.Cancel:SetScript("OnMouseDown", self.PopupButtonOnMouseDown)

		Popup.Cancel.Text = Popup.Cancel:CreateFontString(nil, "OVERLAY")
		Popup.Cancel.Text:SetPoint("CENTER", Popup.Cancel, 0, -0.5)
		Popup.Cancel.Text:SetJustifyH("CENTER")
		Popup.Cancel.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 14, "")
		Popup.Cancel.Text:SetText(CANCEL)

		self.Popup = Popup

		return
	end

	if self.Popup:IsShown() then
		self.Popup:Hide()
	else
		self.Popup:Show()
	end
end

function Gathering:FormatTime(seconds)
	if (seconds > 59) then
		return format("%dm", ceil(seconds / 60))
	else
		return format("%0.1fs", seconds)
	end
end

function Gathering:CreateHeader(page, text)
	local Header = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Header:SetSize(page:GetWidth() - 8, 22)
	Header:SetBackdrop(Outline)
	Header:SetBackdropColor(0.25, 0.266, 0.294)

	Header.Text = Header:CreateFontString(nil, "OVERLAY")
	Header.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	Header.Text:SetPoint("LEFT", Header, 5, 0)
	Header.Text:SetJustifyH("LEFT")
	Header.Text:SetShadowColor(0, 0, 0)
	Header.Text:SetShadowOffset(1, -1)
	Header.Text:SetText(format("|cffFFC44D%s|r", text))

	tinsert(page, Header)
end

function Gathering:UpdateSettingValue(key, value)
	if (value == self.DefaultSettings[key]) then
		GatheringSettings[key] = nil
	else
		GatheringSettings[key] = value
	end

	self.Settings[key] = value
end

function Gathering:CheckBoxOnMouseUp()
	if (Gathering.Settings[self.Setting] == true) then
		self.Tex:SetVertexColor(0.125, 0.133, 0.145)
		Gathering:UpdateSettingValue(self.Setting, false)

		if self.Hook then
			self:Hook(false)
		end
	else
		self.Tex:SetVertexColor(1, 0.7686, 0.3019)
		Gathering:UpdateSettingValue(self.Setting, true)

		if self.Hook then
			self:Hook(true)
		end
	end
end

function Gathering:CreateCheckbox(page, key, text, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(129, 22)

	local Checkbox = CreateFrame("Frame", nil, Line)
	Checkbox:SetSize(18, 18)
	Checkbox:SetPoint("LEFT", Line, 4, 0)
	Checkbox:SetScript("OnMouseUp", self.CheckBoxOnMouseUp)
	Checkbox.Setting = key

	Checkbox.Tex = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Tex:SetTexture(BlankTexture)
	Checkbox.Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)

	Checkbox.Text = Checkbox:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 6, 0)
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetShadowColor(0, 0, 0)
	Checkbox.Text:SetShadowOffset(1, -1)
	Checkbox.Text:SetText(text)

	if self.Settings[key] then
		Checkbox.Tex:SetVertexColor(1, 0.7686, 0.3019)
	else
		Checkbox.Tex:SetVertexColor(0.125, 0.133, 0.145)
	end

	if func then
		Checkbox.Hook = func
	end

	tinsert(page, Line)
end

local ListOnEnter = function(self)
	self.Tex:SetVertexColor(0.3, 0.3, 0.34)
end

local ListOnLeave = function(self)
	self.Tex:SetVertexColor(0.184, 0.192, 0.211)
end

local WidgetOnLeave = function(self)
	self.Tex:SetVertexColor(0.125, 0.133, 0.145)
end

function Gathering:EditBoxOnEnterPressed()
	local Text = self:GetText()

	self:SetAutoFocus(false)
	self:ClearFocus()

	if self.Hook then
		self:Hook(Text)
	end

	self:SetText(L["Ignore items"])
end

function Gathering:OnEscapePressed()
	self:SetAutoFocus(false)
	self:ClearFocus()
	self:SetText(L["Ignore items"])
end

function Gathering:EditBoxOnMouseDown()
	local Type, ID, Link = GetCursorInfo()

	self:SetAutoFocus(true)

	if (Type and Type == "item") then
		self:SetText(ID)
		self.Icon:SetTexture(C_Item.GetItemIconByID(ID))
	else
		self:SetText("")
	end

	ClearCursor()
end

function Gathering:OnEditFocusLost()
	self:SetText("")
	self.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")

	ClearCursor()
end

function Gathering:OnEditChar(text)
	local ID = tonumber(self:GetText())

	if (not ID) then
		self.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")

		return
	end

	local IconID = C_Item.GetItemIconByID(ID)

	if (IconID and IconID ~= 134400) then
		self.Icon:SetTexture(IconID)
	else
		self.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	end
end

function Gathering:DiscordOnEscapePressed()
	self:SetAutoFocus(false)
	self:ClearFocus()
	self:SetText("discord.gg/XefDFa6nJR")
end

function Gathering:DiscordOnMouseDown()
	self:SetAutoFocus(true)
	self:HighlightText()
end

function Gathering:DiscordButtonOnMouseDown()
	local Parent = self:GetParent()

	Parent:SetAutoFocus(true)
	Parent:HighlightText()
end

function Gathering:CreateEditBox(page, text, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local EditBox = CreateFrame("EditBox", nil, Line)
	EditBox:SetSize(170, 22)
	EditBox:SetPoint("LEFT", Line, -1, 0)
	EditBox:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	EditBox:SetShadowColor(0, 0, 0)
	EditBox:SetShadowOffset(1, -1)
	EditBox:SetJustifyH("LEFT")
	EditBox:SetAutoFocus(false)
	EditBox:EnableKeyboard(true)
	EditBox:EnableMouse(true)
	EditBox:SetMaxLetters(255)
	EditBox:SetTextInsets(5, 0, 0, 0)
	EditBox:SetText(text)
	EditBox:SetScript("OnEnterPressed", self.EditBoxOnEnterPressed)
	EditBox:SetScript("OnEscapePressed", self.OnEscapePressed)
	EditBox:SetScript("OnMouseDown", self.EditBoxOnMouseDown)
	EditBox:SetScript("OnEditFocusLost", self.OnEditFocusLost)
	EditBox:SetScript("OnEnter", ListOnEnter)
	EditBox:SetScript("OnLeave", WidgetOnLeave)
	EditBox:SetScript("OnChar", self.OnEditChar)

	EditBox.Tex = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Tex:SetTexture(BlankTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.125, 0.133, 0.145)

	EditBox.Icon = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Icon:SetPoint("LEFT", EditBox, "RIGHT", 1, 0)
	EditBox.Icon:SetSize(20, 20)
	EditBox.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	EditBox.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	if func then
		EditBox.Hook = func
	end

	tinsert(page, Line)
end

function Gathering:NumberEditBoxOnEnterPressed()
	local Text = self:GetText()

	self:SetAutoFocus(false)
	self:ClearFocus()

	Gathering:UpdateSettingValue(self.Setting, tonumber(Text))

	if self.Hook then
		self:Hook(tonumber(Text))
	end
end

function Gathering:NumberOnEscapePressed()
	self:SetAutoFocus(false)
	self:ClearFocus()
end

function Gathering:NumberEditBoxOnMouseDown()
	self:SetAutoFocus(true)
	ClearCursor()
end

function Gathering:NumberOnEditFocusLost()
	ClearCursor()
end

function Gathering:CreateNumberEditBox(page, key, text, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local EditBox = CreateFrame("EditBox", nil, Line)
	EditBox:SetSize(60, 22)
	EditBox:SetPoint("LEFT", Line, 0, 0)
	EditBox:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	EditBox:SetShadowColor(0, 0, 0)
	EditBox:SetShadowOffset(1, -1)
	EditBox:SetJustifyH("LEFT")
	EditBox:SetAutoFocus(false)
	EditBox:EnableKeyboard(true)
	EditBox:EnableMouse(true)
	EditBox:SetMaxLetters(3)
	EditBox:SetNumeric(true)
	EditBox:SetTextInsets(5, 0, 0, 0)
	EditBox:SetText(self.Settings[key])
	EditBox:SetScript("OnEnterPressed", self.NumberEditBoxOnEnterPressed)
	EditBox:SetScript("OnEscapePressed", self.NumberOnEscapePressed)
	EditBox:SetScript("OnMouseDown", self.NumberEditBoxOnMouseDown)
	EditBox:SetScript("OnEnter", ListOnEnter)
	EditBox:SetScript("OnLeave", WidgetOnLeave)
	EditBox.Setting = key

	EditBox.Tex = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Tex:SetTexture(BlankTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.125, 0.133, 0.145)

	EditBox.Text = EditBox:CreateFontString(nil, "OVERLAY")
	EditBox.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	EditBox.Text:SetPoint("LEFT", EditBox, "RIGHT", 6, 0)
	EditBox.Text:SetJustifyH("LEFT")
	EditBox.Text:SetShadowColor(0, 0, 0)
	EditBox.Text:SetShadowOffset(1, -1)
	EditBox.Text:SetText(text)

	if func then
		EditBox.Hook = func
	end

	tinsert(page, Line)
end

function Gathering:DiscordEditBoxOnMouseDown()
	self:HighlightText()
	self:SetAutoFocus(true)
end

function Gathering:DiscordEditBoxOnEnterPressed()
	self:SetAutoFocus(false)
	self:ClearFocus()
	self:SetText("discord.gg/XefDFa6nJR")
end

function Gathering:CreateDiscordEditBox(page)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local EditBox = CreateFrame("EditBox", nil, Line)
	EditBox:SetSize(190, 22)
	EditBox:SetPoint("LEFT", Line, 0, 0)
	EditBox:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	EditBox:SetShadowColor(0, 0, 0)
	EditBox:SetShadowOffset(1, -1)
	EditBox:SetJustifyH("LEFT")
	EditBox:SetAutoFocus(false)
	EditBox:EnableKeyboard(true)
	EditBox:EnableMouse(true)
	EditBox:SetTextInsets(5, 0, 0, 0)
	EditBox:SetText("discord.gg/XefDFa6nJR")
	EditBox:SetScript("OnEnterPressed", self.DiscordEditBoxOnEnterPressed)
	EditBox:SetScript("OnEscapePressed", self.DiscordEditBoxOnEnterPressed)
	EditBox:SetScript("OnMouseDown", self.DiscordEditBoxOnMouseDown)

	EditBox.Tex = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Tex:SetTexture(BlankTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.125, 0.133, 0.145)

	EditBox.Text = EditBox:CreateFontString(nil, "OVERLAY")
	EditBox.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	EditBox.Text:SetPoint("LEFT", EditBox, "RIGHT", 3, 0)
	EditBox.Text:SetJustifyH("LEFT")
	EditBox.Text:SetShadowColor(0, 0, 0)
	EditBox.Text:SetShadowOffset(1, -1)
	EditBox.Text:SetText(text)

	tinsert(page, Line)
end

local ScrollSelections = function(self)
	local First = false

	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + MaxSelections - 1) then
			if (not First) then
				self[i]:SetPoint("TOPLEFT", self, -1, 1)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 0)
			end

			self[i]:Show()
		else
			self[i]:Hide()
		end
	end

	if self.ScrollBar then
		self.ScrollBar:SetValue(self.Offset)
	end
end

local SelectionOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1

		if (self.Offset > (#self - (MaxSelections - 1))) then
			self.Offset = self.Offset - 1
		end
	end

	ScrollSelections(self)
end

local SelectionScrollBarOnValueChanged = function(self)
	local Parent = self:GetParent()
	Parent.Offset = self:GetValue()

	ScrollSelections(Parent)
end

local ScrollBarOnEnter = function(self)
	self:GetThumbTexture():SetVertexColor(0.4, 0.4, 0.4)
end

local ScrollBarOnLeave = function(self)
	if (not self.OverrideThumb) then
		self:GetThumbTexture():SetVertexColor(0.25, 0.266, 0.294)
	end
end

local ScrollBarOnMouseDown = function(self)
	self.OverrideThumb = true
	self:GetThumbTexture():SetVertexColor(0.4, 0.4, 0.4)
end

local ScrollBarOnMouseUp = function(self)
	self.OverrideThumb = false
	self:GetThumbTexture():SetVertexColor(0.25, 0.266, 0.294)
end

local SelectionScrollBarOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent(), delta)
end

local FontListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()

	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Key), 12, "")
	Selection.Current:SetText(self.Key)

	Selection.List:Hide()

	Gathering:UpdateSettingValue(Selection.Setting, self.Key)

	if Selection.Hook then
		Selection:Hook(self.Key)
	end

	Selection.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowDown.tga")
end

local FontSelectionOnMouseUp = function(self)
	if (not self.List) then
		self.List = CreateFrame("Frame", nil, self)
		self.List:SetSize(150, (20 * MaxSelections) - 2) -- 128
		self.List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		self.List.Offset = 1
		self.List:EnableMouseWheel(true)
		self.List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		self.List:SetFrameStrata("HIGH")
		self.List:SetFrameLevel(20)
		self.List:Hide()

		self.List.Tex = self.List:CreateTexture(nil, "ARTWORK")
		self.List.Tex:SetTexture(BlankTexture)
		self.List.Tex:SetPoint("TOPLEFT", self.List, -2, 2)
		self.List.Tex:SetPoint("BOTTOMRIGHT", self.List, 2, -2)
		self.List.Tex:SetVertexColor(0.125, 0.133, 0.145)

		for Key, Path in next, self.Selections do
			local Selection = CreateFrame("Frame", nil, self.List)
			Selection:SetSize(140, 20)
			Selection.Key = Key
			Selection.Path = Path
			Selection:SetScript("OnMouseUp", FontListOnMouseUp)
			Selection:SetScript("OnEnter", ListOnEnter)
			Selection:SetScript("OnLeave", ListOnLeave)

			Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
			Selection.Tex:SetTexture(BlankTexture)
			Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Selection.Tex:SetVertexColor(0.184, 0.192, 0.211)

			Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
			Selection.Text:SetFont(Path, 12)
			Selection.Text:SetSize(134, 18)
			Selection.Text:SetPoint("LEFT", Selection, 5, 0)
			Selection.Text:SetJustifyH("LEFT")
			Selection.Text:SetShadowColor(0, 0, 0)
			Selection.Text:SetShadowOffset(1, -1)
			Selection.Text:SetText(Key)

			tinsert(self.List, Selection)
		end

		table.sort(self.List, function(a, b)
			return a.Key < b.Key
		end)

		local ScrollBar = CreateFrame("Slider", nil, self.List)
		ScrollBar:SetPoint("TOPRIGHT", self.List, 0, 0)
		ScrollBar:SetPoint("BOTTOMRIGHT", self.List, 0, 0)
		ScrollBar:SetWidth(10)
		ScrollBar:SetThumbTexture(BlankTexture)
		ScrollBar:SetOrientation("VERTICAL")
		ScrollBar:SetValueStep(1)
		ScrollBar:SetMinMaxValues(1, (#self.List - (MaxSelections - 1)))
		ScrollBar:SetValue(1)
		ScrollBar:SetObeyStepOnDrag(true)
		ScrollBar:EnableMouseWheel(true)
		ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
		ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
		ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
		ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
		ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
		ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)

		local Thumb = ScrollBar:GetThumbTexture()
		Thumb:SetSize(10, 18)
		Thumb:SetVertexColor(0.25, 0.266, 0.294)

		self.List.ScrollBar = ScrollBar

		ScrollSelections(self.List)
	end

	if self.List:IsShown() then
		self.List:Hide()
		self.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowDown.tga")
	else
		self.List:Show()
		self.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowUp.tga")
	end
end

function Gathering:CreateFontSelection(page, key, text, selections, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local Selection = CreateFrame("Frame", nil, Line)
	Selection:SetSize(Line:GetWidth(), 22)
	Selection:SetPoint("LEFT", Line, 0, 0)
	Selection:SetScript("OnMouseUp", FontSelectionOnMouseUp)
	Selection:SetScript("OnEnter", ListOnEnter)
	Selection:SetScript("OnLeave", WidgetOnLeave)
	Selection.Selections = selections
	Selection.Setting = key

	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BlankTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.125, 0.133, 0.145)

	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowDown.tga")
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(1, 0.7686, 0.3019)

	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings[key]), 12, "")
	Selection.Current:SetSize(122, 18)
	Selection.Current:SetPoint("LEFT", Selection, 5, -0.5)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(self.Settings[key])

	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)

	if func then
		Selection.Hook = func
	end

	tinsert(page, Line)
end

local ListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()

	Selection.Current:SetText(self.Key)
	Selection.List:Hide()

	Gathering:UpdateSettingValue(Selection.Setting, self.Value)
	--Gathering:UpdateSettingValue(Selection.Setting, self.Key)

	if Selection.Hook then
		Selection:Hook(self.Value)
		--Selection:Hook(self.Key)
	end

	Selection.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowDown.tga")
end

local SelectionOnMouseUp = function(self)
	if (not self.List) then
		self.List = CreateFrame("Frame", nil, self)
		self.List:SetSize(150, 22 * MaxSelections) -- 128
		self.List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		self.List.Offset = 1
		self.List:EnableMouseWheel(true)
		self.List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		self.List:SetFrameStrata("HIGH")
		self.List:SetFrameLevel(20)
		self.List:Hide()

		self.List.Tex = self.List:CreateTexture(nil, "ARTWORK")
		self.List.Tex:SetTexture(BlankTexture)
		self.List.Tex:SetPoint("TOPLEFT", self.List, -2, 2)
		self.List.Tex:SetPoint("BOTTOMRIGHT", self.List, 2, -2)
		self.List.Tex:SetVertexColor(0.125, 0.133, 0.145)

		for Key, Value in next, self.Selections do
			local Selection = CreateFrame("Frame", nil, self.List)
			Selection:SetSize(140, 22)
			Selection.Key = Key
			Selection.Value = Value
			Selection:SetScript("OnMouseUp", ListOnMouseUp)
			Selection:SetScript("OnEnter", ListOnEnter)
			Selection:SetScript("OnLeave", ListOnLeave)

			Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
			Selection.Tex:SetTexture(BlankTexture)
			Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Selection.Tex:SetVertexColor(0.184, 0.192, 0.211)

			Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
			Selection.Text:SetFont(SharedMedia:Fetch("font", Gathering.Settings["window-font"]), 12, "")
			Selection.Text:SetSize(134, 18)
			Selection.Text:SetPoint("LEFT", Selection, 5, 0)
			Selection.Text:SetJustifyH("LEFT")
			Selection.Text:SetShadowColor(0, 0, 0)
			Selection.Text:SetShadowOffset(1, -1)
			Selection.Text:SetText(Key)

			tinsert(self.List, Selection)
		end

		table.sort(self.List, function(a, b)
			return a.Key < b.Key
		end)

		if #self.List > (MaxSelections - 1) then
			local ScrollBar = CreateFrame("Slider", nil, self.List)
			ScrollBar:SetPoint("TOPLEFT", self.List, "TOPRIGHT", 0, 0)
			ScrollBar:SetPoint("BOTTOMLEFT", self.List, "BOTTOMRIGHT", 0, 0)
			ScrollBar:SetWidth(10)
			ScrollBar:SetThumbTexture(BlankTexture)
			ScrollBar:SetOrientation("VERTICAL")
			ScrollBar:SetValueStep(1)
			ScrollBar:SetMinMaxValues(1, (#self.List - (MaxSelections - 1)))
			ScrollBar:SetValue(1)
			ScrollBar:SetObeyStepOnDrag(true)
			ScrollBar:EnableMouseWheel(true)
			ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
			ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
			ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
			ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
			ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
			ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)

			local Thumb = ScrollBar:GetThumbTexture()
			Thumb:SetSize(10, 18)
			Thumb:SetVertexColor(0.25, 0.266, 0.294)

			self.List.ScrollBar = ScrollBar
		else
			self.List:SetHeight((22 * #self.List) - 2)
			self.List:SetWidth(139)
		end

		ScrollSelections(self.List)
	end

	if self.List:IsShown() then
		self.List:Hide()
		self.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowDown.tga")
	else
		self.List:Show()
		self.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowUp.tga")
	end
end

function Gathering:CreateSelection(page, key, text, selections, func)
	local Line = CreateFrame("Frame", nil, page)
	Line:SetSize(page:GetWidth() - 8, 22)

	local Selection = CreateFrame("Frame", nil, Line)
	Selection:SetSize(Line:GetWidth(), 22)
	Selection:SetPoint("LEFT", Line, 0, 0)
	Selection:SetScript("OnMouseUp", SelectionOnMouseUp)
	Selection:SetScript("OnEnter", ListOnEnter)
	Selection:SetScript("OnLeave", WidgetOnLeave)
	Selection.Selections = selections
	Selection.Setting = key

	local Name

	for k, v in next, selections do
		if (v == self.Settings[key]) then
			Name = k
		end
	end

	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BlankTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.125, 0.133, 0.145)

	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture("Interface\\AddOns\\Gathering\\Assets\\GatheringArrowDown.tga")
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(1, 0.7686, 0.3019)

	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	Selection.Current:SetSize(122, 18)
	Selection.Current:SetPoint("LEFT", Selection, 5, -0.5)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	--Selection.Current:SetText(selections[self.Settings[key]])
	Selection.Current:SetText(Name)

	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)

	if func then
		Selection.Hook = func
	end

	tinsert(page, Line)
end

local Scroll = function(self)
	local First = false

	for i = 1, #Gathering.GUI.LeftWidgets do
		if (i >= self.Offset) and (i <= self.Offset + MaxWidgets - 1) then
			if (not First) then
				Gathering.GUI.LeftWidgets[i]:SetPoint("TOPLEFT", Gathering.GUI.LeftWidgets, 4, -4)
				First = true
			else
				Gathering.GUI.LeftWidgets[i]:SetPoint("TOPLEFT", Gathering.GUI.LeftWidgets[i-1], "BOTTOMLEFT", 0, -2)
			end

			Gathering.GUI.LeftWidgets[i]:Show()
		else
			Gathering.GUI.LeftWidgets[i]:Hide()
		end
	end

	First = false

	for i = 1, #Gathering.GUI.RightWidgets do
		if (i >= self.Offset) and (i <= self.Offset + MaxWidgets - 1) then
			if (not First) then
				Gathering.GUI.RightWidgets[i]:SetPoint("TOPLEFT", Gathering.GUI.RightWidgets, 4, -4)
				First = true
			else
				Gathering.GUI.RightWidgets[i]:SetPoint("TOPLEFT", Gathering.GUI.RightWidgets[i-1], "BOTTOMLEFT", 0, -2)
			end

			Gathering.GUI.RightWidgets[i]:Show()
		else
			Gathering.GUI.RightWidgets[i]:Hide()
		end
	end
end

local WindowOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1

		if (self.Offset > (Gathering.GUI.MaxScroll - (MaxWidgets - 1))) then
			self.Offset = self.Offset - 1
		end
	end

	Scroll(self)
	self.ScrollBar:SetValue(self.Offset)
end

local ScrollBarOnValueChanged = function(self, value)
	local Value = floor(value + 0.5)

	self.Parent.Offset = Value

	Scroll(self.Parent)
end

function Gathering:UpdateFontSetting(value)
	Gathering.Text:SetFont(SharedMedia:Fetch("font", value), 14, "")
	Gathering:UpdateTooltipFont()
end

function Gathering:UpdateDisplayMode(value)
	if (value == "TIME") then
		Gathering.Text:SetText(date("!%X", Gathering.Seconds))

		Gathering.Int = 1
	elseif (value == "GPH") then
		if (Gathering.GoldGained > 0) then
			Gathering.Text:SetFormattedText("GPH: %s", Gathering:CopperToGold(floor((Gathering.GoldGained / max(GetTime() - Gathering.GoldTimer, 1)) * 60 * 60)))
		else
			Gathering.Text:SetFormattedText("GPH: %s", Gathering:CopperToGold(0))
		end

		Gathering.Int = 2
	elseif (value == "GOLD") then
		Gathering.Text:SetText(Gathering:CopperToGold(Gathering.GoldGained))
	elseif (value == "TOTAL") then
		Gathering.Text:SetFormattedText("Total: %s", Gathering.TotalGathered)
	end
end

function Gathering:ShowPage(name)
	for i = 1, #self.Windows do
		if (self.Windows[i].Name == name) then
			self.Windows[i]:Show()
		else
			self.Windows[i]:Hide()
		end
	end
end

function Gathering:GetPage(name)
	for i = 1, #self.Windows do
		if (self.Windows[i].Name == name) then
			return self.Windows[i]
		end
	end
end

function Gathering:PageTabOnEnter()
	self:SetBackdropColor(0.25, 0.266, 0.294)
end

function Gathering:PageTabOnLeave()
	self:SetBackdropColor(0.184, 0.192, 0.211)
end

function Gathering:PageTabOnMouseUp()
	Gathering:ShowPage(self.Name)

	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 5, -0.5)
end

function Gathering:PageTabOnMouseDown()
	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 6, -1.5)
end

function Gathering:AddPage(name)
	local Tab = CreateFrame("Frame", nil, self.GUI.TabParent, "BackdropTemplate")
	Tab:SetSize(72, 22)
	Tab:SetBackdrop(Outline)
	Tab:SetBackdropColor(0.184, 0.192, 0.211)
	Tab:SetScript("OnEnter", self.PageTabOnEnter)
	Tab:SetScript("OnLeave", self.PageTabOnLeave)
	Tab:SetScript("OnMouseUp", self.PageTabOnMouseUp)
	Tab:SetScript("OnMouseDown", self.PageTabOnMouseDown)
	Tab.Name = name

	Tab.Text = Tab:CreateFontString(nil, "OVERLAY")
	Tab.Text:SetPoint("LEFT", Tab, 5, -0.5)
	Tab.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	Tab.Text:SetJustifyH("LEFT")
	Tab.Text:SetShadowColor(0, 0, 0)
	Tab.Text:SetShadowOffset(1, -1)
	Tab.Text:SetText(name)

	local Page = CreateFrame("Frame", nil, self.GUI.Window)
	Page:SetAllPoints()
	Page.Name = name

	table.insert(self.Tabs, Tab)
	table.insert(self.Windows, Page)

	return Page
end

function Gathering:SortWidgets(widgets)
	for i = 1, #widgets do
		if (i == 1) then
			widgets[i]:SetPoint("TOPLEFT", widgets, 4, -4)
		else
			widgets[i]:SetPoint("TOPLEFT", widgets[i-1], "BOTTOMLEFT", 0, -4)
		end
	end
end

function Gathering:SortWidgetsWide(widgets)
	for i = 1, #widgets do
		if (i == 1) then
			widgets[i]:SetPoint("TOPLEFT", widgets, 4, -30)
		elseif ((i - 1) % 3 == 0) then
			widgets[i]:SetPoint("TOPLEFT", widgets[i-3], "BOTTOMLEFT", 0, -4)
		else
			widgets[i]:SetPoint("LEFT", widgets[i-1], "RIGHT", 4, 0)
		end
	end
end

function Gathering:SetupTrackingPage(page)
	page.TopWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.TopWidgets:SetSize(page:GetWidth(), 133)
	page.TopWidgets:SetPoint("TOPLEFT", page, 0, 0)
	page.TopWidgets:EnableMouse(true)
	page.TopWidgets:SetBackdrop(Outline)
	page.TopWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	page.LeftWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.LeftWidgets:SetSize(199, 107)
	page.LeftWidgets:SetPoint("TOPLEFT", page.TopWidgets, "BOTTOMLEFT", 0, -6)
	page.LeftWidgets:EnableMouse(true)
	page.LeftWidgets:SetBackdrop(Outline)
	page.LeftWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	self:CreateHeader(page.TopWidgets, TRACKING)

	self:SortWidgets(page.TopWidgets)

	table.remove(page.TopWidgets, 1)

	self:CreateCheckbox(page.TopWidgets, "track-herbs", L["Herbs"], self.UpdateHerbTracking)
	self:CreateCheckbox(page.TopWidgets, "track-cloth", L["Cloth"], self.UpdateClothTracking)
	self:CreateCheckbox(page.TopWidgets, "track-leather", L["Leather"], self.UpdateLeatherTracking)
	self:CreateCheckbox(page.TopWidgets, "track-ore", L["Ore"], self.UpdateOreTracking)
	self:CreateCheckbox(page.TopWidgets, "track-jewelcrafting", L["Jewelcrafting"], self.UpdateJewelcraftingTracking)
	self:CreateCheckbox(page.TopWidgets, "track-enchanting", L["Enchanting"], self.UpdateEnchantingTracking)
	self:CreateCheckbox(page.TopWidgets, "track-cooking", L["Cooking"], self.UpdateCookingTracking)
	self:CreateCheckbox(page.TopWidgets, "track-reagents", L["Reagents"], self.UpdateReagentTracking)
	self:CreateCheckbox(page.TopWidgets, "track-consumable", L["Consumables"], self.UpdateConsumableTracking)
	self:CreateCheckbox(page.TopWidgets, "track-holiday", L["Holiday"], self.UpdateHolidayTracking)
	self:CreateCheckbox(page.TopWidgets, "track-quest", L["Quests"], self.UpdateQuestTracking)
	self:CreateCheckbox(page.TopWidgets, "track-xp", L["XP"])

	self:CreateHeader(page.LeftWidgets, MISCELLANEOUS)

	self:CreateCheckbox(page.LeftWidgets, "ignore-bop", L["Ignore Bind on Pickup"])
	self:CreateCheckbox(page.LeftWidgets, "IgnoreMailItems", L["Ignore mail items"])
	self:CreateCheckbox(page.LeftWidgets, "IgnoreMailMoney", L["Ignore mail gold"])

	self:SortWidgetsWide(page.TopWidgets)
	self:SortWidgets(page.LeftWidgets)
end

function Gathering:SetupSettingsPage(page)
	page.LeftWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.LeftWidgets:SetSize(199, 246)
	page.LeftWidgets:SetPoint("LEFT", page, 0, 0)
	page.LeftWidgets:EnableMouse(true)
	page.LeftWidgets:SetBackdrop(Outline)
	page.LeftWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	page.RightWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.RightWidgets:SetSize(198, 246)
	page.RightWidgets:SetPoint("LEFT", page.LeftWidgets, "RIGHT", 6, 0)
	page.RightWidgets:EnableMouse(true)
	page.RightWidgets:SetBackdrop(Outline)
	page.RightWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	self:CreateHeader(page.LeftWidgets, L["Display Mode"])
	self:CreateSelection(page.LeftWidgets, "DisplayMode", "", DisplayModes, self.UpdateDisplayMode)

	self:CreateHeader(page.LeftWidgets, L["Set Font"])

	self:CreateFontSelection(page.LeftWidgets, "window-font", "", Fonts, self.UpdateFontSetting)

	self:CreateHeader(page.LeftWidgets, WINDOW_SIZE_LABEL)

	self:CreateNumberEditBox(page.LeftWidgets, "WindowWidth", "Set Width", self.SetFrameWidth)
	self:CreateNumberEditBox(page.LeftWidgets, "WindowHeight", "Set Height", self.SetFrameHeight)

	self:CreateHeader(page.RightWidgets, MISCELLANEOUS)

	self:CreateCheckbox(page.RightWidgets, "hide-idle", L["Hide while idle"], self.ToggleTimerPanel)
	self:CreateCheckbox(page.RightWidgets, "ShowTooltipHelp", L["Show tooltip help"])

	self:SortWidgets(page.LeftWidgets)
	self:SortWidgets(page.RightWidgets)
end

local IgnoreWindowOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1

		if (self.Offset > (#page.IgnoredItems - 11)) then
			self.Offset = self.Offset - 1
		end
	end

	ScrollIgnoredItems(self)
	self.ScrollBar:SetValue(self.Offset)
end

local IgnoreScrollBarOnValueChanged = function(self, value)
	local Value = floor(value + 0.5)

	self.Parent.Offset = Value

	ScrollIgnoredItems(self.Parent)
end

function Gathering:SetupIgnorePage(page)
	page.LeftWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.LeftWidgets:SetSize(199, 246)
	page.LeftWidgets:SetPoint("LEFT", page, 0, 0)
	page.LeftWidgets:EnableMouse(true)
	page.LeftWidgets:SetBackdrop(Outline)
	page.LeftWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	page.IgnoredList = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.IgnoredList:SetSize(198, 246)
	page.IgnoredList:SetPoint("LEFT", page.LeftWidgets, "RIGHT", 6, 0)
	page.IgnoredList:EnableMouse(true)
	page.IgnoredList:SetBackdrop(Outline)
	page.IgnoredList:SetBackdropColor(0.184, 0.192, 0.211)

	page.IgnoredItems = {}

	self:CreateHeader(page.LeftWidgets, IGNORE)

	self:CreateEditBox(page.LeftWidgets, L["Ignore items"], self.AddIgnoredItem)

	self:SortWidgets(page.LeftWidgets)

	-- Add ignored items
	local Name, Link

	for ID in next, GatheringIgnore do
		Name, Link = GetItemInfo(ID)

		if (Name and Link) then
			local Line = CreateFrame("Frame", nil, page, "BackdropTemplate")
			Line:SetSize(page.IgnoredList:GetWidth() - 24, 22)
			Line.Item = ID

			Line.Text = Line:CreateFontString(nil, "OVERLAY")
			Line.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
			Line.Text:SetPoint("LEFT", Line, 5, 0)
			Line.Text:SetJustifyH("LEFT")
			Line.Text:SetShadowColor(0, 0, 0)
			Line.Text:SetShadowOffset(1, -1)
			Line.Text:SetText(Link or Name)

			Line.CloseButton = CreateFrame("Frame", nil, Line)
			Line.CloseButton:SetPoint("RIGHT", Line, 0, 0)
			Line.CloseButton:SetSize(24, 24)
			Line.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
			Line.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
			Line.CloseButton:SetScript("OnMouseUp", function(self) Gathering:RemoveIgnoredItem(self:GetParent().Item) end)

			Line.CloseButton.Texture = Line.CloseButton:CreateTexture(nil, "OVERLAY")
			Line.CloseButton.Texture:SetPoint("CENTER", Line.CloseButton, 0, -0.5)
			Line.CloseButton.Texture:SetTexture("Interface\\AddOns\\Gathering\\Assets\\HydraUIClose.tga")

			tinsert(page.IgnoredItems, Line)
		else
			Item:CreateFromItemID(ID):ContinueOnItemLoad(function()
				Name, Link = GetItemInfo(ID)

				local Line = CreateFrame("Frame", nil, page, "BackdropTemplate")
				Line:SetSize(page.IgnoredList:GetWidth() - 24, 22)
				Line.Item = ID

				Line.Text = Line:CreateFontString(nil, "OVERLAY")
				Line.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
				Line.Text:SetPoint("LEFT", Line, 5, 0)
				Line.Text:SetJustifyH("LEFT")
				Line.Text:SetShadowColor(0, 0, 0)
				Line.Text:SetShadowOffset(1, -1)
				Line.Text:SetText(Link or Name)

				Line.CloseButton = CreateFrame("Frame", nil, Line)
				Line.CloseButton:SetPoint("RIGHT", Line, 0, 0)
				Line.CloseButton:SetSize(24, 24)
				Line.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
				Line.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
				Line.CloseButton:SetScript("OnMouseUp", function(self) Gathering:RemoveIgnoredItem(self:GetParent().Item) end)

				Line.CloseButton.Texture = Line.CloseButton:CreateTexture(nil, "OVERLAY")
				Line.CloseButton.Texture:SetPoint("CENTER", Line.CloseButton, 0, -0.5)
				Line.CloseButton.Texture:SetTexture("Interface\\AddOns\\Gathering\\Assets\\HydraUIClose.tga")

				tinsert(page.IgnoredItems, Line)

				ScrollIgnoredItems(page)
			end)
		end
	end

	page.Offset = 1

	-- Scroll bar
	page.ScrollBar = CreateFrame("Slider", nil, page.IgnoredList)
	page.ScrollBar:SetWidth(12)
	page.ScrollBar:SetPoint("TOPRIGHT", page.IgnoredList, -4, -4)
	page.ScrollBar:SetPoint("BOTTOMRIGHT", page.IgnoredList, -4, 4)
	page.ScrollBar:SetThumbTexture(BlankTexture)
	page.ScrollBar:SetOrientation("VERTICAL")
	page.ScrollBar:SetValueStep(1)
	page.ScrollBar:SetMinMaxValues(1, math.max(1, #page.IgnoredItems - 9))
	page.ScrollBar:SetValue(1)
	page.ScrollBar:EnableMouse(true)
	page.ScrollBar:SetScript("OnValueChanged", IgnoreScrollBarOnValueChanged)
	page.ScrollBar:SetScript("OnMouseWheel", IgnoreWindowOnMouseWheel)
	page.ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
	page.ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
	page.ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
	page.ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)
	page.ScrollBar.Parent = page

	page.ScrollBar:SetFrameStrata("HIGH")
	page.ScrollBar:SetFrameLevel(20)

	local Thumb = page.ScrollBar:GetThumbTexture()
	Thumb:SetSize(12, 22)
	Thumb:SetVertexColor(0.25, 0.266, 0.294)

	ScrollIgnoredItems(page)
end

function Gathering:CreateStatLine(page, text)
	local Line = CreateFrame("Frame", nil, page, "BackdropTemplate")
	Line:SetSize(page:GetWidth() - 8, 22)

	Line.Text = Line:CreateFontString(nil, "OVERLAY")
	Line.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	Line.Text:SetPoint("LEFT", Line, 5, 0)
	Line.Text:SetJustifyH("LEFT")
	Line.Text:SetShadowColor(0, 0, 0)
	Line.Text:SetShadowOffset(1, -1)
	Line.Text:SetText(text)

	tinsert(page, Line)

	return Line
end

function Gathering:SetupStatsPage(page)
	page.LeftWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.LeftWidgets:SetSize(199, 246)
	page.LeftWidgets:SetPoint("LEFT", page, 0, 0)
	page.LeftWidgets:EnableMouse(true)
	page.LeftWidgets:SetBackdrop(Outline)
	page.LeftWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	page.XPStats = {}

	page.RightWidgets = CreateFrame("Frame", nil, page, "BackdropTemplate")
	page.RightWidgets:SetSize(198, 246)
	page.RightWidgets:SetPoint("LEFT", page.LeftWidgets, "RIGHT", 6, 0)
	page.RightWidgets:EnableMouse(true)
	page.RightWidgets:SetBackdrop(Outline)
	page.RightWidgets:SetBackdropColor(0.184, 0.192, 0.211)

	if (not GatheringStats) then
		GatheringStats = {}
	end

	self:CreateHeader(page.RightWidgets, "Experience")
	page.XPStats.xp = self:CreateStatLine(page.RightWidgets, format("Total: %s", self:Comma(GatheringStats.xp) or 0))
	page.XPStats.sessionxp = self:CreateStatLine(page.RightWidgets, format("Session: %s", Gathering.XPGained or 0))
	page.XPStats.levels = self:CreateStatLine(page.RightWidgets, format("Levels: %s", GatheringStats.levels or 0))
	--page.XPStats.PerHour = self:CreateStatLine(page.RightWidgets, "XP: 0")
	--page.XPStats.TTL = self:CreateStatLine(page.RightWidgets, "XP: 0")

	self:CreateHeader(page.LeftWidgets, "Gold")
	page.XPStats.totalgold = self:CreateStatLine(page.LeftWidgets, format("Gold: %s", self:CopperToGold(GatheringStats.gold) or 0))
	page.XPStats.sessiongold = self:CreateStatLine(page.LeftWidgets, format("Session: %s", self:CopperToGold(Gathering.GoldGained) or 0))

	self:CreateHeader(page.LeftWidgets, "Items")
	page.XPStats.items = self:CreateStatLine(page.LeftWidgets, format("Total: %s", self:Comma(GatheringStats.total) or 0))

	--self:CreateHeader(page.LeftWidgets, "Misc")
	--page.XPStats.clouds = self:CreateStatLine(page.LeftWidgets, format("Clouds: %s", self:Comma(GatheringStats.clouds) or 0))

	self:SortWidgets(page.LeftWidgets)
	self:SortWidgets(page.RightWidgets)
end

function Gathering:UpdateItemsStat()
	if (not self.Windows) then
		return
	end

	local page = self:GetPage("Stats")

	if (not page) then
		return
	end

	if page.XPStats.items then
		page.XPStats.items.Text:SetText(format("Total: %s", self:Comma(GatheringStats.items) or 0))
	end
end

function Gathering:UpdateXPStat()
	if (not self.Windows) then
		return
	end

	local page = self:GetPage("Stats")

	if (not page) then
		return
	end

	if page.XPStats.xp then
		page.XPStats.xp.Text:SetText(format("Total: %s", self:Comma(GatheringStats.xp) or 0))
	end

	if page.XPStats.sessionxp then
		page.XPStats.sessionxp.Text:SetText(format("Session: %s", self:Comma(Gathering.XPGained) or 0))
	end

	if page.XPStats.levels then
		page.XPStats.levels.Text:SetText(format("Levels: %s", GatheringStats.levels or 0))
	end
end

function Gathering:UpdateMoneyStat()
	if (not self.Windows) then
		return
	end

	local page = self:GetPage("Stats")

	if (not page) then
		return
	end

	if page.XPStats.totalgold then
		page.XPStats.totalgold.Text:SetText(format("Total: %s", self:CopperToGold(GatheringStats.gold) or 0))
	end

	if page.XPStats.sessiongold then
		page.XPStats.sessiongold.Text:SetText(format("Session: %s", self:CopperToGold(Gathering.GoldGained) or 0))
	end
end

function Gathering:CreateGUI()
	self.Windows = {}
	self.Tabs = {}

	-- Window
	self.GUI = CreateFrame("Frame", "Gathering Settings", UIParent, "BackdropTemplate")
	self.GUI:SetSize(490, 24)
	self.GUI:SetPoint("CENTER", UIParent, 0, 160)
	self.GUI:SetMovable(true)
	self.GUI:EnableMouse(true)
	self.GUI:SetUserPlaced(true)
	self.GUI:SetClampedToScreen(true)
	self.GUI:RegisterForDrag("LeftButton")
	self.GUI:SetScript("OnDragStart", self.GUI.StartMoving)
	self.GUI:SetScript("OnDragStop", self.GUI.StopMovingOrSizing)
	self.GUI:SetBackdrop(Outline)
	self.GUI:SetBackdropColor(0.184, 0.192, 0.211)

	self.GUI.Text = self.GUI:CreateFontString(nil, "OVERLAY")
	self.GUI.Text:SetPoint("LEFT", self.GUI, 6, -0.5)
	self.GUI.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12, "")
	self.GUI.Text:SetJustifyH("LEFT")
	self.GUI.Text:SetShadowColor(0, 0, 0)
	self.GUI.Text:SetShadowOffset(1, -1)
	self.GUI.Text:SetText("|cffFFC44DGathering|r " .. AddOnVersion)

	self.GUI.CloseButton = CreateFrame("Frame", nil, self.GUI)
	self.GUI.CloseButton:SetPoint("RIGHT", self.GUI, 0, 0)
	self.GUI.CloseButton:SetSize(24, 24)
	self.GUI.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	self.GUI.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	self.GUI.CloseButton:SetScript("OnMouseUp", function() self.GUI:Hide() end)

	self.GUI.CloseButton.Texture = self.GUI.CloseButton:CreateTexture(nil, "OVERLAY")
	self.GUI.CloseButton.Texture:SetPoint("CENTER", self.GUI.CloseButton, 0, -0.5)
	self.GUI.CloseButton.Texture:SetTexture("Interface\\AddOns\\Gathering\\Assets\\HydraUIClose.tga")

	self.GUI.TabParent = CreateFrame("Frame", nil, self.GUI, "BackdropTemplate")
	self.GUI.TabParent:SetSize(80, 246)
	self.GUI.TabParent:SetPoint("TOPLEFT", self.GUI, "BOTTOMLEFT", 0, -6)
	self.GUI.TabParent:SetBackdrop(Outline)
	self.GUI.TabParent:SetBackdropColor(0.184, 0.192, 0.211)

	self.GUI.Window = CreateFrame("Frame", nil, self.GUI)
	self.GUI.Window:SetSize(403, 246)
	self.GUI.Window:SetPoint("LEFT", self.GUI.TabParent, "RIGHT", 7, 0)

	self.GUI.OuterBackdrop = CreateFrame("Frame", nil, self.GUI.Window, "BackdropTemplate")
	self.GUI.OuterBackdrop:SetPoint("TOPLEFT", self.GUI, -6, 6)
	self.GUI.OuterBackdrop:SetPoint("BOTTOMRIGHT", self.GUI.Window, 6, -6)
	self.GUI.OuterBackdrop:SetBackdrop(Outline)
	self.GUI.OuterBackdrop:SetBackdropColor(0.125, 0.133, 0.145)
	self.GUI.OuterBackdrop:SetFrameStrata("BACKGROUND")
	self.GUI.OuterBackdrop:SetFrameLevel(0)

	local TrackingPage = self:AddPage("Tracking")
	self:SetupTrackingPage(TrackingPage)

	local StatsPage = self:AddPage("Stats")
	self:SetupStatsPage(StatsPage)

	local SettingsPage = self:AddPage("Settings")
	self:SetupSettingsPage(SettingsPage)

	local IgnorePage = self:AddPage("Ignore")
	self:SetupIgnorePage(IgnorePage)

	for i = 1, #self.Tabs do
		if (i == 1) then
			self.Tabs[i]:SetPoint("TOPLEFT", self.GUI.TabParent, 4, -4)
		else
			self.Tabs[i]:SetPoint("TOPLEFT", self.Tabs[i-1], "BOTTOMLEFT", 0, -4)
		end
	end

	self:ShowPage("Tracking")

	--[[self.GUI.MaxScroll = math.max(#self.GUI.LeftWidgets, #self.GUI.RightWidgets)

	-- Scroll bar
	self.GUI.Window.ScrollBar = CreateFrame("Slider", nil, self.GUI.RightWidgets)
	self.GUI.Window.ScrollBar:SetWidth(12)
	self.GUI.Window.ScrollBar:SetPoint("TOPLEFT", self.GUI.RightWidgets, "TOPRIGHT", 4, 0)
	self.GUI.Window.ScrollBar:SetPoint("BOTTOMLEFT", self.GUI.RightWidgets, "BOTTOMRIGHT", 4, 0)
	self.GUI.Window.ScrollBar:SetThumbTexture(BlankTexture)
	self.GUI.Window.ScrollBar:SetOrientation("VERTICAL")
	self.GUI.Window.ScrollBar:SetValueStep(1)
	self.GUI.Window.ScrollBar:SetMinMaxValues(1, (self.GUI.MaxScroll - (MaxWidgets - 1)))
	self.GUI.Window.ScrollBar:SetValue(1)
	self.GUI.Window.ScrollBar:EnableMouse(true)
	self.GUI.Window.ScrollBar:SetScript("OnValueChanged", ScrollBarOnValueChanged)
	self.GUI.Window.ScrollBar:SetScript("OnEnter", ScrollBarOnEnter)
	self.GUI.Window.ScrollBar:SetScript("OnLeave", ScrollBarOnLeave)
	self.GUI.Window.ScrollBar:SetScript("OnMouseDown", ScrollBarOnMouseDown)
	self.GUI.Window.ScrollBar:SetScript("OnMouseUp", ScrollBarOnMouseUp)
	self.GUI.Window.ScrollBar.Parent = self.GUI.Window

	self.GUI.Window.ScrollBar:SetFrameStrata("HIGH")
	self.GUI.Window.ScrollBar:SetFrameLevel(20)

	local Thumb = self.GUI.Window.ScrollBar:GetThumbTexture()
	Thumb:SetSize(12, 22)
	Thumb:SetVertexColor(0.125, 0.133, 0.145)

	--Scroll(self.GUI.Window)]]
end

function Gathering:ScanButtonOnClick()
	local TimeDiff = (GetTime() - (GatheringLastScan or 0))

	if (TimeDiff > 0) and (900 > TimeDiff) then -- 15 minute throttle
		print(format(L["You must wait %s until you can scan again."], Gathering:FormatTime(900 - TimeDiff)))
		return
	end

	if Gathering:IsEventRegistered("REPLICATE_ITEM_LIST_UPDATE") then -- Awaiting results already
		if (TimeDiff > 900) then
			self:UnregisterEvent("REPLICATE_ITEM_LIST_UPDATE")
		else
			return
		end
	end

	Gathering:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")

	ReplicateItems()

	print(L["|cffFFC44DGathering|r is scanning market prices. This should take less than 10 seconds."])

	GatheringLastScan = GetTime()
end

function Gathering:CHAT_MSG_LOOT(msg)
	if (not msg) then
		return
	end

	if ((self.Settings.IgnoreMailItems and InboxFrame:IsVisible()) or (GuildBankFrame and GuildBankFrame:IsVisible())) then -- Ignore useless info
		return
	end

	local PreMessage, Color, ItemString, Name, Quantity = match(msg, LootMatch)

	if (not ItemString) then
		return
	end

	if (PreMessage and not ValidMessages[PreMessage]) then
		return
	end

	local LinkType, ID = match(ItemString, "^(%a+):(%d+)")

	ID = tonumber(ID)
	Quantity = tonumber(Quantity) or 1

	local _, _, Quality, _, _, Type, SubType, _, _, Texture, _, ClassID, SubClassID, BindType = GetItemInfo(ID)

	if (self.Ignored[ID] or self.Ignored[Name] or ((not self.TrackedItemTypes[ClassID]) or (not self.TrackedItemTypes[ClassID][SubClassID]))) then
		return
	end

	if (BindType and ((BindType ~= 0) and self.Settings["ignore-bop"])) then
		return
	end

	if (not self.Gathered[SubType]) then
		self.Gathered[SubType] = {}
	end

	local Now = GetTime()

	if (not self.Gathered[SubType][ID]) then
		self.Gathered[SubType][ID] = {Initial = Now}
	end

	local Info = self.Gathered[SubType][ID]

	Info.Collected = (Info.Collected or 0) + Quantity
	Info.Last = Now

	self.TotalGathered = self.TotalGathered + Quantity -- For gathered/hr stat

	if (self.Settings.DisplayMode == "TOTAL") then
		self.Text:SetFormattedText(L["Total: %s"], self.TotalGathered)
	end

	if (not self:GetScript("OnUpdate")) then
		self:StartTimer()
	end

	self:AddStat("total", Quantity)
	self:AddItemStat(ID, Quantity)

	self:UpdateItemsStat()

	if self.MouseIsOver then
		self:OnLeave()
		self:OnEnter()
	end
end

function Gathering:REPLICATE_ITEM_LIST_UPDATE()
	if (not GatheringMarketPrices) then
		GatheringMarketPrices = {}
	end

	local Count, Buyout, ID, HasAllInfo, PerUnit, _

	for i = 0, (GetNumReplicateItems() - 1) do
		_, _, Count, _, _, _, _, _, _, Buyout, _, _, _, _, _, _, ID, HasAllInfo = GetReplicateItemInfo(i)

		if HasAllInfo then
			self.MarketPrices[ID] = Buyout / Count
			GatheringMarketPrices[ID] = self.MarketPrices[ID]
		elseif ID then
			Item:CreateFromItemID(ID):ContinueOnItemLoad(function()
				_, _, Count, _, _, _, _, _, _, Buyout, _, _, _, _, _, _, ID = GetReplicateItemInfo(i)
				PerUnit = Buyout / Count

				if self.MarketPrices[ID] then
					if (self.MarketPrices[ID] > PerUnit) then -- Collect lowest prices
						self.MarketPrices[ID] = PerUnit
						GatheringMarketPrices[ID] = self.MarketPrices[ID]
					end
				else
					self.MarketPrices[ID] = PerUnit
					GatheringMarketPrices[ID] = self.MarketPrices[ID]
				end
			end)
		end
	end

	self:UnregisterEvent("REPLICATE_ITEM_LIST_UPDATE")

	print(L["|cffFFC44DGathering|r updated market prices."])
end

function Gathering:MODIFIER_STATE_CHANGED()
	if self.MouseIsOver then
		self.Tooltip:ClearLines()
		self:OnEnter()
	end
end

function Gathering:OnTooltipSetItem()
	if (not Gathering.Settings["show-tooltip"]) then
		return
	end

	local Item, Link = self:GetItem()

	if Item then
		local Price = Gathering:GetPrice(Link)

		if (Price and Price > 0) then
			self:AddLine(" ")
			self:AddLine("|cffFFC44DGathering|r")
			self:AddLine(format(L["Price per unit: %s"], Gathering:CopperToGold(Price)), 1, 1, 1)
		end
	end
end

function Gathering:PLAYER_ENTERING_WORLD()
	if (not self.Initial) then

		self.Ignored = GatheringIgnore or {}

		if IsAddOnLoaded("TradeSkillMaster") then
			self.HasTSM = true
		end

		if (not IsAddOnLoaded("HydraUI")) then
			print("|cffFFC44DGathering|r: Join the community for support and feedback! - discord.gg/XefDFa6nJR")
		end

		--[[if TooltipDataProcessor then
			TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, self.OnTooltipSetItem)
		else
			GameTooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
		end]]

		if (not GatheringSettings) then
			GatheringSettings = {}
		end

		self.Settings = setmetatable(GatheringSettings, {__index = self.DefaultSettings})

		self:CreateWindow()

		self:UpdateHerbTracking(self.Settings["track-herbs"])
		self:UpdateClothTracking(self.Settings["track-cloth"])
		self:UpdateLeatherTracking(self.Settings["track-leather"])
		self:UpdateOreTracking(self.Settings["track-ore"])
		self:UpdateJewelcraftingTracking(self.Settings["track-jewelcrafting"])
		self:UpdateEnchantingTracking(self.Settings["track-enchanting"])
		self:UpdateCookingTracking(self.Settings["track-cooking"])
		self:UpdateReagentTracking(self.Settings["track-reagents"])
		self:UpdateConsumableTracking(self.Settings["track-consumable"])
		self:UpdateHolidayTracking(self.Settings["track-holiday"])
		self:UpdateQuestTracking(self.Settings["track-quest"])

		if self.Settings["hide-idle"] then
			self:Hide()
		end

		self.XPStartTime = GetTime()

		self.Initial = true
	end

	if (GameVersion < 90000 and not IsInInstance()) then
		C_Timer.After(6, function()
			CT:SendAddonMessage("NORMAL", "GATHERING_VRSN", AddOnVersion, "YELL")
		end)
	end

	self:GROUP_ROSTER_UPDATE()
end

function Gathering:PLAYER_MONEY()
	if (InboxFrame:IsVisible() and self.Settings.IgnoreMailMoney) then
		return
	end

	local Current = GetMoney()

	if (Current > self.GoldValue) then
		local Diff = Current - self.GoldValue
		local Now = GetTime()

		self.GoldGained = self.GoldGained + Diff

		if (self.GoldTimer == 0) then
			self.GoldTimer = Now
		end

		if (self.Settings.DisplayMode == "TIME") then
			self:StartTimer()
		elseif (self.Settings.DisplayMode == "GPH") then
			if (self.GoldGained > 0) then
				self.Text:SetFormattedText(L["GPH: %s"], self:CopperToGold(floor((self.GoldGained / max(Now - self.GoldTimer, 1)) * 60 * 60)))
			end

			if (not self:GetScript("OnUpdate")) then
				self:SetScript("OnUpdate", self.OnUpdate)
			end
		elseif (self.Settings.DisplayMode == "GOLD") then
			self.Text:SetText(self:CopperToGold(self.GoldGained))
		end

		self:AddStat("gold", Diff)

		self:UpdateMoneyStat()
	end

	self.GoldValue = Current
end

function Gathering:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		CT:SendAddonMessage("NORMAL", "GATHERING_VRSN", AddOnVersion, "GUILD")

		self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	end
end

function Gathering:GROUP_ROSTER_UPDATE()
	local Home = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
	local Instance = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE)

	if (Home == 0 and self.SentGroup) then
		self.SentGroup = false
	elseif (Instance == 0 and self.SentInstance) then
		self.SentInstance = false
	end

	if (Instance > 0 and not self.SentInstance) then
		CT:SendAddonMessage("NORMAL", "GATHERING_VRSN", AddOnVersion, "INSTANCE_CHAT")
		self.SentInstance = true
	elseif (Home > 0 and not self.SentGroup) then
		CT:SendAddonMessage("NORMAL", "GATHERING_VRSN", AddOnVersion, IsInRaid(LE_PARTY_CATEGORY_HOME) and "RAID" or IsInGroup(LE_PARTY_CATEGORY_HOME) and "PARTY")
		self.SentGroup = true
	end
end

function Gathering:ZONE_CHANGED()
	if UnitOnTaxi("player") then
		local Now = GetTime()

		if (Now - self.LastYell > 15) then
			CT:SendAddonMessage("NORMAL", "GATHERING_VRSN", AddOnVersion, "YELL")

			self.LastYell = Now
		end
	end
end

function Gathering:ZONE_CHANGED_NEW_AREA()
	if UnitOnTaxi("player") then
		local Now = GetTime()

		if (Now - self.LastYell > 15) then
			CT:SendAddonMessage("NORMAL", "GATHERING_VRSN", AddOnVersion, "YELL")

			self.LastYell = Now
		end
	end
end

function Gathering:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if sender:find("-") then
		sender = match(sender, "(%S+)-%S+")
	end

	if (sender == Me or prefix ~= "GATHERING_VRSN") then
		return
	end

	message = tonumber(message)

	if (message >= AddOnNum) then
		ChannelCD[channel] = true
	else
		ChannelCD[channel] = false
	end

	if (AddOnNum > message) then -- We have a higher version, share it
		C_Timer.After(random(1, 8), function()
			if (not ChannelCD[channel]) then
				CT:SendAddonMessage("NORMAL", "GATHERING_VRSN", AddOnVersion, channel)
			end
		end)
	elseif (message > AddOnNum) then -- We're behind!
		print(format("Update |cffFFC44DGathering|r to version %s! www.curseforge.com/wow/addons/gathering", message))
		print("Join the Discord community for support and feedback discord.gg/XefDFa6nJR")

		AddOnNum = message
		AddOnVersion = tostring(message)
	end
end

function Gathering:AUCTION_HOUSE_SHOW()
	if (not self.ScanButton and AuctionHouseFrame) then
		self.ScanButton = CreateFrame("Button", "Gathering Scan Button", AuctionHouseFrame.MoneyFrameBorder, "UIPanelButtonTemplate")
		self.ScanButton:SetSize(140, 24)
		self.ScanButton:SetPoint("LEFT", AuctionHouseFrame.MoneyFrameBorder, "RIGHT", 3, 0)
		self.ScanButton:SetText(L["Gathering Scan"])
		self.ScanButton:SetScript("OnClick", self.ScanButtonOnClick)
	end
end

function Gathering:PLAYER_XP_UPDATE()
	local XP = UnitXP("player")
	local MaxXP = UnitXPMax("player")

	if (MaxXP ~= self.LastMax) then
		self.XPGained = self.LastMax - self.LastXP + XP + self.XPGained
		self:AddStat("xp", (self.LastMax - self.LastXP + XP))
		self:AddStat("levels", 1)
	else
		self.XPGained = (XP - self.LastXP) + self.XPGained
		self:AddStat("xp", (XP - self.LastXP))
	end

	if (not self.XPStartTime) then
		self.XPStartTime = GetTime()
	end

	self:UpdateXPStat()

	self.LastXP = XP
	self.LastMax = MaxXP
end

function Gathering:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Gathering:GetPrice(link)
	if self.HasTSM then
		return TSM_API.GetCustomPriceValue("dbMarket", TSM_API.ToItemString(link))
	end
end

function Gathering:OnEnter()
	if (self.TotalGathered == 0 and self.GoldGained == 0 and self.XPGained == 0) then
		return
	end

	self.MouseIsOver = true

	local Now = GetTime()
	local MarketTotal = 0
	local X, Y = self:GetCenter()

	self.Tooltip:SetOwner(self, "ANCHOR_NONE")

	if (Y > UIParent:GetHeight() / 2) then
		self.Tooltip:SetPoint("TOP", self, "BOTTOM", 0, -2)
	else
		self.Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 2)
	end

	self.Tooltip:ClearLines()

	local Now = GetTime()

	if (self.TotalGathered > 0) then
		for SubType, Info in next, self.Gathered do
			self.Tooltip:AddLine(SubType, 1, 1, 0)

			for ID, Value in next, Info do
				local Name, Link, Rarity = GetItemInfo(ID)
				local Hex = "|cffFFFFFF"

				if Rarity then
					Hex = ITEM_QUALITY_COLORS[Rarity].hex
				end

				local Price = self:GetPrice(Link)

				if Price then
					MarketTotal = MarketTotal + (Price * Value.Collected)
				end

				if (IsShiftKeyDown() and Price) then
					self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s/%s)", Value.Collected, self:CopperToGold((Price * Value.Collected / max(Now - Value.Initial, 1)) * 60 * 60), L["Hr"]), 1, 1, 1, 1, 1, 1)
				elseif IsControlKeyDown() then
					self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s%%)", Value.Collected, floor((Value.Collected / self.TotalGathered * 100 + 0.05) * 10) / 10), 1, 1, 1, 1, 1, 1)
				elseif IsAltKeyDown() then
					self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s %s", L["Recently Gathered: "], date("!%X", GetTime() - Value.Last)), 1, 1, 1, 1, 1, 1)
				else
					self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s/%s)", Value.Collected, floor((Value.Collected / max(Now - Value.Initial, 1)) * 60 * 60), L["Hr"]), 1, 1, 1, 1, 1, 1)
				end
			end

			self.Tooltip:AddLine(" ")
		end
	end

	if (self.GoldGained > 0) then
		self.Tooltip:AddLine(MONEY_LOOT, 1, 1, 0)

		if IsShiftKeyDown() then
			self.Tooltip:AddDoubleLine(BONUS_ROLL_REWARD_MONEY, format("%s (%s %s)", self:CopperToGold(self.GoldGained), self:CopperToGold(floor((self.GoldGained / max(Now - self.GoldTimer, 1)) * 60 * 60)), L["Hr"]), 1, 1, 1, 1, 1, 1)
		else
			self.Tooltip:AddDoubleLine(BONUS_ROLL_REWARD_MONEY, self:CopperToGold(self.GoldGained), 1, 1, 1, 1, 1, 1)
		end
	end

	if (self.Settings["track-xp"] and self.XPGained > 0) then
		if (self.GoldGained > 0) then
			self.Tooltip:AddLine(" ")
		end

		local PerSec = self.XPGained / (Now - self.XPStartTime)

		self.Tooltip:AddLine(COMBAT_XP_GAIN, 1, 1, 0)
		self.Tooltip:AddDoubleLine("XP Gained", self:Comma(self.XPGained), 1, 1, 1, 1, 1, 1)
		self.Tooltip:AddDoubleLine("XP / hr", self:Comma((PerSec * 60) * 60), 1, 1, 1, 1, 1, 1)
		self.Tooltip:AddDoubleLine("Time to level", self:FormatFullTime((UnitXPMax("player") - UnitXP("player")) / PerSec), 1, 1, 1, 1, 1, 1)
	end

	if (self.TotalGathered > 0) then
		if (self.XPGained > 0) then
			self.Tooltip:AddLine(" ")
		end

		self.Tooltip:AddDoubleLine(L["Total Gathered:"], self.TotalGathered, nil, nil, nil, 1, 1, 1)

		if (IsShiftKeyDown() and MarketTotal > 0) then
			self.Tooltip:AddDoubleLine(L["Total Average Per Hour:"], self:CopperToGold((MarketTotal / max(self.Seconds, 1)) * 60 * 60), nil, nil, nil, 1, 1, 1)
		else
			self.Tooltip:AddDoubleLine(L["Total Average Per Hour:"], self:Comma(floor(((self.TotalGathered / max(self.Seconds, 1)) * 60 * 60))), nil, nil, nil, 1, 1, 1)
		end

		if (MarketTotal > 0) then
			self.Tooltip:AddDoubleLine(L["Total Value:"], self:CopperToGold(MarketTotal), nil, nil, nil, 1, 1, 1)
		end
	end

	if self.Settings.ShowTooltipHelp then
		self.Tooltip:AddLine(" ")
		self.Tooltip:AddLine(L["Left click: Toggle timer"])
		self.Tooltip:AddLine(L["Right click: Reset data"])
	end

	self:UpdateTooltipFont()

	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self.Tooltip:Show()
end

function Gathering:OnLeave()
	if self.Tooltip.Override then
		return
	end

	self.MouseIsOver = false

	self:UnregisterEvent("MODIFIER_STATE_CHANGED")

	self.Tooltip:Hide()
end

function Gathering:OnMouseUp(button)
	if (button == "LeftButton") then
		self:ToggleTimer()
	elseif (button == "RightButton") then
		self:ToggleResetPopup()
	elseif (button == "MiddleButton") then
		if (self.Tooltip.Override == true) then
			self.Tooltip.Override = false
		else
			self.Tooltip.Override = true
		end
	end
end

function Gathering:BAG_UPDATE_DELAYED()
	if (not self.BagResults) then
		return
	end

	local Results = {}
	local ID, Texture, Count, ClassID, SubClassID

	for Bag = 0, NUM_BAG_SLOTS do
		for Slot = 1, GetContainerNumSlots(Bag) do
			ID = GetContainerItemID(Bag, Slot)
			Texture, Count = GetContainerItemInfo(Bag, Slot)

			if ID then
				ClassID, SubClassID = select(12, GetItemInfo(ID))

				if (self.TrackedItemTypes[ClassID] and self.TrackedItemTypes[ClassID][SubClassID]) then
					if self.BagResults[Bag][Slot] then
						if (Count > self.BagResults[Bag][Slot][2]) then
							local Change = Count - self.BagResults[Bag][Slot][2]

							tinsert(Results, {ID, Change})
						end
					else
						tinsert(Results, {ID, Count}) -- We just started a stack, and Count is the total of the new item
					end
				end
			end
		end
	end

	if (#Results == 0) then
		self.BagResults = nil

		return
	end

	for i = 1, #Results do
		local ID = Results[i][1]
		local Quantity = Results[i][2]
		local Type, SubType, _, _, _, _, ClassID, SubClassID, BindType = select(6, GetItemInfo(ID))

		if (BindType and ((BindType ~= 0) and self.Settings["ignore-bop"])) then
			return
		end

		if (not self.Gathered[SubType]) then
			self.Gathered[SubType] = {}
		end

		local Now = GetTime()

		if (not self.Gathered[SubType][ID]) then
			self.Gathered[SubType][ID] = {Initial = Now}
		end

		local Info = self.Gathered[SubType][ID]

		Info.Collected = (Info.Collected or 0) + Quantity
		Info.Last = Now

		self.TotalGathered = self.TotalGathered + Quantity -- For gathered/hr stat

		if (self.Settings.DisplayMode == "TOTAL") then
			self.Text:SetFormattedText(L["Total: %s"], self.TotalGathered)
		end

		if (not self:GetScript("OnUpdate")) then
			self:StartTimer()
		end

		if self.MouseIsOver then
			self:OnLeave()
			self:OnEnter()
		end
	end

	self.BagResults = nil
end

function Gathering:UNIT_SPELLCAST_CHANNEL_START(unit, guid, id)
	if (unit ~= "player") then
		return
	end

	if (not id or id ~= 30427) then -- Extract Gas
		return
	end

	self.BagResults = {}

	local ID, Texture, Count, ClassID, SubClassID

	for Bag = 0, NUM_BAG_SLOTS do
		if (not self.BagResults[Bag]) then
			self.BagResults[Bag] = {}
		end

		for Slot = 1, GetContainerNumSlots(Bag) do
			ID = GetContainerItemID(Bag, Slot)

			if ID then
				Texture, Count = GetContainerItemInfo(Bag, Slot)
				ClassID, SubClassID = select(12, GetItemInfo(ID))

				if (self.TrackedItemTypes[ClassID] and self.TrackedItemTypes[ClassID][SubClassID]) then
					self.BagResults[Bag][Slot] = {ID, Count}
				end
			end
		end
	end

	self:AddStat("clouds", 1)
end

if (GameVersion > 20000 and GameVersion < 90000) then
	Gathering:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	Gathering:RegisterEvent("BAG_UPDATE_DELAYED")
elseif (GameVersion > 90000) then
	Gathering:RegisterEvent("AUCTION_HOUSE_SHOW")
end

if (GameVersion < 90000) then
	Gathering:RegisterEvent("ZONE_CHANGED")
	Gathering:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

Gathering:RegisterEvent("GROUP_ROSTER_UPDATE")
Gathering:RegisterEvent("GUILD_ROSTER_UPDATE")
Gathering:RegisterEvent("CHAT_MSG_ADDON")
Gathering:RegisterEvent("CHAT_MSG_LOOT")
Gathering:RegisterEvent("PLAYER_ENTERING_WORLD")
Gathering:RegisterEvent("PLAYER_MONEY")
Gathering:RegisterEvent("PLAYER_XP_UPDATE")
Gathering:SetScript("OnEvent", Gathering.OnEvent)
Gathering:SetScript("OnEnter", Gathering.OnEnter)
Gathering:SetScript("OnLeave", Gathering.OnLeave)
Gathering:SetScript("OnMouseUp", Gathering.OnMouseUp)

SLASH_GATHERING1 = "/gt"
SLASH_GATHERING2 = "/gather"
SLASH_GATHERING3 = "/gathering"
SlashCmdList["GATHERING"] = function(cmd)
	if (not Gathering.GUI) then
		Gathering:CreateGUI()

		return
	end

	if Gathering.GUI:IsShown() then
		Gathering.GUI:Hide()
	else
		Gathering.GUI:Show()
	end
end

C_ChatInfo.RegisterAddonMessagePrefix("GATHERING_VRSN")