local Name, AddOn = ...
local Gathering = AddOn.Gathering
local Session = {}

function Gathering:CHAT_MSG_COMBAT_FACTION_CHANGE(msg)
	local Faction, Gain = string.match(msg, "Reputation with (%S+) increased by (%d+).") -- FACTION_STANDING_INCREASED
	
	if (not Faction) then
		return
	end
	
	Gain = tonumber(Gain)
	
	if (not Session[Faction]) then
		Session[Faction] = Gain
	else
		Session[Faction] = Session[Faction] + Gain
	end
	
	self:AddStat("rep", Gain)
end

Gathering:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")