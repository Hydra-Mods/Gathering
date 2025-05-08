local Name, AddOn = ...

local Gathering = CreateFrame("Frame", "Gathering_Header", UIParent, "BackdropTemplate")
Gathering:SetPoint("TOP", UIParent, 0, -100)
Gathering:EnableMouse(true)
Gathering:SetMovable(true)
Gathering:SetUserPlaced(true)
Gathering.SentGroup = false
Gathering.SentInstance = false
Gathering.LastYell = 0
Gathering.Int = 1

Gathering.BlankTexture = "Interface\\AddOns\\Gathering\\Assets\\HydraUIBlank.tga"
Gathering.BarTexture = "Interface\\AddOns\\Gathering\\Assets\\HydraUI4.tga"
Gathering.GameVersion = select(4, GetBuildInfo())
Gathering.SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
Gathering.Textures = Gathering.SharedMedia:HashTable("statusbar")
Gathering.Fonts = Gathering.SharedMedia:HashTable("font")
Gathering.Me = UnitName("player")

AddOn.L = {}
AddOn.Locale = GetLocale()
AddOn.Gathering = Gathering

function Gathering:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end