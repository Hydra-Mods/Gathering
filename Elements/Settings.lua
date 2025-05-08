local Name, AddOn = ...
local Gathering = AddOn.Gathering

Gathering.DefaultSettings = {
	-- Tracking
	["track-ore"] = true,
	["track-herbs"] = true,
	["track-leather"] = true,
	["track-cooking"] = true,
	["track-cloth"] = true,
	["track-jewelcrafting"] = true,
	["track-enchanting"] = true,
	["track-reagents"] = true,
	["track-consumable"] = true,
	["track-holiday"] = true,
	["track-quest"] = false,
	["track-xp"] = true,

	-- Functionality
	IgnoreBOP = false, -- Ignore bind on pickup gear. IE: ignore BoP loot on a raid run, but show BoE's for the auction house
	HideIdle = false, -- Hide the tracker frame while not running
	IgnoreMailItems = true, -- Ignore items that arrived through mail
	IgnoreMailMoney = true, -- Ignore money that arrived through mail
	ShowTooltipHelp = true, -- Display helpful information in the tooltip (Left click to toggle, right click to reset)
	DisplayMode = "TIME", -- TOTAL; Display total gathered, GPH; display gold per hour, GOLD; display gold collected, TIME; display timer

	-- Styling
	WindowFont = Gathering.SharedMedia.DefaultMedia.font, -- Set the font
	WindowHeight = 24,
	WindowWidth = 130,

	-- Bag Slots
	EnableSlotBar = true,
	SlotBarTooltip = true,
	SlotBarHeight = 6,
	-- Threshold options
}

Gathering.TrackedItemTypes = {
	[Enum.ItemClass.Consumable] = {},
	[Enum.ItemClass.Weapon] = {},
	[Enum.ItemClass.Armor] = {},
	[Enum.ItemClass.Tradegoods] = {},
	[Enum.ItemClass.Miscellaneous] = {},
	[Enum.ItemClass.Questitem] = {},
}

function Gathering:UpdateWeaponTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Axe1H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Axe2H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Bows] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Guns] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Mace1H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Mace2H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Polearm] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Sword1H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Sword2H] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Warglaive] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Staff] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Bearclaw] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Catclaw] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Unarmed] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Generic] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Dagger] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Thrown] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Crossbow] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Wand] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Weapon][Enum.ItemWeaponSubclass.Fishingpole] = value
end

function Gathering:UpdateArmorTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Generic] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Cloth] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Leather] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Mail] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Plate] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Cosmetic] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Shield] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Libram] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Idol] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Totem] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Sigil] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Armor][Enum.ItemArmorSubclass.Relic] = value
end

function Gathering:UpdateJewelcraftingTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][4] = value
end

function Gathering:UpdateClothTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][5] = value
end

function Gathering:UpdateLeatherTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][6] = value
end

function Gathering:UpdateOreTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][7] = value
end

function Gathering:UpdateCookingTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][0] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][8] = value
end

function Gathering:UpdateHerbTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][9] = value
end

function Gathering:UpdateEnchantingTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][12] = value
end

function Gathering:UpdateHolidayTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Holiday] = value
end

function Gathering:UpdateMountTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Mount] = value
end

function Gathering:UpdateConsumableTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][1] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][2] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][3] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][4] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][5] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][6] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Consumable][7] = value
end

function Gathering:UpdateReagentTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Reagent] = value
	Gathering.TrackedItemTypes[Enum.ItemClass.Tradegoods][10] = value
end

function Gathering:UpdateOtherTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Miscellaneous][Enum.ItemMiscellaneousSubclass.Other] = value
end

function Gathering:UpdateQuestTracking(value)
	Gathering.TrackedItemTypes[Enum.ItemClass.Questitem][0] = value
end