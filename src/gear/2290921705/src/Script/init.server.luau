-- // Created by StarWars
local debris = game:GetService("Debris")

local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local leavesMotor = handle:FindFirstChild("Leaves")

local gear = GearService:BindGear(tool, "LaserGun")

gear.Class:SetDamage(15)
gear.Class:SetFireSound(30583931)
gear.Class:SetColors({Color3.fromRGB(160, 95, 53)})

local particleEmitter = script.ParticleEmitter

local function invokeClient(mode, value)
	local result = nil
	pcall(function()
		result = gear.ClientControls:InvokeClient(gear.Player, mode, value) 
	end)
	
	return result
end

gear:BindActivateFunction("fallStaffActiavte", function()
	if leavesMotor then
		leavesMotor.MaxVelocity = 0.1
		delay(1, function()
			if leavesMotor.MaxVelocity > 0 then
				leavesMotor.MaxVelocity = 0
			end
		end)
	end
end)

gear:BindEquippedFunction("fallStaffEquipped", function()
	if leavesMotor then
		leavesMotor.DesiredAngle = 10000000
	end
end)

gear:BindUnequippedFunction("fallStaffUnequipped", function()
	if leavesMotor then
		leavesMotor.DesiredAngle = 0
		leavesMotor.CurrentAngle = 0
		leavesMotor.MaxVelocity = 0
	end
end)

gear.Class.OnLaserFired:Connect(function(laserPart)
	local newPart = laserPart:Clone()
	newPart.Transparency = 1
	newPart.CFrame = laserPart.CFrame
	newPart.Parent = workspace
	
	local newParticle = particleEmitter:Clone()
	newParticle.Parent = newPart
	newParticle.Enabled = true
	wait(0.5)
	newParticle.Enabled = false
	
	debris:AddItem(newPart, 10)
end)