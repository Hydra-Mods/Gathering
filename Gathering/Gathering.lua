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
local RarityColor = ITEM_QUALITY_COLORS
local LootMessage = (LOOT_ITEM_SELF:gsub("%%.*", ""))
local LootMatch = "([^|]+)|cff(%x+)|H([^|]+)|h%[([^%]]+)%]|h|r[^%d]*(%d*)"
local MaxWidgets = 11
local BlankTexture = "Interface\\AddOns\\Gathering\\vUIBlank.tga"
local BarTexture = "Interface\\AddOns\\Gathering\\vUI4.tga"
local Font = "Interface\\Addons\\Gathering\\PTSans.ttf"

local Outline = {
	bgFile = BlankTexture,
	edgeFile = BlankTexture,
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

-- Header
local Gathering = CreateFrame("Frame", "Gathering Header", UIParent)
Gathering:SetSize(140, 28)
Gathering:SetPoint("TOP", UIParent, 0, -100)
Gathering:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
Gathering:SetBackdropColor(0, 0, 0, 1)
Gathering:EnableMouse(true)
Gathering:SetMovable(true)
Gathering:SetUserPlaced(true)
Gathering:SetClampedToScreen(true)
Gathering:RegisterForDrag("LeftButton")
Gathering:SetScript("OnDragStart", Gathering.StartMoving)
Gathering:SetScript("OnDragStop", Gathering.StopMovingOrSizing)

-- Text
Gathering.Text = Gathering:CreateFontString(nil, "OVERLAY")
Gathering.Text:SetPoint("CENTER", Gathering, 0, 0)
Gathering.Text:SetJustifyH("CENTER")
Gathering.Text:SetFont(Font, 14)
Gathering.Text:SetText("Gathering")

-- Tooltip
Gathering.Tooltip = CreateFrame("GameTooltip", "Gathering Tooltip", UIParent, "GameTooltipTemplate")

-- Data
Gathering.Gathered = {}
Gathering.TotalGathered = 0
Gathering.NumTypes = 0
Gathering.Elapsed = 0
Gathering.Seconds = 0
Gathering.SecondsPerItem = {}

Gathering.DefaultSettings = {
	["track-ore"] = true,
	["track-herbs"] = true,
	["track-leather"] = true,
	["track-cooking"] = true,
	["track-cloth"] = true,
	["track-enchanting"] = true,
	["track-jewelcrafting"] = true,
	["track-weapons"] = false,
	["track-armor"] = false,
	["track-pets"] = false,
	["track-mounts"] = false,
	["track-consumables"] = false,
	["track-reagents"] = false,
	["track-other"] = false,
}

Gathering.TrackedItemTypes = {
	[LE_ITEM_CLASS_CONSUMABLE] = {},
	[LE_ITEM_CLASS_WEAPON] = {},
	[LE_ITEM_CLASS_ARMOR] = {},
	[LE_ITEM_CLASS_TRADEGOODS] = {},
	[LE_ITEM_CLASS_MISCELLANEOUS] = {},
	[LE_ITEM_CLASS_BATTLEPET] = {},
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
	--Gathering.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_THROWN] = value -- Classic
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
	--[[Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_LIBRAM] = value -- Classic
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_IDOL] = value -- Classic
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_TOTEM] = value -- Classic
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_SIGIL] = value -- Classic]]
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

function Gathering:UpdatePetTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_COMPANION_PET] = value
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
end

function Gathering:UpdateOtherTracking(value)
	Gathering.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_OTHER] = value
end

function Gathering:UpdateFont()
	for i = 1, self.Tooltip:GetNumRegions() do
		local Region = select(i, self.Tooltip:GetRegions())
		
		if (Region:GetObjectType() == "FontString" and not Region.Handled) then
			Region:SetFont(Font, 12)
			Region:SetShadowColor(0, 0, 0)
			Region:SetShadowOffset(1.25, -1.25)
			Region.Handled = true
		end
	end
end

function Gathering:CopperToGold(copper)
	return format("%s|cfff4d03fg|r", BreakUpLargeNumbers(floor((copper / 100) / 100 + 0.5)))
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
end

function Gathering:FormatTime(seconds)
	if (seconds > 59) then
		return format("%dm", ceil(seconds / 60))
	else
		return format("%0.1fs", seconds)
	end
end

function Gathering:CreateHeader(text) -- GENERAL
	-- Main header
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
	Header.Tex:SetVertexColor(0.25, 0.25, 0.25)
	
	Header.Text = Header:CreateFontString(nil, "OVERLAY")
	Header.Text:SetFont(Font, 12)
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
		self:Hook(false)
	else
		self.Tex:SetVertexColor(0, 0.8, 0)
		Gathering:UpdateSettingValue(self.Setting, true)
		self:Hook(true)
	end
