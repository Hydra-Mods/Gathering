local date = date
local pairs = pairs
local select = select
local max = math.max
local floor = floor
local format = format
local tonumber = tonumber
local match = string.match
local GetItemInfo = GetItemInfo
local BreakUpLargeNumbers = BreakUpLargeNumbers
local ReplicateItems = C_AuctionHouse.ReplicateItems
local GetNumReplicateItems = C_AuctionHouse.GetNumReplicateItems
local GetReplicateItemInfo = C_AuctionHouse.GetReplicateItemInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LootMessage = LOOT_ITEM_SELF:gsub("%%.*", "")
local LootMatch = "([^|]+)|cff(%x+)|H([^|]+)|h%[([^%]]+)%]|h|r[^%d]*(%d*)"
local Locale = GetLocale()
local MaxWidgets = 11
local MaxSelections = 8
local BlankTexture = "Interface\\AddOns\\Gathering\\HydraUIBlank.tga"
local BarTexture = "Interface\\AddOns\\Gathering\\HydraUI4.tga"
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local AddOnVersion = tonumber(GetAddOnMetadata("Gathering", "Version"))
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local Textures = SharedMedia:HashTable("statusbar")
local Fonts = SharedMedia:HashTable("font")
local Me = UnitName("player")
local MyRealm = GetRealmName()
local MyFaction = UnitFactionGroup("player")

SharedMedia:Register("font", "PT Sans", "Interface\\Addons\\Gathering\\PTSans.ttf")
SharedMedia:Register("statusbar", "HydraUI 4", BarTexture)

local Index = function(self, key)
	return key
end

local L = setmetatable({}, {__index = Index})

if (Locale == "deDE") then -- German
	L["Total Gathered:"] = "Gesammelt total:"
	L["Total Average Per Hour:"] = "Gesamtdurchschnitt pro Stunde:"
	L["Total Value:"] = "Gesamtwert:"
	L["Left click: Toggle timer"] = "Linksklick: Timer anhalten/fortsetzen"
	L["Right click: Reset data"] = "Rechtsklick: Daten zur\195\188cksetzen"
	L["Hr"] = "Std."

	L["You must wait %s until you can scan again."] = "Du musst %s warten bevor du wieder scannen kannst."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r scannt gerade die Marktpreise, dies sollte weniger als 10 Sekunden dauern."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r hat die Marktpreise aktualisiert"

	L["Ore"] = "Erz"
	L["Herbs"] = "Kr\195\164uter"
	L["Leather"] = "Leder"
	L["Cooking"] = "Kochen"
	L["Cloth"] = "Stoffe"
	L["Enchanting"] = "Verzaubern"
	L["Jewelcrafting"] = "Juwelen"
	L["Weapons"] = "Waffen"
	L["Armor"] = "R\195\188stung"
	L["Pets"] = "Haustiere"
	L["Mounts"] = "Reittiere"
	L["Consumables"] = "Verbrauchbares"
	L["Reagents"] = "Reagenzien"
	L["Ignore Bind on Pickup"] = "Ignoriere Items, welche beim aufheben Seelengebunden werden"
	L["%s is now being unignored."] = "%s wird nun nicht mehr ignoriert."
	L["Show tooltip data"] = "Zeige Tooltip Daten"
	L["Price per unit: %s"] = "Preis pro Einheit: %s"
elseif (Locale == "esES") then -- Spanish (Spain)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "esMX") then -- Spanish (Mexico)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "frFR") then -- French
	L["Total Gathered:"] = "Total recueilli:"
	L["Total Average Per Hour:"] = "Moyenne totale par heure:"
	L["Total Value:"] = "Valeur totale:"
	L["Left click: Toggle timer"] = "Clic gauche : Minuterie on/off"
	L["Right click: Reset data"] = "Clic droit : Réinitialisation des données"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "Vous devez attendre %s pour que vous puissiez à nouveau scanner."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r scrute les prix du marché. Cela devrait prendre moins de 10 secondes."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r a fini d'actualiser les prix du marché."
	
	L["Ore"] = "Minerai"
	L["Herbs"] = "Herbes"
	L["Leather"] = "Cuir"
	L["Cooking"] = "Cuisine"
	L["Cloth"] = "Tissu"
	L["Enchanting"] = "Enchanteur"
	L["Jewelcrafting"] = "Joaillerie"
	L["Weapons"] = "Armes"
	L["Armor"] = "Armure"
	L["Pets"] = "Mascottes"
	L["Mounts"] = "Montures"
	L["Consumables"] = "Consommables"
	L["Reagents"] = "Réactifs"
	L["Ignore Bind on Pickup"] = "Ignorer les objets liés au ramassage"
	L["%s is now being unignored."] = "%s n'est désormais plus ignorée."
	L["Show tooltip data"] = "Afficher les données de l'infobulle"
	L["Price per unit: %s"] = "Prix par unité: %s"
elseif (Locale == "itIT") then -- Italian
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "koKR") then -- Korean
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "ptBR") then -- Portuguese (Brazil)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "ruRU") then -- Russian
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "zhCN") then -- Chinese (Simplified) | Contributed by zhousp
	L["Total Gathered:"] = "总计:"
	L["Total Average Per Hour:"] = "每小时:"
	L["Total Value:"] = "总价值:"
	L["Left click: Toggle timer"] = "左键点击: 开始/暂停"
	L["Right click: Reset data"] = "右键点击: 重置数据"
	L["Hr"] = "小时"
	
	L["You must wait %s until you can scan again."] = "必须 %s 后才能再次扫描."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r 正在扫描拍卖行价格."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r 更新价格数据成功."
	
	L["Ore"] = "矿石"
	L["Herbs"] = "草药"
	L["Leather"] = "皮"
	L["Cooking"] = "烹饪"
	L["Cloth"] = "布"
	L["Enchanting"] = "附魔"
	L["Jewelcrafting"] = "珠宝加工"
	L["Weapons"] = "武器"
	L["Armor"] = "护甲"
	L["Pets"] = "宠物"
	L["Mounts"] = "坐骑"
	L["Consumables"] = "消耗品"
	L["Reagents"] = "药剂"
	L["Ignore Bind on Pickup"] = "忽略拾取绑定物品"
	L["%s is now being unignored."] = "%s 已取消屏蔽名单."
	L["Show tooltip data"] = "鼠标显示拍卖行价格"
	L["Price per unit: %s"] = "拍卖行最低价: %s"
