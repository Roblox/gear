--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animations = {
	Play = {Animation = Tool:WaitForChild("Play"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 2},
}

Sounds = {
	TubaSound = Handle:WaitForChild("TubaSound")
}

Gravity = 196.20

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ShockwavePart = Instance.new("Part")
ShockwavePart.Name = "ShockWave"
ShockwavePart.Material = Enum.Material.Plastic
ShockwavePart.Shape = Enum.PartType.Block
ShockwavePart.FormFactor = Enum.FormFactor.Custom
ShockwavePart.TopSurface = Enum.SurfaceType.Smooth
ShockwavePart.BottomSurface = Enum.SurfaceType.Smooth
ShockwavePart.Size = Vector3.new(8, 0.2, 8)
ShockwavePart.Transparency = 1
ShockwavePart.CanCollide = false
for i, v in pairs({"Top", "Bottom"}) do
	Decal = Instance.new("Decal")
	Decal.Specular = 20
	Decal.Face = Enum.NormalId[v]
	Decal.Texture = "http://www.roblox.com/asset/?version=1&id=1280730"
	Decal.Parent = ShockwavePart
end

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and ToolEquipped and CheckIfAlive() then
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
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

function Shoot(Pos)
	
	local SpawnPos = Head.Position + Pos.unit * 5
	
	local Shockwave = ShockwavePart:Clone()
	Shockwave.CFrame = CFrame.new(SpawnPos, (SpawnPos + Pos)) * CFrame.Angles((math.pi / 2), 0, 0)
	Shockwave.Velocity = (Pos * 25)
	
	Debris:AddItem(Shockwave, 3)
	
	Shockwave.Parent = game:GetService("Workspace")
	
	Shockwave.CanCollide = true

	local ShockwaveFloat = Instance.new("BodyForce")
	ShockwaveFloat.force = Vector3.new(0.0, (Shockwave:GetMass()) * Gravity, 0)
	ShockwaveFloat.Parent = Shockwave
	
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.P = 10000
	BodyGyro.cframe = Shockwave.CFrame
	BodyGyro.Parent = Shockwave

	local CurrentCharater = Character
	Shockwave.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if character and character ~= Character and torso and humanoid and humanoid.Health > 0 then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.P = 100000
			BodyVelocity.maxForce = Vector3.new(BodyVelocity.P, BodyVelocity.P, BodyVelocity.P)
			BodyVelocity.velocity = (torso.Position - Shockwave.Position) * 12
			Debris:AddItem(BodyVelocity, 1)
			Debris:AddItem(Shockwave, 1)
			BodyVelocity.Parent = torso
		end
	end)
	
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then 
		return
	end

	Tool.Enabled = false
	
	CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	Tuba = Handle:Clone()
	Tuba.CanCollide = false
	
	local Weld = Instance.new("Weld")
	Weld.Part1 = Torso
	Weld.Part0 = Tuba
	Weld.C1 = CFrame.new(Vector3.new(-0.3, 0.8, 0.0)) * CFrame.Angles(math.pi, 0.0, -(math.pi / 4))
	Weld.Parent = Tuba
	
	Tuba.Parent = Tool
	
	Handle.Transparency = 1
	
	InvokeClient("PlayAnimation", Animations.Play)
	
	Sounds.TubaSound:Play()
	
	if CurrentlyEquipped then
	
		wait(1.75)
		
		for i = 1, 4 do
			if CurrentlyEquipped then
				Shoot(Torso.CFrame.lookVector.unit)
				if i ~= 4 then
					wait(1.5)
				end
			end
		end
		
		if CurrentlyEquipped then
			wait(1)
			if Tuba and Tuba.Parent then
				Tuba:Destroy()
			end
			Handle.Transparency = 0
		end
		
	end
	
	wait(4)
	
	Tool.Enabled = true	
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
	Handle.Transparency = 0
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs({Tuba}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Sounds) do
		v:Stop()
		InvokeClient("StopSound", v)
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)