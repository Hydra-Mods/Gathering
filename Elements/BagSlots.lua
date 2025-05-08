local Name, AddOn = ...
local Gathering = AddOn.Gathering
local L = AddOn.L

local GetNumSlots, GetNumFreeSlots, ContainerToInventoryID
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

if C_Container then
	GetNumSlots = C_Container.GetContainerNumSlots
	GetNumFreeSlots = C_Container.GetContainerNumFreeSlots
	ContainerToInventoryID = C_Container.ContainerIDToInventoryID
else
	GetNumSlots = GetContainerNumSlots
	GetNumFreeSlots = GetContainerNumFreeSlots
	ContainerToInventoryID = ContainerIDToInventoryID
end

local GetBagSlotInfo = function()
	local Total, Free = 0, 0

	for i = 0, NUM_BAG_SLOTS do
		local Slots = GetNumSlots(i)

		if Slots then
			Free = Free + GetNumFreeSlots(i)
			Total = Total + Slots
		end
	end

	return Total, (Total - Free)
end

local OnEnter = function(self)
	if (not Gathering.Settings.SlotBarTooltip) then
		return
	end

	local X, Y = self:GetCenter()
	local Tooltip = Gathering.Tooltip

	Tooltip:SetOwner(self, "ANCHOR_NONE")

	if (Y > UIParent:GetHeight() / 2) then
		Tooltip:SetPoint("TOP", self, "BOTTOM", 0, -2)
	else
		Tooltip:SetPoint("BOTTOM", self, "TOP", 0, 2)
	end

	Tooltip:ClearLines()

	local TotalSlots, UsedSlots = GetBagSlotInfo()

	if (TotalSlots == 0) then
		return
	end

	local Percent = math.floor((UsedSlots / TotalSlots) * 100 + 0.5)

	Tooltip:AddLine(L["Bag Space"])
	Tooltip:AddLine(" ")
	Tooltip:AddLine(string.format("%d / %d (%d%%)", UsedSlots, TotalSlots, Percent), 1, 1, 1)

	Gathering:UpdateTooltipFont()

	Tooltip:Show()
end

local OnLeave = function(self)
	Gathering.Tooltip:Hide()
end

function Gathering:HookBagTooltip()
	local BagSlots = self.BagSlots

	BagSlots:HookScript("OnEnter", OnEnter)
	BagSlots:HookScript("OnLeave", OnLeave)
end

function Gathering:BAG_UPDATE()
	local BagSlots = self.BagSlots

	if (not BagSlots) then
		return
	end

	local TotalSlots, UsedSlots = GetBagSlotInfo()

	if (TotalSlots == 0) then
		return
	end

	local Percent = math.floor((UsedSlots / TotalSlots) * 100 + 0.5)
	local Bar = BagSlots.Bar

	if (Percent <= 50) then
		Bar:SetStatusBarColor(0.15, 0.9, 0.15)
	elseif (Percent <= 80) then
		Bar:SetStatusBarColor(0.9, 0.9, 0)
	elseif (Percent <= 95) then
		Bar:SetStatusBarColor(0.9, 0.15, 0)
	else
		Bar:SetStatusBarColor(0.9, 0.15, 0.15)
	end

	Bar:SetMinMaxValues(0, TotalSlots)
	Bar:SetValue(UsedSlots)
	--BagSlots.Text:SetFormattedText("%d / %d", UsedSlots, TotalSlots)
end

Gathering:RegisterEvent("BAG_UPDATE")