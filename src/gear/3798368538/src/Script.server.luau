-- // Created by StarWars
local GearService = require(1075123174)
local Gear = GearService:BindGear(script.Parent, "Sword")
Gear.Class:DisableLunge()
Gear:SetupLocalScript("MouseIcon")

local IDLE_MESH = "rbxassetid://3758121429"
local ATTACK_MESH = "rbxassetid://3758113942"
local GRIP_UP = CFrame.new(0, -2.36146448e-07, 1.95110512, 1, 0, 0, 0, -1.62920671e-07, -1, 0, 1, -1.62920671e-07)
local GRIP_OUT = CFrame.new(0, 0.0618524551, 1.59979463, 1, 0, 0, 0, 1, -1.74845553e-07, 0, 1.74845553e-07, 1)

local handle = script.Parent.Handle

script.Parent.Grip = GRIP_UP
handle.Mesh.MeshId = IDLE_MESH

Gear.Class:SetGripUp(GRIP_UP)
Gear.Class:SetGripOut(GRIP_OUT)

Gear:BindActivateFunction("mace_attack", function()
	handle.Mesh.MeshId = ATTACK_MESH
	script.Parent.Grip = GRIP_OUT
	
	delay(0.475, function()
		script.Parent.Grip = GRIP_UP
		handle.Mesh.MeshId = IDLE_MESH
	end)
end)