elseif (Locale == "zhTW") then -- Chinese (Traditional/Taiwan) | Contributed by zhousp
	L["Total Gathered:"] = "總計:"
	L["Total Average Per Hour:"] = "每小時:"
	L["Total Value:"] = "總價值:"
	L["Left click: Toggle timer"] = "左鍵點擊: 開始/暫停"
	L["Right click: Reset data"] = "右鍵點擊: 重置數據"
	L["Hr"] = "小時"
	
	L["You must wait %s until you can scan again."] = "必須 %s 後才能再次掃描."
	L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."] = "|cff00CC6AGathering|r 正在掃描拍賣行價格."
	L["|cff00CC6AGathering|r updated market prices."] = "|cff00CC6AGathering|r 更新價格數據成功."
	
	L["Ore"] = "礦石"
	L["Herbs"] = "草藥"
	L["Leather"] = "皮"
	L["Cooking"] = "烹飪"
	L["Cloth"] = "布"
	L["Enchanting"] = "附魔"
	L["Jewelcrafting"] = "珠寶加工"
	L["Weapons"] = "武器"
	L["Armor"] = "護甲"
	L["Pets"] = "寵物"
	L["Mounts"] = "坐騎"
	L["Consumables"] = "消耗品"
	L["Reagents"] = "藥劑"
	L["Ignore Bind on Pickup"] = "忽略拾取綁定物品"
	L["%s is now being unignored."] = "%s 已取消屏蔽名單."
	L["Show tooltip data"] = "鼠標顯示拍賣行價格"
	L["Price per unit: %s"] = "拍賣行最低價: %s"
end

local Outline = {
	bgFile = BlankTexture,
	edgeFile = BlankTexture,
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local Gathering = CreateFrame("Frame", "Gathering Header", UIParent, "BackdropTemplate")
Gathering:SetPoint("TOP", UIParent, 0, -100)
Gathering:EnableMouse(true)
Gathering:SetMovable(true)
Gathering:SetUserPlaced(true)

function Gathering:CreateWindow()
	self:SetSize(140, 26)
	self:SetBackdrop({bgFile = BlankTexture, edgeFile = BlankTexture, edgeSize = 1, insets = {top = 0, left = 0, bottom = 0, right = 0}})
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetBackdropColor(0.2, 0.2, 0.2, 0.7)
	self:SetClampedToScreen(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)

	-- Text
	self.Text = self:CreateFontString(nil, "OVERLAY")
	self.Text:SetPoint("CENTER", self, 0, 0)
	self.Text:SetJustifyH("CENTER")
	self.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 14)
	self.Text:SetShadowColor(0, 0, 0)
	self.Text:SetShadowOffset(1, -1)
	self.Text:SetText("Gathering")

	-- Tooltip
	self.Tooltip = CreateFrame("GameTooltip", "Gathering Tooltip", UIParent, "GameTooltipTemplate")
	self.Tooltip:SetFrameLevel(10)

	self.Tooltip.Backdrop = CreateFrame("Frame", nil, self.Tooltip, "BackdropTemplate")
	self.Tooltip.Backdrop:SetAllPoints(Gathering.Tooltip)
	self.Tooltip.Backdrop:SetBackdrop({bgFile = BlankTexture, edgeFile = BlankTexture, edgeSize = 1, insets = {top = 0, left = 0, bottom = 0, right = 0}})
	self.Tooltip.Backdrop:SetBackdropBorderColor(0, 0, 0)
	self.Tooltip.Backdrop:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
	self.Tooltip.Backdrop:SetFrameStrata("TOOLTIP")
	self.Tooltip.Backdrop:SetFrameLevel(1)

	-- Data
	self.Gathered = {}
	self.TotalGathered = 0
	self.NumTypes = 0
	self.Elapsed = 0
	self.Seconds = 0
	self.SecondsPerItem = {}
end

Gathering.DefaultSettings = {
	-- Tracking
	["track-ore"] = true,
	["track-herbs"] = true,
	["track-leather"] = true,
	["track-cooking"] = true,
	["track-cloth"] = true,
	["track-enchanting"] = true,
	["track-jewelcrafting"] = true,
	["track-weapons"] = false,
	["track-armor"] = false,
	["track-mounts"] = false,
	["track-consumables"] = false,
	["track-reagents"] = false,
	["track-other"] = false,
	
	-- Functionality
	["ignore-bop"] = false, -- Ignore bind on pickup gear. IE: ignore BoP loot on a raid run, but show BoE's for the auction house
	["hide-idle"] = false, -- Hide the tracker frame while not running
	["show-tooltip"] = false, -- Show tooltip data about item prices
	
	-- Styling
	["window-font"] = SharedMedia.DefaultMedia.font, -- Set the font
}

Gathering.TrackedItemTypes = {
	[LE_ITEM_CLASS_CONSUMABLE] = {},
	[LE_ITEM_CLASS_WEAPON] = {},
	[LE_ITEM_CLASS_ARMOR] = {},
	[LE_ITEM_CLASS_TRADEGOODS] = {},
	[LE_ITEM_CLASS_MISCELLANEOUS] = {},
}

function Gathering:UpdateWeaponTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_AXE1H] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_AXE2H] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_BOWS] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_GUNS] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_MACE1H] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_MACE2H] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_POLEARM] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_SWORD1H] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_SWORD2H] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_WARGLAIVE] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_STAFF] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_BEARCLAW] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_CATCLAW] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_UNARMED] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_GENERIC] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_CROSSBOW] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_WAND] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_FISHINGPOLE] = value
end

function Gathering:UpdateArmorTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_GENERIC] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_CLOTH] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_LEATHER] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_MAIL] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_PLATE] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_COSMETIC] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_SHIELD] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_RELIC] = value
end

function Gathering:UpdateJewelcraftingTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][4] = value
end

function Gathering:UpdateClothTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][5] = value
end

function Gathering:UpdateLeatherTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][6] = value
end

function Gathering:UpdateOreTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][7] = value
end

function Gathering:UpdateCookingTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][8] = value
end

