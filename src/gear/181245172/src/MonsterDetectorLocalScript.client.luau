-- Made by SolarCrane

local RS = game:GetService('ReplicatedStorage')
local PlayersService = game:GetService("Players")
local HttpService = game:GetService('HttpService')

local MonsterGearGui = require(RS:WaitForChild('MonsterGearGui'))


local Utility = require(RS:WaitForChild('Utility'))
local CreateLocalWelder = require(RS:WaitForChild('LocalEquipWeld'))
local MonsterData = require(RS:WaitForChild('MonsterData'))

local LocalPlayer = PlayersService.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild('PlayerGui')

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Equipped = false
local MonsterInfoGui = nil


CreateLocalWelder(Tool)

local function OnEquip()
	Equipped = true	
	if not MonsterInfoGui then
		MonsterInfoGui = MonsterGearGui()
		MonsterInfoGui:SetName("Monster Detector")
	end
	MonsterInfoGui:Show()
end

local function OnUnequip()
	Equipped = false
	MonsterInfoGui:Hide()
end

Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
