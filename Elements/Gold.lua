local Name, AddOn = ...
local Gathering = AddOn.Gathering
local L = AddOn.L

function Gathering:PLAYER_MONEY()
    if ((self.Settings.IgnoreMailMoney and InboxFrame:IsVisible()) or (GuildBankFrame and GuildBankFrame:IsVisible())) then -- Ignore useless info
        return
    end

    local Current = GetMoney()

    if (self.GoldValue == Current) then
        return
    end

    local DisplayMode = self.Settings.DisplayMode
    local Now = GetTime()
    local Diff = Current - self.GoldValue

    self.GoldGained = Current - self.StartingGold

    if (self.GoldTimer == 0) then
        self.GoldTimer = GetTime()
    end

    if (DisplayMode == "TIME") then
        self:StartTimer()
    elseif (DisplayMode == "GPH") then
        if (self.GoldGained ~= 0) then
            self.Text:SetFormattedText(L["GPH: %s"], self:CopperToGold(floor((self.GoldGained / max(Now - self.GoldTimer, 1)) * 60 * 60)))
        end

        if (not self:GetScript("OnUpdate")) then
            self:SetScript("OnUpdate", self.OnUpdate)
        end
    elseif (DisplayMode == "GOLD") then
        self.Text:SetText(self:CopperToGold(self.GoldGained))
    end

	if (Diff > 0) then
		self:AddStat("gold", Diff)
		self:UpdateMoneyStat()
	end

    self.GoldValue = Current
end

Gathering:RegisterEvent("PLAYER_MONEY")