function Gathering:UpdateHerbTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][9] = value
end

function Gathering:UpdateEnchantingTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][12] = value
end

function Gathering:UpdateHolidayTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_HOLIDAY] = value
end

function Gathering:UpdateMountTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_MOUNT] = value
end

function Gathering:UpdateConsumableTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][1] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][2] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][3] = value
end

function Gathering:UpdateReagentTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_REAGENT] = value
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][10] = value
end

function Gathering:UpdateOtherTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_OTHER] = value
end

function Gathering:AddIgnoredItem(text)
	if (text == "") then
		return
	end
	
	local ID = tonumber(text)
	
	if (not GatheringIgnore) then
		GatheringIgnore = {}
	end
	
	if ID then
		GatheringIgnore[ID] = true
		
		print(format(ERR_IGNORE_ADDED_S, GetItemInfo(ID)))
	else
		GatheringIgnore[text] = true
		
		print(format(ERR_IGNORE_ADDED_S, text))
	end
end

function Gathering:RemoveIgnoredItem(text)
	if ((not GatheringIgnore) or (text == "")) then
		return
	end
	
	local ID = tonumber(text)
	
	if ID then
		GatheringIgnore[ID] = nil
		
		print(format(L["%s is now being unignored."], GetItemInfo(ID)))
	else
		GatheringIgnore[text] = nil
		
		print(format(L["%s is now being unignored."], text))
	end
end

function Gathering:ToggleTimerPanel(value)
	if (value and (not Gathering:GetScript("OnUpdate"))) then
		Gathering:Hide()
	else
		Gathering:Show()
	end
end

function Gathering:UpdateTooltipFont()
	local Font = SharedMedia:Fetch("font", self.Settings["window-font"])
	
	if self.Tooltip.NineSlice then
		self.Tooltip.NineSlice:Hide()
	end
	
	for i = 1, self.Tooltip:GetNumRegions() do
		local Region = select(i, self.Tooltip:GetRegions())
		
		--if (Region:GetObjectType() == "FontString" and not Region.Handled) then
		if (Region:GetObjectType() == "FontString") then
			Region:SetFont(Font, 12)
			Region:SetShadowColor(0, 0, 0)
			Region:SetShadowOffset(1, -1)
			--Region.Handled = true
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
	
	if (self.Elapsed >= 1) then
		self.Seconds = self.Seconds + 1
		
		for key in pairs(self.SecondsPerItem) do
			self.SecondsPerItem[key] = self.SecondsPerItem[key] + 1
		end
		
		self.Text:SetText(date("!%X", self.Seconds))
		
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
	
	if (not strfind(self.Text:GetText(), "%d")) then
		self.Text:SetText("0:00:00")
	end
	
	self:SetScript("OnUpdate", self.OnUpdate)
	self.Text:SetTextColor(0.1, 0.9, 0.1)
end

function Gathering:PauseTimer()
	self:SetScript("OnUpdate", nil)
	self.Text:SetTextColor(0.9, 0.9, 0.1)
end

function Gathering:ToggleTimer()
	if (not self:GetScript("OnUpdate")) then
		self:StartTimer()
	else
		self:PauseTimer()
	end
end

function Gathering:Reset()
	self:SetScript("OnUpdate", nil)
	
	wipe(self.Gathered)
	wipe(self.SecondsPerItem)
	
	self.NumTypes = 0
	self.TotalGathered = 0
	self.Seconds = 0
	self.Elapsed = 0
	
	self.Text:SetTextColor(1, 1, 1)
	self.Text:SetText(date("!%X", self.Seconds))
	
	if self.MouseIsOver then
		self:OnLeave()
	end
	
	if self.Settings["hide-idle"] then
		self:Hide()
	end
end

function Gathering:FormatTime(seconds)
	if (seconds > 59) then
		return format("%dm", ceil(seconds / 60))
	else
		return format("%0.1fs", seconds)
	end
end

function Gathering:CreateHeader(text)
	local Header = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Header:SetSize(190, 20)
	
	Header.BG = Header:CreateTexture(nil, "BORDER")
	Header.BG:SetTexture(BlankTexture)
	Header.BG:SetVertexColor(0, 0, 0)
	Header.BG:SetPoint("TOPLEFT", Header, 0, 0)
	Header.BG:SetPoint("BOTTOMRIGHT", Header, 0, 0)
	
	Header.Tex = Header:CreateTexture(nil, "OVERLAY")
	Header.Tex:SetTexture(BarTexture)
	Header.Tex:SetPoint("TOPLEFT", Header, 1, -1)
	Header.Tex:SetPoint("BOTTOMRIGHT", Header, -1, 1)
	Header.Tex:SetVertexColor(0.2, 0.2, 0.2)
	
	Header.Text = Header:CreateFontString(nil, "OVERLAY")
	Header.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	Header.Text:SetPoint("LEFT", Header, 3, 0)
	Header.Text:SetJustifyH("LEFT")
	Header.Text:SetShadowColor(0, 0, 0)
	Header.Text:SetShadowOffset(1, -1)
	Header.Text:SetText(text)
	
	tinsert(self.GUI.Window.Widgets, Header)
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
		self.Tex:SetVertexColor(0.8, 0, 0)
		Gathering:UpdateSettingValue(self.Setting, false)
		
		if self.Hook then
			self:Hook(false)
		end
	else
		self.Tex:SetVertexColor(0, 0.8, 0)
		Gathering:UpdateSettingValue(self.Setting, true)
		
		if self.Hook then
			self:Hook(true)
		end
	end
end

function Gathering:CreateCheckbox(key, text, func)
	local Checkbox = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Checkbox:SetSize(20, 20)
	Checkbox:SetScript("OnMouseUp", self.CheckBoxOnMouseUp)
	Checkbox.Setting = key
	
	Checkbox.BG = Checkbox:CreateTexture(nil, "BORDER")
	Checkbox.BG:SetTexture(BlankTexture)
	Checkbox.BG:SetVertexColor(0, 0, 0)
	Checkbox.BG:SetPoint("TOPLEFT", Checkbox, 0, 0)
	Checkbox.BG:SetPoint("BOTTOMRIGHT", Checkbox, 0, 0)
	
	Checkbox.Tex = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Tex:SetTexture(BarTexture)
	Checkbox.Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	
	Checkbox.Text = Checkbox:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 3, 0)
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetShadowColor(0, 0, 0)
	Checkbox.Text:SetShadowOffset(1, -1)
	Checkbox.Text:SetText(text)
	
	if self.Settings[key] then
		Checkbox.Tex:SetVertexColor(0, 0.8, 0)
	else
		Checkbox.Tex:SetVertexColor(0.8, 0, 0)
	end
	
	if func then
		Checkbox.Hook = func
	end
	
	tinsert(self.GUI.Window.Widgets, Checkbox)
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

