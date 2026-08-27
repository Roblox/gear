--Send them away by the bats!

local Self = script

local world = workspace

local Instant,Type,Vec3,cframe,Angles = Instance.new,type,Vector3.new,CFrame.new,CFrame.Angles

local random,huge,rad,Wait = math.random,math.huge,math.rad,wait

local Pcall,Wrap = pcall,coroutine.wrap

local Target,Creator = Self:FindFirstChild("Target"),Self:FindFirstChild("Creator")

if not Target or not Creator then Self:Destroy() end
Creator = Creator.Value
Target = Target.Value

local Humanoid = Target:FindFirstChildOfClass("Humanoid")

function Create(ty)
	return function(data)
		local obj = Instant(ty)
		for k, v in pairs(data) do
			if Type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService"))
}

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instant("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

local Yell,BatSwarm = Self:WaitForChild("Yell"), Self:WaitForChild("BatSwarm")
Target.Archivable = true

local CharacterClone = Target:Clone()

CharacterClone.PrimaryPart = CharacterClone.PrimaryPart or CharacterClone:FindFirstChild("HumanoidRootPart") or CharacterClone:FindFirstChild("Torso")

Yell.Parent = CharacterClone.PrimaryPart
BatSwarm.Parent = CharacterClone.PrimaryPart


Create("ForceField"){
	Visible = false,
	Parent = CharacterClone
}

local Descendants = Target:GetDescendants()

UntagHumanoid(Humanoid)
TagHumanoid(Humanoid,Creator)

for i=1,#Descendants do
	if Descendants[i] and Descendants[i]:IsA("BasePart") then
		Descendants[i]:Destroy()
	end
end

local CloneDescendants = CharacterClone:GetDescendants()


for i=1,#CloneDescendants do
	if CloneDescendants[i] then
		if CloneDescendants[i]:IsA("BaseScript") then
			CloneDescendants[i]:Destroy()
		elseif CloneDescendants[i]:IsA("BasePart") then
			if CloneDescendants[i]:CanSetNetworkOwnership() then
				CloneDescendants[i]:SetNetworkOwner(nil)
			end
		end
	end	
end

CharacterClone.Parent = world
local meshes = {63693995, 63694839, 63694853}
local Offset = {Vec3(0,0,0),Vec3(0, 0, -0.31),Vec3(0, 0, 0.2)}

local bat = Create("Part"){
	Size = Vec3(0.6, 0.6, 0.6),
	CanCollide = false,
	Anchored = false,
	CastShadow = true,
	Locked = true,
	Transparency = 0.0,
	Name = "Bat"
}

local CharVelo
Wrap(function()
	Pcall(function()
		local Angular = Create("BodyAngularVelocity"){
			MaxTorque = Vec3(1,1,1)*huge,
			--D = 100,
			--P = 10^5,
			AngularVelocity = Vec3(0,0,0),
			Parent = CharacterClone.PrimaryPart
		}
		CharVelo = Create("BodyVelocity"){
			MaxForce = Vec3(1,1,1)*huge,
			Velocity = Vec3(random(-1,1),1,random(-1,1)) * 20,
			Parent = CharacterClone.PrimaryPart
		}
		while Wait(.5) do
			if Angular then
				Angular.AngularVelocity = Vec3(random(-10,10),random(-10,10),random(-10,10))
			end
		end
	end)
end)()

for i=1,20,1 do
	local batclone = bat:Clone()
	batclone.CFrame = CharacterClone.PrimaryPart.CFrame * Angles(rad(random(1,360)),rad(random(1,360)),rad(random(1,360)))
	batclone.Parent = CharacterClone
	if batclone:CanSetNetworkOwnership() then
		batclone:SetNetworkOwner(nil)
	end
	local batMesh = Create("SpecialMesh"){
		MeshId = "http://www.roblox.com/asset/?id=63693995", -- front, 63694839  --back, 63694853  
		TextureId = "http://www.roblox.com/asset/?id=63694777",
		Scale = Vec3(1, 1, 1) * 2,
		Parent = batclone
	}
	local Velo = Create("BodyVelocity"){
		MaxForce = Vec3(1,1,1)*huge,
		Velocity = Vec3(0,0,0),
		Parent = batclone
	}
	Wrap(function()
		repeat
			for i=1,#meshes do
				if batMesh and batMesh.Parent then
					batMesh.MeshId = "http://www.roblox.com/asset/?id="..meshes[i]
					batMesh.Offset = Offset[i]/2
					Wait(1/15)
				end
			end
			Services.RunService.Heartbeat:Wait()
		until not batMesh or not batMesh.Parent
	end)()
	Wrap(function()
		repeat
			if batclone and CharacterClone.PrimaryPart and CharVelo then
				Velo.Velocity = cframe(batclone.Position,(CharacterClone.PrimaryPart.Position + CharVelo.Velocity.Unit * CharVelo.Velocity.Magnitude) --[[+ Vec3(random(-5,5),random(-5,5),random(-5,5))]]).LookVector * CharVelo.Velocity.Magnitude + Vec3(random(-20,20),random(-20,20),random(-20,20))
				batclone.RotVelocity = Vec3(random(-5,5),random(-5,5),random(-5,5))
			end
			Wait(random(.2,.5))
		until not batclone or not CharacterClone.PrimaryPart
	end)()
end




BatSwarm:Play()
Yell:Play()

Wait(6)

CharacterClone:Destroy()
Self:Destroy()