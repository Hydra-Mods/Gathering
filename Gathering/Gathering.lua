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

local TrackedItemTypes = {
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
}

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
	if (TrackedItemTypes[ClassID] and not TrackedItemTypes[ClassID][SubClassID]) then
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