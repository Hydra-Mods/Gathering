local Name, AddOn = ...
local Gathering = AddOn.Gathering
local L = AddOn.L

local ReplicateItems = C_AuctionHouse.ReplicateItems
local GetNumReplicateItems = C_AuctionHouse.GetNumReplicateItems
local GetReplicateItemInfo = C_AuctionHouse.GetReplicateItemInfo

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

function Gathering:AUCTION_HOUSE_SHOW()
	if (not self.ScanButton and AuctionHouseFrame) then
		self.ScanButton = CreateFrame("Button", "Gathering Scan Button", AuctionHouseFrame.MoneyFrameBorder, "UIPanelButtonTemplate")
		self.ScanButton:SetSize(140, 24)
		self.ScanButton:SetPoint("LEFT", AuctionHouseFrame.MoneyFrameBorder, "RIGHT", 3, 0)
		self.ScanButton:SetText(L["Gathering Scan"])
		self.ScanButton:SetScript("OnClick", self.ScanButtonOnClick)
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

Gathering:RegisterEvent("AUCTION_HOUSE_SHOW")
Gathering:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")