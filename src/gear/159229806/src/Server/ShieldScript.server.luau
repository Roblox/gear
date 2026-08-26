local Character = script.Parent

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris"))
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

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

local BaseUrl = "http://www.roblox.com/asset/?id="

local Properties = {
	CurrentRadius = 20
}

local Center = (Character:FindFirstChild("HumanoidRootPart"))

if not Center then script:Destroy() end

local Shield = Create("Part"){
	Transparency = 0.5,
	Shape = Enum.PartType.Ball,
	Material = Enum.Material.Neon,
	Locked = true,
	CanCollide = false,
	Anchored = false,
	Size = Vector3.new(1,1,1)*1,
	CFrame = Center.CFrame,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Color = Color3.fromRGB(0,128,0),
}

local ShieldMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.Sphere,
	Offset = Vector3.new(0,0,0),
	Scale = Vector3.new(0,0,0),
	VertexColor = Vector3.new(0,1,0)*10^5,
	--TextureId = BaseUrl.."883311537",
	Parent = Shield
}

local WeldConstraint = Create("WeldConstraint"){
	Part0 = Center,
	Part1 = Shield,
	Parent = Shield
}
Shield.CFrame = Center.CFrame
Shield.Parent = Character


delay(2,function()
	Shield:Destroy()
	script:Destroy()
end)

spawn(function()
	repeat
	spawn(function()
		local NegativeRegion = (Center.Position - Vector3.new(ShieldMesh.Scale.X, ShieldMesh.Scale.Y, ShieldMesh.Scale.Z))
		local PositiveRegion = (Center.Position + Vector3.new(ShieldMesh.Scale.X, ShieldMesh.Scale.Y, ShieldMesh.Scale.Z))
		local Region = Region3.new(NegativeRegion, PositiveRegion)
		local Parts = workspace:FindPartsInRegion3WithIgnoreList(Region,{Character,Shield},math.huge)
		for _,hit in pairs(Parts) do
			if hit and hit.Parent and not hit.Anchored and (hit.CFrame.p-Shield.CFrame.p).Magnitude <= Properties.CurrentRadius then
				local Knockback = Create("BodyVelocity"){
					MaxForce = Vector3.new(1,1,1)*math.huge,
					Velocity = ((hit.CFrame.p-Shield.CFrame.p).Unit*100)+Vector3.new(0,50,0),
					Name = "Knockback",
					Parent = hit
				}
				Services.Debris:AddItem(Knockback,.1)
			end
		end
	end)



	Services.RunService.Stepped:Wait()
	--Services.RunService.Heartbeat:Wait()
	until not Shield or not Shield.Parent
end)

local CharacterHumanoid = Character:FindFirstChildOfClass("Humanoid")
--[[spawn(function()
	repeat
		CharacterHumanoid.Health = CharacterHumanoid.Health + .5
		Services.RunService.Heartbeat:Wait()
	until not Shield or not Shield.Parent or not CharacterHumanoid or not CharacterHumanoid.Parent
end)]]

for i=1,20,1 do
	if Shield and Shield.Parent and Center and Center.Parent then
		ShieldMesh.Scale = Vector3.new(0,0,0):Lerp(Vector3.new(1,1,1)*Properties.CurrentRadius,i/30)
		Services.RunService.Heartbeat:Wait()	
	end
end


