local Name, AddOn = ...
local Gathering = AddOn.Gathering

local gsub = string.gsub
local match = string.match
local format = string.format
local reverse = string.reverse
local ceil = math.ceil
local floor = math.floor

local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink

if C_Container then
	GetContainerNumSlots = C_Container.GetContainerNumSlots
	GetContainerItemInfo = C_Container.GetContainerItemInfo
	GetContainerItemLink = C_Container.GetContainerItemLink
end

function Gathering:FormatTime(seconds)
	if (seconds > 59) then
		return format("%dm", ceil(seconds / 60))
	else
		return format("%0.1fs", seconds)
	end
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

	return Left and Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) or number
end

function Gathering:CopperToGold(copper)
	local Gold = floor(copper / (100 * 100))
	local Silver = floor((copper - (Gold * 100 * 100)) / 100)
	local Copper = floor(copper % 100)
	local Separator = ""
	local String = ""

	if (Gold > 0) then
		String = self:Comma(Gold) .. "|cffffe02eg|r"
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

function Gathering:GetPrice(link)
	if self.HasTSM then
		return TSM_API.GetCustomPriceValue("dbMarket", TSM_API.ToItemString(link))
	end
end

function Gathering:GetTrashValue()
	local Profit = 0

	for Bag = 0, 4 do
		for Slot = 1, GetContainerNumSlots(Bag) do
			local Link = GetContainerItemLink(Bag, Slot)

			if Link then
				local Quality = select(3, GetItemInfo(Link)) -- Just list out the arguments as dummies and save the 2 select calls
				local VendorPrice = select(11, GetItemInfo(Link))
				local Count = GetContainerItemInfo(Bag, Slot).stackCount or 1
				local TotalPrice = VendorPrice

				if ((VendorPrice and (VendorPrice > 0)) and Count) then
					TotalPrice = VendorPrice * Count
				end

				if ((Quality and Quality < 1) and TotalPrice > 0) then
					Profit = Profit + TotalPrice
				end
			end
		end
	end

	return Profit
end