function Gathering:CreateDiscord()
	local EditBox = CreateFrame("EditBox", nil, self.GUI.OuterBackdrop)
	EditBox:SetSize(116, 20)
	EditBox:SetPoint("BOTTOMLEFT", 4, 3)
	EditBox:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	EditBox:SetShadowColor(0, 0, 0)
	EditBox:SetShadowOffset(1, -1)
	EditBox:SetFrameLevel(10)
	EditBox:SetFrameStrata("MEDIUM")
	EditBox:SetJustifyH("LEFT")
	EditBox:SetAutoFocus(false)
	EditBox:EnableKeyboard(true)
	EditBox:EnableMouse(true)
	EditBox:SetMaxLetters(19)
	EditBox:SetTextInsets(5, 0, 0, 0)
	EditBox:SetText("discord.gg/XefDFa6nJR")
	EditBox:SetScript("OnEnterPressed", self.DiscordOnEscapePressed)
	EditBox:SetScript("OnEscapePressed", self.DiscordOnEscapePressed)
	EditBox:SetScript("OnMouseDown", self.DiscordOnMouseDown)
	--EditBox:SetScript("OnChar", self.OnEditChar)
	
	--[[EditBox.Tex = EditBox:CreateTexture(nil, "BACKGROUND")
	EditBox.Tex:SetTexture(BarTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.4, 0.4, 0.4)]]
	
	EditBox.BG = EditBox:CreateTexture(nil, "BACKGROUND")
	EditBox.BG:SetTexture(BlankTexture)
	EditBox.BG:SetVertexColor(0.3, 0.3, 0.3)
	EditBox.BG:SetPoint("TOPLEFT", EditBox, 0, 0)
	EditBox.BG:SetPoint("BOTTOMRIGHT", self.GUI.OuterBackdrop, -4, 4)
	
	EditBox.BG = EditBox:CreateTexture(nil, "BACKGROUND")
	EditBox.BG:SetTexture(BlankTexture)
	EditBox.BG:SetVertexColor(0.2, 0.2, 0.2)
	EditBox.BG:SetPoint("TOPLEFT", EditBox, 0, 0)
	EditBox.BG:SetPoint("BOTTOMRIGHT", EditBox, -0, 1)
	
	EditBox.Button = CreateFrame("Frame", nil, EditBox)
	EditBox.Button:SetHeight(20)
	EditBox.Button:SetPoint("LEFT", EditBox, "RIGHT", 0, 0)
	EditBox.Button:SetPoint("BOTTOMRIGHT", self.GUI.OuterBackdrop, 4, 3)
	EditBox.Button:SetScript("OnMouseUp", self.DiscordButtonOnMouseDown)
	
	EditBox.Text = EditBox:CreateFontString(nil, "OVERLAY")
	EditBox.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	EditBox.Text:SetPoint("LEFT", EditBox, "RIGHT", 5, 0)
	EditBox.Text:SetJustifyH("LEFT")
	EditBox.Text:SetShadowColor(0, 0, 0)
	EditBox.Text:SetShadowOffset(1, -1)
	EditBox.Text:SetText("Join Discord")
end

function Gathering:CreateEditBox(text, func)
	local EditBox = CreateFrame("EditBox", nil, self.GUI.ButtonParent)
	EditBox:SetSize(168, 20)
	EditBox:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
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
	EditBox:SetScript("OnChar", self.OnEditChar)
	
	EditBox.BG = EditBox:CreateTexture(nil, "BORDER")
	EditBox.BG:SetTexture(BlankTexture)
	EditBox.BG:SetVertexColor(0, 0, 0)
	EditBox.BG:SetPoint("TOPLEFT", EditBox, 0, 0)
	EditBox.BG:SetPoint("BOTTOMRIGHT", EditBox, 0, 0)
	
	EditBox.Tex = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Tex:SetTexture(BarTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.4, 0.4, 0.4)
	
	EditBox.Icon = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Icon:SetPoint("LEFT", EditBox, "RIGHT", 3, 0)
	EditBox.Icon:SetSize(18, 18)
	EditBox.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	EditBox.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	EditBox.BG = EditBox:CreateTexture(nil, "BORDER")
	EditBox.BG:SetTexture(BlankTexture)
	EditBox.BG:SetVertexColor(0, 0, 0)
	EditBox.BG:SetPoint("TOPLEFT", EditBox.Icon, -1, 1)
	EditBox.BG:SetPoint("BOTTOMRIGHT", EditBox.Icon, 1, -1)
	
	if func then
		EditBox.Hook = func
	end
	
	tinsert(self.GUI.Window.Widgets, EditBox)
end

local ScrollSelections = function(self)
	local First = false
	
	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + MaxSelections - 1) then
			if (not First) then
				self[i]:SetPoint("TOPLEFT", self, 0, -1)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 1)
			end
			
			self[i]:Show()
		else
			self[i]:Hide()
		end
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
	--self.ScrollBar:SetValue(self.Offset)
end

local FontListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()
	
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Key), 12)
	Selection.Current:SetText(self.Key)
	
	Selection.List:Hide()
	
	Gathering:UpdateSettingValue(Selection.Setting, self.Key)
	
	if Selection.Hook then
		Selection:Hook(self.Key)
	end
	
	Selection.Arrow:SetTexture("Interface\\AddOns\\Gathering\\HydraUIArrowDown.tga")
end

