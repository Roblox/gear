--Tela-Thorn script

local Character = script.Parent
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso") 

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Player = Players:GetPlayerFromCharacter(Character)

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

local Creator = script:WaitForChild("Creator")

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
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "54653968"),
	TextureId = (BaseUrl .. "54654008"),
	Scale = Vector3.new(1, 1, 0.8),
	VertexColor = Vector3.new(1, 0, 0),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseThornPart,
}

Fire = script:WaitForChild("Fire")

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

Debris:AddItem(Fire, 3)
Fire.Parent = Torso
Fire.Enabled = true
Torso.Anchored = true
ThornPart = BaseThornPart:Clone()
ThornPart.CFrame = Torso.CFrame
Debris:AddItem(ThornPart, 3.75)
ThornPart.Parent = game:GetService("Workspace")

for i, v in pairs(Torso:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Body")) then
		v:Destroy()
	end
end

StartTick = tick()
while (tick() - StartTick) < 3.5 do 
	if Player and Creator.Value and Creator.Value:IsA("Player") and not IsTeamMate(Player, Creator.Value) then
		UntagHumanoid(Humanoid)
		TagHumanoid(Humanoid, Creator.Value)
	end
	Humanoid:TakeDamage(4.5)
	wait(0.5) 
end 

Torso.Anchored = false 

wait(2)

script:Destroy()