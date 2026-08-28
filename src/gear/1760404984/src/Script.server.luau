-- // Created by StarWars

local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local barrelAttachment = handle.BarrelAttachment

local gear = GearService:BindGear(tool)

local baseTeapotAmmo = Instance.new("Part")
baseTeapotAmmo.Size = Vector3.new(1.572, 0.788, 0.984)
baseTeapotAmmo.CanCollide = false
baseTeapotAmmo.Anchored = false
baseTeapotAmmo.Name = "Teapot"
local baseMesh = Instance.new("SpecialMesh")
baseMesh.MeshId = "rbxassetid://1743845693"
baseMesh.TextureId = "rbxassetid://1743846570"
baseMesh.Parent = baseTeapotAmmo
local bodyForce = Instance.new("BodyForce")
bodyForce.Force = Vector3.new(0, workspace.Gravity * 0.8 * baseTeapotAmmo:GetMass(), 0)
bodyForce.Parent = baseTeapotAmmo

local LAUNCH_SPEED = 150
local RELOAD_TIME = 2
local DAMAGE = 12
local GRIPS = {
	Holding = CFrame.new(0, -1.25, 0.75, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Fired = CFrame.new(0, -1.28185344, 0.924550891, 1, 0, 0, 0, 0.904214382, 0.427078843, 0, -0.427078843, 0.904214382)
}

local function fireLauncher(direction)
	local teapot = baseTeapotAmmo:Clone()
	teapot.Velocity = direction * LAUNCH_SPEED
	teapot.RotVelocity = Vector3.new(math.random(1,2), math.random(1,2), math.random(1,2))
	teapot.Touched:Connect(function(hit)
		if not hit:IsDescendantOf(gear.Character) and hit.Parent then
			local parent = hit.Parent
			if parent:IsA("Accessory") or parent:IsA("Tool") then
				parent = parent.Parent
			end
			local humanoid = parent:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(DAMAGE)
				teapot:Destroy()
			end
		end
	end)
	teapot.CFrame = barrelAttachment.WorldCFrame
	teapot.Parent = workspace
	tool.Grip = GRIPS.Fired
	wait(0.1)
	tool.Grip = GRIPS.Holding
end

local function invokeClient(player, mode, value)
	local result = nil
	pcall(function()
		result = gear.ClientControls:InvokeClient(player, mode, value)
	end)
	
	return result
end

gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

gear:BindActivateFunction("teapotLauncherActivate", function()
	local mouseData = invokeClient(gear.Player, "GetMouseData")
	if mouseData then
		local direction = (mouseData.Position - gear.RootPart.CFrame.p).Unit
		fireLauncher(direction)
		wait(RELOAD_TIME)
	end 
end)