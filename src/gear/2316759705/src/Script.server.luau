-- // Created by StarWars
local GearService = require(1075123174)

local tool = script.Parent
local handle = tool.Handle
local barrelAttachment = handle.BarrelAttachment

local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local baseAmmo1 = Instance.new("Part")
baseAmmo1.Size = Vector3.new(0.688, 0.248, 0.458)
baseAmmo1.CanCollide = false
baseAmmo1.Anchored = false
baseAmmo1.Name = "Microbe"

local baseMesh1 = Instance.new("SpecialMesh")
baseMesh1.MeshId = "rbxassetid://2310151477"
baseMesh1.TextureId = "rbxassetid://2310153180"
baseMesh1.Parent = baseAmmo1

local bodyForce1 = Instance.new("BodyForce")
bodyForce1.Force = Vector3.new(0, workspace.Gravity * 0.8 * baseAmmo1:GetMass(), 0)
bodyForce1.Parent = baseAmmo1

local baseAmmo2 = Instance.new("Part")
baseAmmo2.Size = Vector3.new(0.624, 0.187, 0.657)
baseAmmo2.CanCollide = false
baseAmmo2.Anchored = false
baseAmmo2.Name = "Microbe"

local baseMesh2 = Instance.new("SpecialMesh")
baseMesh2.MeshId = "rbxassetid://2310151996"
baseMesh2.TextureId = "rbxassetid://2310153180"
baseMesh2.Parent = baseAmmo2

local bodyForce2 = Instance.new("BodyForce")
bodyForce2.Force = Vector3.new(0, workspace.Gravity * 0.8 * baseAmmo2:GetMass(), 0)
bodyForce2.Parent = baseAmmo2

local baseAmmo3 = Instance.new("Part")
baseAmmo3.Size = Vector3.new(0.332, 0.152, 0.693)
baseAmmo3.CanCollide = false
baseAmmo3.Anchored = false
baseAmmo3.Name = "Microbe"

local baseMesh3 = Instance.new("SpecialMesh")
baseMesh3.MeshId = "rbxassetid://2310152248"
baseMesh3.TextureId = "rbxassetid://2310153180"
baseMesh3.Parent = baseAmmo3

local bodyForce3 = Instance.new("BodyForce")
bodyForce3.Force = Vector3.new(0, workspace.Gravity * 0.8 * baseAmmo3:GetMass(), 0)
bodyForce3.Parent = baseAmmo3

local ammos = {baseAmmo1, baseAmmo2, baseAmmo3}
local rand = Random.new()

local LAUNCH_SPEED = 150
local RELOAD_TIME = 2
local DAMAGE = 12
local GRIPS = {
	Holding = CFrame.new(0, -0.426, -1.412),
	Fired = CFrame.new(0, -0.426, -1.412, 1, 0, 0, 0, 0.904214382, 0.427078843, 0, -0.427078843, 0.904214382)
}

function InvokeClient(mode, value)
	if gear.Player and mode then
		local result
		
		pcall(function()
			result = gear.ClientControls:InvokeClient(gear.Player, mode, value)
		end)
		
		return result
	end
end

function FireLauncher(direction)
	local microbe = ammos[rand:NextInteger(1, #ammos)]:Clone()
	microbe.Velocity = direction * LAUNCH_SPEED
	microbe.RotVelocity = Vector3.new(math.random(1,2), math.random(1,2), math.random(1,2))
	microbe.Touched:Connect(function(hit)
		if not hit:IsDescendantOf(gear.Character) and hit.Parent then
			local parent = hit.Parent
			if parent:IsA("Accessory") or parent:IsA("Tool") then
				parent = parent.Parent
			end
			local humanoid = parent:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(DAMAGE)
				microbe:Destroy()
			end
		end
	end)
	microbe.CFrame = barrelAttachment.WorldCFrame
	microbe.Parent = workspace
	tool.Grip = GRIPS.Fired
	wait(0.1)
	tool.Grip = GRIPS.Holding
end

tool.Activated:Connect(function()
	if gear:IsPlayerAlive() and tool.Enabled then
		tool.Enabled = false
		
		local mouseData = InvokeClient("GetMouseData")
		if mouseData and mouseData.Position then
			local direction = (mouseData.Position - gear.RootPart.CFrame.p).Unit
			FireLauncher(direction)
		end
		
		wait(RELOAD_TIME)
		tool.Enabled = true
	end
end)