local FontSelectionOnMouseUp = function(self)
	if (not self.List) then
		self.List = CreateFrame("Frame", nil, self)
		self.List:SetSize(128, 20 * MaxSelections)
		self.List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		self.List.Offset = 1
		self.List:EnableMouseWheel(true)
		self.List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		self.List:Hide()
		
		for Key, Path in next, self.Selections do
			local Selection = CreateFrame("Frame", nil, self.List)
			Selection:SetSize(128, 20)
			Selection.Key = Key
			Selection.Path = Path
			Selection:SetScript("OnMouseUp", FontListOnMouseUp)
			
			Selection.BG = Selection:CreateTexture(nil, "BORDER")
			Selection.BG:SetTexture(BlankTexture)
			Selection.BG:SetVertexColor(0, 0, 0)
			Selection.BG:SetPoint("TOPLEFT", Selection, 0, 0)
			Selection.BG:SetPoint("BOTTOMRIGHT", Selection, 0, 0)
			
			Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
			Selection.Tex:SetTexture(BarTexture)
			Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Selection.Tex:SetVertexColor(0.4, 0.4, 0.4)
			
			Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
			Selection.Text:SetFont(Path, 12)
			Selection.Text:SetSize(122, 18)
			Selection.Text:SetPoint("LEFT", Selection, 3, 0)
			Selection.Text:SetJustifyH("LEFT")
			Selection.Text:SetShadowColor(0, 0, 0)
			Selection.Text:SetShadowOffset(1, -1)
			Selection.Text:SetText(Key)
			
			tinsert(self.List, Selection)
		end
		
		table.sort(self.List, function(a, b)
			return a.Key < b.Key
		end)
		
		ScrollSelections(self.List)
	end
	
	if self.List:IsShown() then
		self.List:Hide()
		self.Arrow:SetTexture("Interface\\AddOns\\Gathering\\HydraUIArrowDown.tga")
	else
		self.List:Show()
		self.Arrow:SetTexture("Interface\\AddOns\\Gathering\\HydraUIArrowUp.tga")
	end
end

function Gathering:CreateFontSelection(key, text, selections, func)
	local Selection = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Selection:SetSize(128, 20)
	Selection:SetScript("OnMouseUp", FontSelectionOnMouseUp)
	Selection.Selections = selections
	Selection.Setting = key
	
	Selection.BG = Selection:CreateTexture(nil, "BORDER")
	Selection.BG:SetTexture(BlankTexture)
	Selection.BG:SetVertexColor(0, 0, 0)
	Selection.BG:SetPoint("TOPLEFT", Selection, 0, 0)
	Selection.BG:SetPoint("BOTTOMRIGHT", Selection, 0, 0)
	
	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BarTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.4, 0.4, 0.4)
	
	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture("Interface\\AddOns\\Gathering\\HydraUIArrowDown.tga")
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(0, 204/255, 106/255)
	
	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings[key]), 12)
	Selection.Current:SetSize(122, 18)
	Selection.Current:SetPoint("LEFT", Selection, 3, 0)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(self.Settings[key])
	
	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)
	
	if func then
		Selection.Hook = func
	end
	
	tinsert(self.GUI.Window.Widgets, Selection)
end

