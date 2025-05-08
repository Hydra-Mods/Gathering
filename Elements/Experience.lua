local Name, AddOn = ...
local Gathering = AddOn.Gathering

function Gathering:PLAYER_XP_UPDATE()
	local XP = UnitXP("player")
	local MaxXP = UnitXPMax("player")

	if (MaxXP ~= self.LastMax) then
		local LevelXP = self.LastMax - self.LastXP + XP

		self.XPGained = self.XPGained + LevelXP
		self:AddStat("xp", LevelXP)
		self:AddStat("levels", 1)
	else
		local GainedXP = XP - self.LastXP

		self.XPGained = self.XPGained + GainedXP
		self:AddStat("xp", GainedXP)
	end

	if (not self.XPStartTime) then
		self.XPStartTime = GetTime()
	end

	self:UpdateXPStat()

	self.LastXP = XP
	self.LastMax = MaxXP
end

Gathering:RegisterEvent("PLAYER_XP_UPDATE")