local Name, AddOn = ...
local Gathering = AddOn.Gathering

-- Generic counting of numbers
local SessionStat = {}

function Gathering:AddStat(stat, value)
	if (not GatheringStats) then
		GatheringStats = {}
	end

	if (not GatheringStats[stat]) then
		GatheringStats[stat] = 0
	end

	if (not SessionStat[stat]) then
		SessionStat[stat] = 0
	end

	GatheringStats[stat] = GatheringStats[stat] + (value or 1)
	SessionStat[stat] = SessionStat[stat] + (value or 1)
end

Gathering.SessionStats = SessionStat