local Scroll = function(self)
	local First = false
	
	for i = 1, #self.Widgets do
		if (i >= self.Offset) and (i <= self.Offset + MaxWidgets - 1) then
			if (not First) then
				self.Widgets[i]:SetPoint("TOPLEFT", Gathering.GUI.ButtonParent, 2, -2)
				First = true
			else
				self.Widgets[i]:SetPoint("TOPLEFT", self.Widgets[i-1], "BOTTOMLEFT", 0, -2)
			end
			
			self.Widgets[i]:Show()
		else
			self.Widgets[i]:Hide()
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
		
		if (self.Offset > (#self.Widgets - (MaxWidgets - 1))) then
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
	Gathering.Text:SetFont(SharedMedia:Fetch("font", value), 14)
	Gathering:UpdateTooltipFont()
end

function Gathering:SettingsLayout()
	self:CreateHeader("Set Font")
	
	self:CreateFontSelection("window-font", "", Fonts, self.UpdateFontSetting)
	
	self:CreateHeader(TRACKING)
	
	self:CreateCheckbox("track-ore", L["Ore"], self.UpdateOreTracking)
	self:CreateCheckbox("track-herbs", L["Herbs"], self.UpdateHerbTracking)
	self:CreateCheckbox("track-leather", L["Leather"], self.UpdateLeatherTracking)
	self:CreateCheckbox("track-cooking", L["Cooking"], self.UpdateCookingTracking)
	self:CreateCheckbox("track-cloth", L["Cloth"], self.UpdateClothTracking)
	self:CreateCheckbox("track-enchanting", L["Enchanting"], self.UpdateEnchantingTracking)
	self:CreateCheckbox("track-jewelcrafting", L["Jewelcrafting"], self.UpdateJewelcraftingTracking)
	self:CreateCheckbox("track-weapons", L["Weapons"], self.UpdateWeaponTracking)
	self:CreateCheckbox("track-armor", L["Armor"], self.UpdateArmorTracking)
	self:CreateCheckbox("track-mounts", L["Mounts"], self.UpdateMountTracking)
	self:CreateCheckbox("track-consumables", L["Consumables"], self.UpdateConsumableTracking)
	self:CreateCheckbox("track-reagents", L["Reagents"], self.UpdateReagentTracking)
	
	self:CreateHeader(MISCELLANEOUS)
	
	self:CreateCheckbox("ignore-bop", L[L["Ignore Bind on Pickup"]])
	self:CreateCheckbox("hide-idle", L["Hide while idle"], self.ToggleTimerPanel)
	self:CreateCheckbox("show-tooltip", L["Show tooltip data"])
	
	self:CreateHeader(IGNORE)
	
	self:CreateEditBox(L["Ignore items"], self.AddIgnoredItem)
	
	self:CreateHeader(UNIGNORE_QUEST)
	
	self:CreateEditBox(L["Unignore items"], self.RemoveIgnoredItem)
	
	self:CreateDiscord()
end

function Gathering:CreateGUI()
	-- Window
	self.GUI = CreateFrame("Frame", "Gathering Settings", UIParent)
	self.GUI:SetSize(210, 18)
	self.GUI:SetPoint("CENTER", UIParent, 0, 160)
	self.GUI:SetMovable(true)
	self.GUI:EnableMouse(true)
	self.GUI:SetUserPlaced(true)
	self.GUI:RegisterForDrag("LeftButton")
	self.GUI:SetScript("OnDragStart", self.GUI.StartMoving)
	self.GUI:SetScript("OnDragStop", self.GUI.StopMovingOrSizing)
	
	self.GUI.BG = self.GUI:CreateTexture(nil, "BORDER")
	self.GUI.BG:SetPoint("TOPLEFT", self.GUI, -1, 1)
	self.GUI.BG:SetPoint("BOTTOMRIGHT", self.GUI, 1, -1)
	self.GUI.BG:SetTexture(BlankTexture)
	self.GUI.BG:SetVertexColor(0, 0, 0)
	
	self.GUI.Texture = self.GUI:CreateTexture(nil, "OVERLAY")
	self.GUI.Texture:SetPoint("TOPLEFT", self.GUI, 0, 0)
	self.GUI.Texture:SetPoint("BOTTOMRIGHT", self.GUI, 0, 0)
	self.GUI.Texture:SetTexture(BarTexture)
	self.GUI.Texture:SetVertexColor(0.2, 0.2, 0.2)
	
	self.GUI.Text = self.GUI:CreateFontString(nil, "OVERLAY")
	self.GUI.Text:SetPoint("LEFT", self.GUI, 3, -0.5)
	self.GUI.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	self.GUI.Text:SetJustifyH("LEFT")
	self.GUI.Text:SetShadowColor(0, 0, 0)
	self.GUI.Text:SetShadowOffset(1, -1)
	self.GUI.Text:SetText("|cff00CC6AGathering|r " .. AddOnVersion)
	
	self.GUI.CloseButton = CreateFrame("Frame", nil, self.GUI)
	self.GUI.CloseButton:SetPoint("TOPRIGHT", self.GUI, 0, 0)
	self.GUI.CloseButton:SetSize(18, 18)
	self.GUI.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	self.GUI.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	self.GUI.CloseButton:SetScript("OnMouseUp", function() self.GUI:Hide() end)
	
	self.GUI.CloseButton.Texture = self.GUI.CloseButton:CreateTexture(nil, "OVERLAY")
	self.GUI.CloseButton.Texture:SetPoint("CENTER", self.GUI.CloseButton, 0, -0.5)
	self.GUI.CloseButton.Texture:SetTexture("Interface\\AddOns\\Gathering\\HydraUIClose.tga")
	
	self.GUI.Window = CreateFrame("Frame", nil, self.GUI)
	self.GUI.Window:SetSize(210, 244)
	self.GUI.Window:SetPoint("TOPLEFT", self.GUI, "BOTTOMLEFT", 0, -4)
	self.GUI.Window.Offset = 1
	self.GUI.Window.Widgets = {}
	
	self.GUI.Window:EnableMouseWheel(true)
	self.GUI.Window:SetScript("OnMouseWheel", WindowOnMouseWheel)
	
	self.GUI.Backdrop = self.GUI.Window:CreateTexture(nil, "BORDER")
	self.GUI.Backdrop:SetPoint("TOPLEFT", self.GUI.Window, -1, 1)
	self.GUI.Backdrop:SetPoint("BOTTOMRIGHT", self.GUI.Window, 1, -21) --  -1
	self.GUI.Backdrop:SetTexture(BlankTexture)
	self.GUI.Backdrop:SetVertexColor(0, 0, 0)
	
	self.GUI.Inside = self.GUI.Window:CreateTexture(nil, "BORDER")
	self.GUI.Inside:SetAllPoints()
	self.GUI.Inside:SetTexture(BlankTexture)
	self.GUI.Inside:SetVertexColor(0.2, 0.2, 0.2)
	
	self.GUI.ButtonParent = CreateFrame("Frame", nil, self.GUI.Window)
	self.GUI.ButtonParent:SetAllPoints()
	self.GUI.ButtonParent:SetFrameLevel(self.GUI.Window:GetFrameLevel() + 4)
	self.GUI.ButtonParent:SetFrameStrata("HIGH")
	self.GUI.ButtonParent:EnableMouse(true)
	
	self.GUI.OuterBackdrop = CreateFrame("Frame", nil, self.GUI.Window, "BackdropTemplate")
	self.GUI.OuterBackdrop:SetPoint("TOPLEFT", self.GUI, -4, 4)
	self.GUI.OuterBackdrop:SetPoint("BOTTOMRIGHT", self.GUI.Window, 4, -24) -- -4
	self.GUI.OuterBackdrop:SetBackdrop(Outline)
	self.GUI.OuterBackdrop:SetBackdropColor(0.2, 0.2, 0.2)
	self.GUI.OuterBackdrop:SetBackdropBorderColor(0, 0, 0)
	self.GUI.OuterBackdrop:SetFrameStrata("LOW")
	
	self:SettingsLayout()
	
	-- Scroll bar
	self.GUI.Window.ScrollBar = CreateFrame("Slider", nil, self.GUI.ButtonParent, "BackdropTemplate")
	self.GUI.Window.ScrollBar:SetPoint("TOPRIGHT", self.GUI.Window, -2, -2)
	self.GUI.Window.ScrollBar:SetPoint("BOTTOMRIGHT", self.GUI.Window, -2, 2)
	self.GUI.Window.ScrollBar:SetWidth(14)
	self.GUI.Window.ScrollBar:SetThumbTexture(BlankTexture)
	self.GUI.Window.ScrollBar:SetOrientation("VERTICAL")
	self.GUI.Window.ScrollBar:SetValueStep(1)
	self.GUI.Window.ScrollBar:SetBackdrop(Outline)
	self.GUI.Window.ScrollBar:SetBackdropColor(0.2, 0.2, 0.2)
	self.GUI.Window.ScrollBar:SetBackdropBorderColor(0, 0, 0)
	self.GUI.Window.ScrollBar:SetMinMaxValues(1, (#self.GUI.Window.Widgets - (MaxWidgets - 1)))
	self.GUI.Window.ScrollBar:SetValue(1)
	self.GUI.Window.ScrollBar:EnableMouse(true)
	self.GUI.Window.ScrollBar:SetScript("OnValueChanged", ScrollBarOnValueChanged)
	self.GUI.Window.ScrollBar.Parent = self.GUI.Window
	
	self.GUI.Window.ScrollBar:SetFrameStrata("HIGH")
	self.GUI.Window.ScrollBar:SetFrameLevel(22)
	
	local Thumb = self.GUI.Window.ScrollBar:GetThumbTexture() 
	Thumb:SetSize(14, 20)
	Thumb:SetTexture(BarTexture)
	Thumb:SetVertexColor(0, 0, 0)
	
	self.GUI.Window.ScrollBar.NewTexture = self.GUI.Window.ScrollBar:CreateTexture(nil, "BORDER")
	self.GUI.Window.ScrollBar.NewTexture:SetPoint("TOPLEFT", Thumb, 0, 0)
	self.GUI.Window.ScrollBar.NewTexture:SetPoint("BOTTOMRIGHT", Thumb, 0, 0)
	self.GUI.Window.ScrollBar.NewTexture:SetTexture(BlankTexture)
	self.GUI.Window.ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	self.GUI.Window.ScrollBar.NewTexture2 = self.GUI.Window.ScrollBar:CreateTexture(nil, "OVERLAY")
	self.GUI.Window.ScrollBar.NewTexture2:SetPoint("TOPLEFT", self.GUI.Window.ScrollBar.NewTexture, 1, -1)
	self.GUI.Window.ScrollBar.NewTexture2:SetPoint("BOTTOMRIGHT", self.GUI.Window.ScrollBar.NewTexture, -1, 1)
	self.GUI.Window.ScrollBar.NewTexture2:SetTexture(BarTexture)
	self.GUI.Window.ScrollBar.NewTexture2:SetVertexColor(0.2, 0.2, 0.2)
	
	Scroll(self.GUI.Window)
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
	
	print(L["|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds."])
	
	GatheringLastScan = GetTime()
end

function Gathering:CHAT_MSG_LOOT(msg)
	if (not msg) then
		return
	end
	
	if (InboxFrame:IsVisible() or (GuildBankFrame and GuildBankFrame:IsVisible())) then -- Ignore useless info
		return
	end
	
	local PreMessage, _, ItemString, Name, Quantity = match(msg, LootMatch)
	
	if (not ItemString) then
		return
	end
	
	local LinkType, ID = match(ItemString, "^(%a+):(%d+)")
	
	if (PreMessage ~= LootMessage) then
		return
	end
	
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
		self.NumTypes = self.NumTypes + 1
	end
	
	if (not self.Gathered[SubType][ID]) then
		self.Gathered[SubType][ID] = 0
	end
	
	if (not self.SecondsPerItem[ID]) then
		self.SecondsPerItem[ID] = 0
	end
	
	self.Gathered[SubType][ID] = self.Gathered[SubType][ID] + Quantity
	self.TotalGathered = self.TotalGathered + Quantity -- For gathered/hr stat
	
	if (not self:GetScript("OnUpdate")) then
		self:StartTimer()
	end
	
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
	
	print(L["|cff00CC6AGathering|r updated market prices."])
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
		local ID = tonumber(match(Link, "^|cff%x+|Hitem:(%d+)"))
		local Price = Gathering:GetPrice(ID, Link)
		
		if (Price and Price > 0) then
			self:AddLine(" ")
			self:AddLine("|cff00CC6AGathering|r")
			self:AddLine(format(L["Price per unit: %s"], Gathering:CopperToGold(Price)), 1, 1, 1)
		end
	end
end

local SendVersion = function()
	local Info
	local NumFriends = BNGetNumFriends()
	
	for i = 1, NumFriends do
		Info = C_BattleNet.GetFriendAccountInfo(i)
		
		if (Info.gameAccountInfo.clientProgram == "WoW") then
			if (Info.gameAccountInfo.wowProjectID == 1) and Info.gameAccountInfo.isOnline and (Info.gameAccountInfo.realmName == MyRealm) and Info.gameAccountInfo.factionName == UnitFactionGroup("player") then
				SendAddonMessage("Gathering-Version", AddOnVersion, "WHISPER", Info.gameAccountInfo.characterName)
			end
		end
	end
	
	for i = 1, C_FriendList.GetNumFriends() do
		Info = C_FriendList.GetFriendInfoByIndex(i)
		
		if Info.connected then
			SendAddonMessage("Gathering-Version", AddOnVersion, "WHISPER", Info.name)
		end
	end
	
	Info = nil
end

function Gathering:PLAYER_ENTERING_WORLD()
	self.MarketPrices = GatheringMarketPrices or {}
	self.Ignored = GatheringIgnore or {}
	
	if IsAddOnLoaded("TradeSkillMaster") then
		self.HasTSM = true
	end
	
	GameTooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
	
	if (not GatheringSettings) then
		GatheringSettings = {}
	end
	
	self.Settings = setmetatable(GatheringSettings, {__index = self.DefaultSettings})
	
	self:CreateWindow()
	
	self:UpdateWeaponTracking(self.Settings["track-weapons"])
	self:UpdateArmorTracking(self.Settings["track-armor"])
	self:UpdateJewelcraftingTracking(self.Settings["track-jewelcrafting"])
	self:UpdateClothTracking(self.Settings["track-cloth"])
	self:UpdateLeatherTracking(self.Settings["track-leather"])
	self:UpdateOreTracking(self.Settings["track-ore"])
	self:UpdateCookingTracking(self.Settings["track-cooking"])
	self:UpdateHerbTracking(self.Settings["track-herbs"])
	self:UpdateEnchantingTracking(self.Settings["track-enchanting"])
	self:UpdateMountTracking(self.Settings["track-mounts"])
	self:UpdateConsumableTracking(self.Settings["track-consumables"])
	self:UpdateReagentTracking(self.Settings["track-reagents"])
	self:UpdateOtherTracking(self.Settings["track-other"])
	
	if self.Settings["hide-idle"] then
		self:Hide()
	end
	
	if IsInGuild() then
		SendAddonMessage("Gathering-Version", AddOnVersion, "GUILD")
	end
	
	if (IsInRaid() and UnitExists("raid1")) then
		SendAddonMessage("Gathering-Version", AddOnVersion, "RAID")
	elseif (IsInGroup() and UnitExists("party1")) then
		SendAddonMessage("Gathering-Version", AddOnVersion, "PARTY")
	end
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Gathering:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		SendAddonMessage("Gathering-Version", AddOnVersion, "GUILD")
	end
end

function Gathering:GROUP_ROSTER_UPDATE()
	if IsInRaid() and UnitExists("raid1") then
		SendAddonMessage("Gathering-Version", AddOnVersion, "RAID")
	elseif IsInGroup() and UnitExists("party1") then
		SendAddonMessage("Gathering-Version", AddOnVersion, "PARTY")
	end
end

function Gathering:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	sender = match(sender, "(%S+)-%S+")
	
	if (sender == Me or prefix ~= "Gathering-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (channel == "WHISPER") then
		if (message > AddOnVersion) then
			print(format("Update |cff00CC6AGathering|r to version %s! www.curseforge.com/wow/addons/gathering", message))
			print("Join the Discord community for support and feedback discord.gg/XefDFa6nJR")
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
		end
	else
		if (AddOnVersion > message) then -- We have a higher version, share it
			SendAddonMessage("Gathering-Version", AddOnVersion, "WHISPER", sender)
		elseif (message > AddOnVersion) then -- We're behind!
			print(format("Update |cff00CC6AGathering|r to version %s! www.curseforge.com/wow/addons/gathering", message))
			print("Join the Discord community for support and feedback discord.gg/XefDFa6nJR")
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
		end
	end
end

function Gathering:AUCTION_HOUSE_SHOW()
	if (not self.ScanButton and AuctionHouseFrame) then
		self.ScanButton = CreateFrame("Button", "Gathering Scan Button", AuctionHouseFrame.MoneyFrameBorder, "UIPanelButtonTemplate")
		self.ScanButton:SetSize(140, 24)
		self.ScanButton:SetPoint("LEFT", AuctionHouseFrame.MoneyFrameBorder, "RIGHT", 3, 0)
		self.ScanButton:SetText("Gathering Scan")
		self.ScanButton:SetScript("OnClick", self.ScanButtonOnClick)
	end
end

function Gathering:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Gathering:GetPrice(id, link)
	if self.HasTSM then
		return TSM_API.GetCustomPriceValue("dbMarket", TSM_API.ToItemString(link))
		--return TSM_API.GetCustomPriceValue("dbMinBuyout", TSM_API.ToItemString(link))
	else
		return self.MarketPrices[id]
	end
end

function Gathering:OnEnter()
	if (self.TotalGathered == 0) then
		return
	end
	
	self.MouseIsOver = true
	
	local Count = 0
	local MarketTotal = 0
	
	self.Tooltip:SetOwner(self, "ANCHOR_NONE")
	self.Tooltip:SetPoint("TOP", self, "BOTTOM", 0, -2)
	self.Tooltip:ClearLines()
	
	self.Tooltip:AddLine(L["Gathering"])
	self.Tooltip:AddLine(" ")
	
	for SubType, Info in pairs(self.Gathered) do
		self.Tooltip:AddLine(SubType, 1, 1, 0)
		Count = Count + 1
		
		for ID, Value in pairs(Info) do
			local Name, Link, Rarity = GetItemInfo(ID)
			local Hex = "|cffFFFFFF"
			
			if Rarity then
				Hex = ITEM_QUALITY_COLORS[Rarity].hex
			end
			
			local Price = self:GetPrice(ID, Link)
			
			if Price then
				MarketTotal = MarketTotal + (Price * Value)
			end
			
			if (IsShiftKeyDown() and Price) then
				self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s/%s)", Value, self:CopperToGold((Price * Value / max(self.SecondsPerItem[ID], 1)) * 60 * 60), L["Hr"]), 1, 1, 1, 1, 1, 1)
			else
				self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s/%s)", Value, floor((Value / max(self.SecondsPerItem[ID], 1)) * 60 * 60), L["Hr"]), 1, 1, 1, 1, 1, 1)
			end
		end
		
		if (Count ~= self.NumTypes) then
			self.Tooltip:AddLine(" ")
		end
	end
	
	self.Tooltip:AddLine(" ")
	self.Tooltip:AddDoubleLine(L["Total Gathered:"], self.TotalGathered, nil, nil, nil, 1, 1, 1)
	
	if (IsShiftKeyDown() and MarketTotal > 0) then
		self.Tooltip:AddDoubleLine(L["Total Average Per Hour:"], self:CopperToGold((MarketTotal / max(self.Seconds, 1)) * 60 * 60), nil, nil, nil, 1, 1, 1)
	else
		self.Tooltip:AddDoubleLine(L["Total Average Per Hour:"], BreakUpLargeNumbers(floor(((self.TotalGathered / max(self.Seconds, 1)) * 60 * 60))), nil, nil, nil, 1, 1, 1)
	end
	
	if (MarketTotal > 0) then
		self.Tooltip:AddDoubleLine(L["Total Value:"], self:CopperToGold(MarketTotal), nil, nil, nil, 1, 1, 1)
	end
	
	self.Tooltip:AddLine(" ")
	self.Tooltip:AddLine(L["Left click: Toggle timer"])
	self.Tooltip:AddLine(L["Right click: Reset data"])
	
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
		self:Reset()
	elseif (button == "MiddleButton") then
		if (self.Tooltip.Override == true) then
			self.Tooltip.Override = false
		else
			self.Tooltip.Override = true
		end
	end
end

Gathering:RegisterEvent("GUILD_ROSTER_UPDATE")
Gathering:RegisterEvent("GROUP_ROSTER_UPDATE")
Gathering:RegisterEvent("CHAT_MSG_ADDON")
Gathering:RegisterEvent("CHAT_MSG_LOOT")
Gathering:RegisterEvent("AUCTION_HOUSE_SHOW")
Gathering:RegisterEvent("PLAYER_ENTERING_WORLD")
Gathering:SetScript("OnEvent", Gathering.OnEvent)
Gathering:SetScript("OnEnter", Gathering.OnEnter)
Gathering:SetScript("OnLeave", Gathering.OnLeave)
Gathering:SetScript("OnMouseUp", Gathering.OnMouseUp)

SLASH_GATHERING1 = "/gather"
SLASH_GATHERING2 = "/gathering"
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

C_ChatInfo.RegisterAddonMessagePrefix("Gathering-Version")