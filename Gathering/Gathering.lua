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
local Font = "Interface\\Addons\\Gathering\\PTSans.ttf"

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

-- Tett
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
	
	-- Check that we want to track the type of item
	--if (self.TrackedItemTypes[ClassID] and not self.TrackedItemTypes[ClassID][SubClassID]) then
	if (not self.Tracked[ID]) then
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
		
		if (HasAllInfo and self.Tracked[ID]) then
			self.MarketPrices[Name] = Buyout / Count
			GatheringMarketPrices[Name] = self.MarketPrices[Name]
		elseif (ID and self.Tracked[ID]) then
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
	
	print("Gathering updated market prices.")
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

function Gathering:FormatTime(seconds)
	if (seconds > 59) then
		return format("%dm", ceil(seconds / 60))
	else
		return format("%0.1fs", seconds)
	end
end

function Gathering:OnScanButtonOnMouseUp()
	local TimeDiff = (GetTime() - (GatheringLastScan or 0))
	
	if (1200 > TimeDiff) then -- 20 minute throttle
		print(format("You must wait %s until you can scan again.", Gathering:FormatTime(1200 - TimeDiff)))
		return
	end
	
	if Gathering:IsEventRegistered("REPLICATE_ITEM_LIST_UPDATE") then -- Awaiting results already
		return
	end
	
	Gathering:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")
	
	ReplicateItems()
	
	print("Gathering is scanning market prices. This will take ~10 seconds.")
	
	GatheringLastScan = GetTime()
end

function Gathering:AUCTION_HOUSE_SHOW()
	if (not self.ScanButton) then
		self.ScanButton = CreateFrame("Button", "Gathering Scan Button", AuctionHouseFrame.MoneyFrameBorder, "UIPanelButtonTemplate")
		self.ScanButton:SetSize(140, 24)
		self.ScanButton:SetPoint("LEFT", AuctionHouseFrame.MoneyFrameBorder, "RIGHT", 3, 0)
		self.ScanButton:SetText("Gathering Scan")
		self.ScanButton:SetScript("OnMouseUp", self.OnScanButtonOnMouseUp)
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

Gathering.Tracked = {
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
	[152631] = true,   -- Briny Flesh
	[154898] = true,   -- Meaty Haunch
	
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
	
	-- Warlords of Draenor
	[111557] = true,   -- Sumptuous Fur
	
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
	
	-- Warlords of Draenor
	[108439] = true,   -- Draenor Clan Orator Cane
	[109584] = true,   -- Ogre Missive
	[109585] = true,   -- Arakkoa Cipher
	
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
	
	-- Alchemy
	[152638] = true,   -- Flask of the Currents
	[168651] = true,   -- Greater Flask of the Currents
	[152641] = true,   -- Flask of the Undertow
	[168654] = true,   -- Greater Flask of the Undertow
	[152639] = true,   -- Flask of Endless Fathoms
	[168652] = true,   -- Greater Flask of Endless Fathoms
	[152640] = true,   -- Flask of the Vast Horizon
	[168653] = true,   -- Greater Flask of the Vast Horizon
	[168656] = true,   -- Greater Mystical Cauldron
	[169451] = true,   -- Abyssal Healing Potion
	[169299] = true,   -- Potion of Unbridled Fury
	[169300] = true,   -- Potion of Wild Mending
	[168529] = true,   -- Potion of Empowered Proximity
	[168506] = true,   -- Potion of Focused Resolve
	[168489] = true,   -- Superior Battle Potion of Agility
	[168498] = true,   -- Superior Battle Potion of Intellect
	[168500] = true,   -- Superior Battle Potion of Strength
	[168499] = true,   -- Superior Battle Potion of Stamina
	[168501] = true,   -- Superior Steelskin Potion
	
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
	
	-- Primals
	[21884] = true,   -- Primal Fire
	[22457] = true,   -- Primal Mana
	[21885] = true,   -- Primal Water
	[22451] = true,   -- Primal Air
	[22452] = true,   -- Primal Earth
	
	-- Crystallized
	[37700] = true,   -- Crystallized Air
	[37701] = true,   -- Crystallized Earth
	[37702] = true,   -- Crystallized Fire
	[37703] = true,   -- Crystallized Shadow
	[37704] = true,   -- Crystallized Life
	[37705] = true,   -- Crystallized Water
	
	-- Volatiles
	[52325] = true,   -- Volatile Fire
	[52326] = true,   -- Volatile Water
	[52327] = true,   -- Volatile Earth
	[52328] = true,   -- Volatile Air
	[52329] = true,   -- Volatile Life
}

--[[Gathering.TrackedItemTypes = {
	[7] = { -- LE_ITEM_CLASS_TRADEGOODS
		[5] = true, -- Cloth
		[6] = true, -- Leather
		[7] = true, -- Metal & Stone
		[8] = true, -- Cooking
		[9] = true, -- Herb
		[12] = true, -- Enchanting
	},
	
	[15] = { -- LE_ITEM_CLASS_MISCELLANEOUS
		[2] = true, -- Companion Pets
		[3] = true, -- Holiday
		[5] = true, -- Mount
	},
}]]