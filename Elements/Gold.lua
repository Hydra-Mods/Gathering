local Name, AddOn = ...
local Gathering = AddOn.Gathering

function Gathering:PLAYER_MONEY()
	if ((self.Settings.IgnoreMailMoney and InboxFrame:IsVisible()) or (GuildBankFrame and GuildBankFrame:IsVisible())) then -- Ignore useless info
		return
	end

	local Current = GetMoney()

	if (Current > self.GoldValue) then
		local Diff = Current - self.GoldValue
		local Now = GetTime()

		self.GoldGained = self.GoldGained + Diff

		if (self.GoldTimer == 0) then
			self.GoldTimer = Now
		end

		if (self.Settings.DisplayMode == "TIME") then
			self:StartTimer()
		elseif (self.Settings.DisplayMode == "GPH") then
			if (self.GoldGained > 0) then
				self.Text:SetFormattedText(L["GPH: %s"], self:CopperToGold(floor((self.GoldGained / max(Now - self.GoldTimer, 1)) * 60 * 60)))
			end

			if (not self:GetScript("OnUpdate")) then
				self:SetScript("OnUpdate", self.OnUpdate)
			end
		elseif (self.Settings.DisplayMode == "GOLD") then
			self.Text:SetText(self:CopperToGold(self.GoldGained))
		end

		self:AddStat("gold", Diff)

		self:UpdateMoneyStat()
	end

	self.GoldValue = Current
end

Gathering:RegisterEvent("PLAYER_MONEY")
