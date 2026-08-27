local Target = script:WaitForChild("Target").Value

local Sounds = {
	IceCrack = script:WaitForChild("IceCrack"),
	Shatter = script:WaitForChild("Shatter")
}

local Torso = Target:FindFirstChild("Torso") or Target:FindFirstChild("UpperTorso")

if not Target then script:Destroy() end

local Humanoid = Target:FindFirstChildOfClass("Humanoid")
Humanoid:UnequipTools()

local Stop = false
coroutine.wrap(function()
	repeat
		Humanoid.JumpPower = 0
		Humanoid.WalkSpeed = 0
		game:GetService("RunService").Heartbeat:Wait()
	until Stop
end)()

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
}

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

--[[if Services.Players:GetPlayerFromCharacter(Target) then
	local Disable = script:WaitForChild("DisableBackpack")
	Disable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Disable.Disabled = false
	Services.Debris:AddItem(Disable,1)
	Services.Players:GetPlayerFromCharacter(Target).CharacterRemoving:Connect(function(Char)--keeps people from a hidden inventory
		local Enable = script:WaitForChild("EnableBackpack")
		Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
		Enable.Disabled = false
		Services.Debris:AddItem(Enable,1)
	end)
end]]

local ice = Create("Part"){
	Shape = "Block", 
	Size = Vector3.new(4.2,4,6.3)*0, 
	CanCollide = true,
	Anchored = true,
	Locked = true,
	Name = "Ice Block",
	CFrame = Torso.CFrame*CFrame.Angles(math.rad(-90),0,0), 
	Transparency = 0.4,
	Parent = Target,
}

local iceBlockMesh = Create("SpecialMesh"){
	MeshId = "http://www.roblox.com/asset/?id=66876751",
	TextureId = "http://www.roblox.com/asset/?id=66876766",
	Scale = Vector3.new(1.0, 1.0, 1.0)*0,
	Parent = ice,
}

Sounds.IceCrack.Parent = ice
Sounds.IceCrack:Play()

local Puff = script:WaitForChild("Puff")
Puff.Parent = ice
Puff.Enabled = true

local FrozenParts = {}

for _,parts in pairs(Target:GetChildren()) do
	if parts:IsA("BasePart") and Humanoid:GetLimb(parts) then
		parts.Anchored = true
		FrozenParts[#FrozenParts+1] = parts
	end
end

for i=1,60,1 do
	ice.Size = (Vector3.new(4.2,4,6.3)*.1):lerp(Vector3.new(4.2,4,6.3),i/60)
	iceBlockMesh.Scale = (Vector3.new(1.0, 1.0, 1.0)*.1):lerp(Vector3.new(1.0, 1.0, 1.0),i/60)
	ice.CFrame = Torso.CFrame*CFrame.Angles(math.rad(-90),0,0)
	Services.RunService.Heartbeat:Wait()
end

local Duration,Start = 5.5,tick()

repeat
	Services.RunService.Heartbeat:Wait()
until (tick()-Start) >= Duration or Humanoid.Health <= 0

Sounds.Shatter.Parent = Torso
Sounds.Shatter:Play()
Services.Debris:AddItem(Sounds.Shatter,Sounds.Shatter.TimeLength+1)

Stop = true
ice:Destroy()
Humanoid.JumpPower = 50
Humanoid.WalkSpeed = 16

local Seed = Random.new(tick())

for _, parts in pairs(FrozenParts) do
	if parts then
		parts.Anchored = false
		local DebrisIce = Create("Part"){
			Size = Vector3.new(Seed:NextNumber(1,2),Seed:NextNumber(1,2),Seed:NextNumber(1,2)),
			Locked = true,
			Anchored = false,
			Name = "Broken Ice",
			CFrame = parts.CFrame,
			Transparency = 0.3,
			Material = Enum.Material.Glass,
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Color = (Seed:NextInteger(1,3) == 1 and Color3.fromRGB(170,255,255)) or Color3.fromRGB(0,170,255),
			Parent = workspace
		}
		Services.Debris:AddItem(DebrisIce,Seed:NextNumber(3,5))
	end
end

local FrostSparkles = script:WaitForChild("FrostSparkles")
FrostSparkles.Parent = Torso
FrostSparkles:Emit(FrostSparkles.Rate)
Services.Debris:AddItem(FrostSparkles,FrostSparkles.Lifetime.Max)

--[[if Services.Players:GetPlayerFromCharacter(Target) then	
	local Enable = script:WaitForChild("EnableBackpack")
	Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Enable.Disabled = false
	Services.Debris:AddItem(Enable,1)
end]]

wait(2) -- Grace period (Your're Welcome EuroC2)

script:Destroy()