--Removes any flying gear from your hands

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


local Character = script.Parent
local Fire = script:WaitForChild("Fire")
local Creator,ToolHandle = script:WaitForChild("Creator"),script:WaitForChild("ToolHandle").Value
local Torso,Humanoid = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso"),Character:FindFirstChildOfClass("Humanoid")

local BaseUrl = "http://www.roblox.com/asset/?id="

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function IsCharacterFlying(char) -- helps check if person is flying
	local FlightClasses = {"BodyPosition","BodyThrust","BodyVelocity","BodyGyro"}
	local Status = false
	
	if char and char:FindFirstChildOfClass("Tool") and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(char)) then
		for _,obj in pairs(char:GetDescendants()) do
			if obj:IsA("BasePart") then
				for _,v in pairs(FlightClasses) do
					if obj:FindFirstChildOfClass(v) then
						obj:FindFirstChildOfClass(v):Destroy()
						Status = true
					end
				end
			end
		end
	end

	
	--Searches locally
	if Services.Players:GetPlayerFromCharacter(char) and not IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(char)) and not Status then -- This is a player
		script:WaitForChild("WingDetectionLocal").Disabled = false
		Status = script:WaitForChild("Remote"):InvokeClient(Services.Players:GetPlayerFromCharacter(char))
	end
	
	return Status
end

local Flying = false -- Go through a series of checks to make sure if this user is flying

Flying = IsCharacterFlying(Character)
	
	local BasePart = Create("Part"){
		Material = Enum.Material.Plastic,
		Shape = Enum.PartType.Block,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		FormFactor = Enum.FormFactor.Custom,
		Size = Vector3.new(0.2, 0.2, 0.2),
		CanCollide = true,
		Locked = true,
	}

	BaseThornPart = BasePart:Clone()
	BaseThornPart.Name = "Effect"
	BaseThornPart.Size = Vector3.new(2, 4, 2)
	BaseThornPart.Anchored = true
	BaseThornPart.CanCollide = false
	Fire.Parent = BaseThornPart
	Fire.Enabled = false
	Services.Debris:AddItem(Fire,4)
	Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "54653968"),
		TextureId = (BaseUrl .. "54654008"),
		Scale = Vector3.new(1, 1, 0.8),
		VertexColor = Vector3.new(1, 0, 0),
		Offset = Vector3.new(0, 0, 0),
		Parent = BaseThornPart,
	}
	
if Flying then --We gottem boys
	--warn("De-winging /" .. Character.Name)
	
	UntagHumanoid(Humanoid)
	TagHumanoid(Humanoid,Creator.Value)
	Humanoid:TakeDamage(75)
	
	local GhostTela = ToolHandle:Clone()
	local GhostTelaMesh = GhostTela:FindFirstChildOfClass("SpecialMesh")
	
	for _,stuff in pairs(GhostTela:GetChildren()) do
		if not stuff:IsA("SpecialMesh") and not stuff:IsA("Attachment") then
			stuff:Destroy()
		end
	end
	local Velo = Create("BodyVelocity"){
		Velocity = (Torso.CFrame.p-GhostTela.CFrame.p).Unit * 200,
		MaxForce = Vector3.new(1,1,1)*math.huge,
		Parent = GhostTela
	}
	GhostTela.Transparency = .5
	GhostTela.Velocity = Vector3.new(0,0,0)
	GhostTela.RotVelocity = Vector3.new(0,0,0)
	GhostTela.Color = Color3.new(1,1,1)
	GhostTelaMesh.VertexColor = Vector3.new(1,0,0)*10^7
	GhostTelaMesh.TextureId = BaseUrl .. "883311537"
	GhostTela.Size = GhostTela.Size * 3
	GhostTelaMesh.Scale = GhostTelaMesh.Scale * 3
	GhostTela.CFrame = CFrame.new(GhostTela.CFrame.p,Torso.CFrame.p) * CFrame.Angles(math.rad(-90),0,0)
	GhostTela.Anchored = false
	GhostTela.Parent = workspace
	GhostTela:SetNetworkOwner(nil)
	GhostTela.Touched:Connect(function(hit)
		if hit.Parent == Character then
			GhostTela:Destroy()
		end
	end)
	Services.Debris:AddItem(GhostTela,4)
	
	Torso.Anchored = true
	local Tool = Character:FindFirstChildOfClass("Tool")
	if Tool then
		Humanoid:UnequipTools()
		Tool:Destroy()
	end
	ThornPart = BaseThornPart:Clone()
	ThornPart.CFrame = Torso.CFrame
	Services.Debris:AddItem(ThornPart, 3.75)
	ThornPart.Parent = workspace
	
	wait(3)
	Torso.Anchored = false
end
	
script:Destroy()