local Name, AddOn = ...
local Gathering = AddOn.Gathering
local Quests = {}

function Gathering:QUEST_TURNED_IN(id, xp, money)
	--print(QuestUtils_GetQuestName(id), xp, self:CopperToGold(money)) -- Debug info
	table.insert(Quests, {id, xp, money})

	self:AddStat("quests", 1)
end

Gathering:RegisterEvent("QUEST_TURNED_IN")