end

function Gathering:CreateCheckbox(key, text, func)
	local Checkbox = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Checkbox:SetSize(20, 20)
	Checkbox.Setting = key
	Checkbox.Hook = func
	Checkbox:SetScript("OnMouseUp", self.CheckBoxOnMouseUp)
	
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
	Checkbox.Text:SetFont(Font, 12)
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
	
	tinsert(self.GUI.Window.Widgets, Checkbox)
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
	if (delta == 1) then -- up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- down
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

function Gathering:InitiateSettings()
	self.Settings = {}
	
	for Key, Value in pairs(self.DefaultSettings) do -- Add default values
		self.Settings[Key] = Value
	end
	
	if (not GatheringSettings) then
		GatheringSettings = {}
	else
		for Key, Value in pairs(GatheringSettings) do -- Add stored values
			self.Settings[Key] = Value
		end
	end
	
	self:UpdateWeaponTracking(self.Settings["track-weapons"])
	self:UpdateArmorTracking(self.Settings["track-armor"])
	self:UpdateJewelcraftingTracking(self.Settings["track-jewelcrafting"])
	self:UpdateClothTracking(self.Settings["track-cloth"])
	self:UpdateLeatherTracking(self.Settings["track-leather"])
	self:UpdateOreTracking(self.Settings["track-ore"])
	self:UpdateCookingTracking(self.Settings["track-cooking"])
	self:UpdateHerbTracking(self.Settings["track-herbs"])
	self:UpdateEnchantingTracking(self.Settings["track-enchanting"])
	self:UpdatePetTracking(self.Settings["track-pets"])
	--self:UpdateHolidayTracking(self.Settings["track-weapons"])
	self:UpdateMountTracking(self.Settings["track-mounts"])
	self:UpdateConsumableTracking(self.Settings["track-consumables"])
	self:UpdateReagentTracking(self.Settings["track-reagents"])
	self:UpdateOtherTracking(self.Settings["track-other"])
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
	self.GUI.Texture:SetVertexColor(0.25, 0.25, 0.25)
	
	self.GUI.Text = self.GUI:CreateFontString(nil, "OVERLAY")
	self.GUI.Text:SetPoint("LEFT", self.GUI, 3, -0.5)
	self.GUI.Text:SetFont(Font, 12)
	self.GUI.Text:SetJustifyH("LEFT")
	self.GUI.Text:SetShadowColor(0, 0, 0)
	self.GUI.Text:SetShadowOffset(1, -1)
	self.GUI.Text:SetText("|cff00CC6AGathering|r " .. GetAddOnMetadata("Gathering", "Version"))
	
	self.GUI.CloseButton = CreateFrame("Frame", nil, self.GUI)
	self.GUI.CloseButton:SetPoint("TOPRIGHT", self.GUI, 0, 0)
	self.GUI.CloseButton:SetSize(18, 18)
	self.GUI.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	self.GUI.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	self.GUI.CloseButton:SetScript("OnMouseUp", function() self.GUI:Hide() end)
	
	self.GUI.CloseButton.Texture = self.GUI.CloseButton:CreateTexture(nil, "OVERLAY")
	self.GUI.CloseButton.Texture:SetPoint("CENTER", self.GUI.CloseButton, 0, -0.5)
	self.GUI.CloseButton.Texture:SetTexture("Interface\\AddOns\\Gathering\\vUIClose.tga")
	
	self.GUI.Window = CreateFrame("Frame", nil, self.GUI)
	self.GUI.Window:SetSize(210, 244)
	self.GUI.Window:SetPoint("TOPLEFT", self.GUI, "BOTTOMLEFT", 0, -4)
	self.GUI.Window.Offset = 1
	self.GUI.Window.Widgets = {}
	
	self.GUI.Window:EnableMouseWheel(true)
	self.GUI.Window:SetScript("OnMouseWheel", WindowOnMouseWheel)
	
	self.GUI.Backdrop = self.GUI.Window:CreateTexture(nil, "BORDER")
	self.GUI.Backdrop:SetPoint("TOPLEFT", self.GUI.Window, -1, 1)
	self.GUI.Backdrop:SetPoint("BOTTOMRIGHT", self.GUI.Window, 1, -1)
	self.GUI.Backdrop:SetTexture(BlankTexture)
	self.GUI.Backdrop:SetVertexColor(0, 0, 0)
	
	self.GUI.Inside = self.GUI.Window:CreateTexture(nil, "BORDER")
	self.GUI.Inside:SetAllPoints()
	self.GUI.Inside:SetTexture(BlankTexture)
	self.GUI.Inside:SetVertexColor(0.3, 0.3, 0.3)
	
	self.GUI.ButtonParent = CreateFrame("Frame", nil, self.GUI.Window)
	self.GUI.ButtonParent:SetAllPoints()
	self.GUI.ButtonParent:SetFrameLevel(self.GUI.Window:GetFrameLevel() + 4)
	self.GUI.ButtonParent:SetFrameStrata("HIGH")
	self.GUI.ButtonParent:EnableMouse(true)
	
	self.GUI.OuterBackdrop = CreateFrame("Frame", nil, self.GUI.Window)
	self.GUI.OuterBackdrop:SetPoint("TOPLEFT", self.GUI, -4, 4)
	self.GUI.OuterBackdrop:SetPoint("BOTTOMRIGHT", self.GUI.Window, 4, -4)
	self.GUI.OuterBackdrop:SetBackdrop(Outline)
	self.GUI.OuterBackdrop:SetBackdropColor(0.25, 0.25, 0.25)
	self.GUI.OuterBackdrop:SetBackdropBorderColor(0, 0, 0)
	self.GUI.OuterBackdrop:SetFrameStrata("LOW")
	
	self:InitiateSettings()
	
	-- Layout
	self:CreateHeader(TRACKING) -- GENERAL
	
	self:CreateCheckbox("track-ore", "Ore", self.UpdateOreTracking)
	self:CreateCheckbox("track-herbs", "Herbs", self.UpdateHerbTracking)
	self:CreateCheckbox("track-leather", "Leather", self.UpdateLeatherTracking)
	self:CreateCheckbox("track-cooking", "Cooking", self.UpdateCookingTracking)
	self:CreateCheckbox("track-cloth", "Cloth", self.UpdateClothTracking)
	self:CreateCheckbox("track-enchanting", "Enchanting", self.UpdateEnchantingTracking)
	self:CreateCheckbox("track-jewelcrafting", "Jewelcrafting", self.UpdateJewelcraftingTracking)
	self:CreateCheckbox("track-weapons", "Weapons", self.UpdateWeaponTracking)
	self:CreateCheckbox("track-armor", "Armor", self.UpdateArmorTracking)
	self:CreateCheckbox("track-pets", "Pets", self.UpdatePetTracking)
	self:CreateCheckbox("track-mounts", "Mounts", self.UpdateMountTracking)
	self:CreateCheckbox("track-consumables", "Consumables", self.UpdateConsumableTracking)
	self:CreateCheckbox("track-reagents", "Reagents", self.UpdateReagentTracking)
	--self:CreateCheckbox("track-other", "Other", self.UpdateOtherTracking)
	
	-- Scroll bar
	self.GUI.Window.ScrollBar = CreateFrame("Slider", nil, self.GUI.ButtonParent)
	self.GUI.Window.ScrollBar:SetPoint("TOPRIGHT", self.GUI.Window, -2, -2)
	self.GUI.Window.ScrollBar:SetPoint("BOTTOMRIGHT", self.GUI.Window, -2, 2)
	self.GUI.Window.ScrollBar:SetWidth(14)
	self.GUI.Window.ScrollBar:SetThumbTexture(BlankTexture)
	self.GUI.Window.ScrollBar:SetOrientation("VERTICAL")
	self.GUI.Window.ScrollBar:SetValueStep(1)
	self.GUI.Window.ScrollBar:SetBackdrop(Outline)
	self.GUI.Window.ScrollBar:SetBackdropColor(0.25, 0.25, 0.25)
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
		print(format("You must wait %s until you can scan again.", Gathering:FormatTime(900 - TimeDiff)))
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
	
	print("|cff00CC6AGathering|r is scanning market prices. This should take less than 10 seconds.")
	
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
	local LinkType, ID = match(ItemString, "^(%a+):(%d+)")
	
	if (PreMessage ~= LootMessage) then
		return
	end
	
	ID = tonumber(ID)
	Quantity = tonumber(Quantity) or 1
	local Type, SubType, _, _, _, _, ClassID, SubClassID = select(6, GetItemInfo(ID))
	print(Name, ClassID, SubClassID)
	-- Check that we want to track the type of item
	if ((not self.TrackedItemTypes[ClassID]) or (not self.TrackedItemTypes[ClassID][SubClassID])) then
		return
	end
	
	if (not self.Gathered[SubType]) then
		self.Gathered[SubType] = {}
		self.NumTypes = self.NumTypes + 1
	end
	
	if (not self.Gathered[SubType][Name]) then
		self.Gathered[SubType][Name] = 0
	end
	
	if (not self.SecondsPerItem[Name]) then
		self.SecondsPerItem[Name] = 0
	end
	
	self.Gathered[SubType][Name] = self.Gathered[SubType][Name] + Quantity
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
	
	local Name, Count, Buyout, ID, HasAllInfo, PerUnit, _
	
	for i = 0, (GetNumReplicateItems() - 1) do
		Name, _, Count, _, _, _, _, _, _, Buyout, _, _, _, _, _, _, ID, HasAllInfo = GetReplicateItemInfo(i)
		
		if HasAllInfo then
			self.MarketPrices[Name] = Buyout / Count
			GatheringMarketPrices[Name] = self.MarketPrices[Name]
		elseif ID then
			Item:CreateFromItemID(ID):ContinueOnItemLoad(function()
				Name, _, Count, _, _, _, _, _, _, Buyout, _, _, _, _, _, _, ID = GetReplicateItemInfo(i)
				PerUnit = Buyout / Count
				
				if self.MarketPrices[Name] then
					if (self.MarketPrices[Name] > PerUnit) then -- Collect lowest prices
						self.MarketPrices[Name] = PerUnit
						GatheringMarketPrices[Name] = self.MarketPrices[Name]
					end
				else
					self.MarketPrices[Name] = PerUnit
					GatheringMarketPrices[Name] = self.MarketPrices[Name]
				end
			end)
		end
	end
	
	self:UnregisterEvent("REPLICATE_ITEM_LIST_UPDATE")
	
	print("|cff00CC6AGathering|r updated market prices.")
