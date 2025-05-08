local Name, AddOn = ...
local Gathering = AddOn.Gathering
local L = AddOn.L

function Gathering:BAG_UPDATE_DELAYED()
	if (not self.BagResults) then
		self:UpdateItemsStat()

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

Gathering:RegisterEvent("BAG_UPDATE_DELAYED")
Gathering:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")