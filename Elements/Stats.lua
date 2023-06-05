local Name, AddOn = ...
local Gathering = AddOn.Gathering
local Session = {}

function Gathering:AddStat(stat, value)
	if (not GatheringStats) then
		GatheringStats = {}
	end

	if (not GatheringStats[stat]) then
		GatheringStats[stat] = 0
	end

	if (not Session[stat]) then
		Session[stat] = 0
	end

	GatheringStats[stat] = GatheringStats[stat] + (value or 1)
	Session[stat] = Session[stat] + (value or 1)
end

Gathering.SessionStats = Session