local Self = script

local world = workspace

local Target = Self:WaitForChild("Target").Value

local Sounds = {
	IceCrack = Self:WaitForChild("IceCrack"),
	Shatter = Self:WaitForChild("Shatter")
}

local StoneShirt,StonePants,StoneColors = Self:WaitForChild("StoneShirt"),Self:WaitForChild("StonePants"),Self:WaitForChild("StoneColors")

local Torso = Target:FindFirstChild("Torso") or Target:FindFirstChild("UpperTorso")

if not Target then Self:Destroy() end

local Vec3,fromRGB,Instant = Vector3.new,Color3.fromRGB,Instance.new

local Type,Pairs = type,pairs

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
		local obj = Instant(ty)
		for k, v in Pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

Sounds.IceCrack.Parent = Torso
Sounds.IceCrack:Play()

if Services.Players:GetPlayerFromCharacter(Target) then
	local Disable = Self:WaitForChild("DisableBackpack")
	Disable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Disable.Disabled = false
	Services.Debris:AddItem(Disable,1)
	Services.Players:GetPlayerFromCharacter(Target).CharacterRemoving:Connect(function(Char)--keeps people from a hidden inventory
		local Enable = Self:WaitForChild("EnableBackpack")
		Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
		Enable.Disabled = false
		Services.Debris:AddItem(Enable,1)
	end)
end

local FrozenParts = {}

local AffectedMeshes = {}

for _,parts in Pairs(Target:GetDescendants()) do
	if parts:IsA("BasePart") and parts.Parent == Humanoid.Parent and Humanoid:GetLimb(parts) then
		parts.Anchored = true
		FrozenParts[#FrozenParts+1] = parts
		parts.Material = Enum.Material.Concrete
	elseif parts:IsA("SpecialMesh") then
		AffectedMeshes[#AffectedMeshes+1] = {Mesh = parts,TextureId = parts.TextureId}
		parts.TextureId = ""
	end
end

local CurrentShirt,CurrentPants,CurrentColors
CurrentShirt = Target:FindFirstChildOfClass("Shirt")
CurrentPants = Target:FindFirstChildOfClass("Pants")
CurrentColors = Target:FindFirstChildOfClass("BodyColors")

if CurrentShirt then
	CurrentShirt.Parent = nil
end

if CurrentPants then
	CurrentPants.Parent = nil
end

if CurrentColors then
	CurrentColors.Parent = nil
end

StoneShirt.Parent = Target
StonePants.Parent = Target
StoneColors.Parent = Target

local Duration,Current_Time = 5.5,0

repeat
	Current_Time = Current_Time + Services.RunService.Heartbeat:Wait()
until Current_Time >= Duration or Humanoid.Health <= 0

Sounds.Shatter.Parent = Torso
Sounds.Shatter:Play()
Services.Debris:AddItem(Sounds.Shatter,Sounds.Shatter.TimeLength+1)

Stop = true
Humanoid.JumpPower = 50
Humanoid.WalkSpeed = 16

local Seed = Random.new(tick())

for _,mesh in Pairs(AffectedMeshes) do
	if mesh.Mesh then
		mesh.Mesh.TextureId = mesh.TextureId
	end
end

for _, parts in Pairs(FrozenParts) do
	if parts then
		parts.Anchored = false
		parts.Material = Enum.Material.Plastic
		local DebrisIce = Create("Part"){
			Size = Vec3(Seed:NextNumber(1,2),Seed:NextNumber(1,2),Seed:NextNumber(1,2)),
			Locked = true,
			Anchored = false,
			Massless = true,
			Name = "Broken Stone",
			CFrame = parts.CFrame,
			Transparency = 0,
			Material = Enum.Material.Concrete,
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Color = (Seed:NextInteger(1,3) == 1 and fromRGB(99, 95, 98)) or fromRGB(163, 162, 165),
			Parent = world
		}
		Services.Debris:AddItem(DebrisIce,Seed:NextNumber(3,5))
	end
end

if StonePants then
	StonePants:Destroy()
end

if StoneShirt then
	StoneShirt:Destroy()
end

if StoneColors then
	StoneColors:Destroy()
end

if CurrentPants then
	CurrentPants.Parent = Target
end

if CurrentShirt then
	CurrentShirt.Parent = Target
end

if CurrentColors then
	CurrentColors.Parent = Target
end

if Services.Players:GetPlayerFromCharacter(Target) then	
	local Enable = Self:WaitForChild("EnableBackpack")
	Enable.Parent = Services.Players:GetPlayerFromCharacter(Target):WaitForChild("Backpack")
	Enable.Disabled = false
	Services.Debris:AddItem(Enable,1)
end

wait(2) -- Grace period (Your're Welcome EuroC2)

Self:Destroy()