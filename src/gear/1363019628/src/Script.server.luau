-- // Created by StarWars
local Players = game:GetService("Players")

local GearService = require(1075123174)
GearService:BindGear(script.Parent, "Sword")

local Tool = script.Parent
local Player = nil
local Character = nil
local Humanoid = nil

local SPEED_BUFF_MODIFIER = 1.5

local ToolEquipped = false

function CheckIfAlive()
	return Player and Character and Humanoid and Humanoid.RootPart and Humanoid.Health > 0
end

Tool.Equipped:Connect(function()
	if ToolEquipped then return end	
	
	ToolEquipped = true
	
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if CheckIfAlive() then
		CacheWalkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = Humanoid.WalkSpeed * SPEED_BUFF_MODIFIER
	end
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end 
	
	if CheckIfAlive() and CacheWalkSpeed then
		Humanoid.WalkSpeed = CacheWalkSpeed
	end	
	
	ToolEquipped = false
	Character = nil
	Player = nil
	Humanoid = nil
end)