end

function Gathering:MODIFIER_STATE_CHANGED()
	if self.MouseIsOver then
		self.Tooltip:ClearLines()
		self:OnEnter()
	end
end

function Gathering:PLAYER_ENTERING_WORLD()
	self.MarketPrices = GatheringMarketPrices or {}
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Gathering:AUCTION_HOUSE_SHOW()
	if (not self.ScanButton) then
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

function Gathering:OnEnter()
	if (self.TotalGathered == 0) then
		return
	end
	
	self.MouseIsOver = true
	
	local Count = 0
	local MarketTotal = 0
	
	self.Tooltip:SetOwner(self, "ANCHOR_NONE")
	self.Tooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	self.Tooltip:ClearLines()
	
	self.Tooltip:AddLine("Gathering")
	self.Tooltip:AddLine(" ")
	
	for SubType, Info in pairs(self.Gathered) do
		self.Tooltip:AddLine(SubType, 1, 1, 0)
		Count = Count + 1
		
		for Name, Value in pairs(Info) do
			local Rarity = select(3, GetItemInfo(Name))
			local Hex = "|cffFFFFFF"
			
			if Rarity then
				Hex = RarityColor[Rarity].hex
			end
			
			if self.MarketPrices[Name] then
				MarketTotal = MarketTotal + (self.MarketPrices[Name] * Value)
			end
			
			if (IsShiftKeyDown() and self.MarketPrices[Name]) then
				self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s/Hr)", Value, self:CopperToGold((self.MarketPrices[Name] * Value / max(self.SecondsPerItem[Name], 1)) * 60 * 60)), 1, 1, 1, 1, 1, 1)
			else
				self.Tooltip:AddDoubleLine(format("%s%s|r:", Hex, Name), format("%s (%s/Hr)", Value, floor((Value / max(self.SecondsPerItem[Name], 1)) * 60 * 60)), 1, 1, 1, 1, 1, 1)
			end
		end
		
		if (Count ~= self.NumTypes) then
			self.Tooltip:AddLine(" ")
		end
	end
	
	self.Tooltip:AddLine(" ")
	self.Tooltip:AddDoubleLine("Total Gathered:", self.TotalGathered, nil, nil, nil, 1, 1, 1)
	
	if IsShiftKeyDown() then
		self.Tooltip:AddDoubleLine("Total Average Per Hour:", self:CopperToGold((MarketTotal / max(self.Seconds, 1)) * 60 * 60), nil, nil, nil, 1, 1, 1)
	else
		self.Tooltip:AddDoubleLine("Total Average Per Hour:", BreakUpLargeNumbers(floor(((self.TotalGathered / max(self.Seconds, 1)) * 60 * 60))), nil, nil, nil, 1, 1, 1)
	end
	
	if (MarketTotal > 0) then
		self.Tooltip:AddDoubleLine("Total Value:", self:CopperToGold(MarketTotal), nil, nil, nil, 1, 1, 1)
	end
	
	self.Tooltip:AddLine(" ")
	self.Tooltip:AddLine("Left click: Toggle timer")
	self.Tooltip:AddLine("Right click: Reset data")
	
	self:UpdateFont()
	
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