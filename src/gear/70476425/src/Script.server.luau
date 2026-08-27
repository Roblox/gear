--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Draco = BasePart:Clone()
Draco.Name = "HC"
Draco.Shape = Enum.PartType.Ball
Draco.Size = Vector3.new(2, 2, 2)
Draco.CanCollide = false
DracoMesh = Instance.new("SpecialMesh")
DracoMesh.MeshType = Enum.MeshType.FileMesh
DracoMesh.Name = "Mesh"
DracoMesh.MeshId = "http://www.roblox.com/asset/?id=70433620"
DracoMesh.TextureId = "http://www.roblox.com/asset/?id=70433639"
DracoMesh.Scale = Vector3.new(0.6, 0.6, 0.6)
DracoMesh.VertexColor = Vector3.new(1, 1, 1)
DracoMesh.Parent = Draco
Fire = Instance.new("Fire")
Fire.Parent = Draco

NewBV = Instance.new("BodyVelocity")
NewBV.P = 1000
NewBV.maxForce = Vector3.new(NewBV.P, NewBV.P, NewBV.P)
NewBV.Name = "BV"

Sounds = {
	Fire = Handle:WaitForChild("Fire")
}

Damage = 15
ReloadTime = 4.5

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function LightThemUp(Hit, Part)
	if not Hit or not Hit.Parent or not Part then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(14)
	local fire = Part:FindFirstChild(Fire.Name)
	if fire then
		local NewFire = fire:Clone()
		Debris:AddItem(NewFire, 5)
		NewFire.Parent = Hit
	end
end 

function Blow(Hit, Part)
	if not Hit or not Hit.Parent or Hit.Name == Draco.Name or not Part then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	if character == Character or character == Tool then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Damage)
	end
	local Explosion = Instance.new("Explosion")
	Explosion.Name = "Explosion"
	Explosion.BlastPressure = 9999		
	Explosion.BlastRadius = 5
	Explosion.Position = Part.Position
	Debris:AddItem(Explosion, 1)
	Explosion.Parent = game:GetService("Workspace")
	local Radius = 1
	Radius = (Radius * 100)
	for i = 1, math.random(5, 9) do 
		local FireDraco = Draco:Clone()
		if FireDraco:FindFirstChild("Mesh") then 
			FireDraco.Mesh.Scale = Vector3.new(0.35, 0.35, 0.35)
		end
		FireDraco.CanCollide = true
		FireDraco.CFrame = Part.CFrame + Vector3.new((math.random(-Radius, Radius) * 0.01), (math.random(-Radius, Radius) * 0.01), (math.random(-Radius, Radius) * 0.01))
		FireDraco.Velocity = (FireDraco.Velocity / 10)
		FireDraco.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			LightThemUp(Hit, FireDraco) 
		end) 
		Debris:AddItem(FireDraco, 5)
		FireDraco.Parent = game:GetService("Workspace")
	end
	if Part and Part.Parent then
		Part:Destroy()
	end
end

function Shoot()
	
	Tool.Enabled = false
	
	Sounds.Fire:Play()	
	
	local DracoClone = Draco:Clone()
	DracoClone.CanCollide = false

	local TargetPosition = InvokeClient("MousePosition")
	local Direction = CFrame.new(Handle.Position, TargetPosition)
	local DirectionVector = Direction.lookVector	
	
	local SpawnPos = Handle.Position
	SpawnPos = SpawnPos + DirectionVector * 5		
	
	DracoClone.CFrame = CFrame.new(SpawnPos, SpawnPos + DirectionVector) + 1 * Vector3.new(0, 1, 0)
	
	DracoClone.Velocity = DirectionVector * 60	
	DracoClone.Name ="DracoClone"
	DracoClone.Parent = game.Workspace			

	local DracoCloneFloat = Instance.new("BodyForce")
	DracoCloneFloat.force =  Vector3.new(0, (DracoClone:GetMass() * workspace.Gravity), 0)
	DracoCloneFloat.Parent = DracoClone

	DracoClone.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		Blow(Hit, DracoClone)
	end)
	
	Debris:AddItem(DracoClone, 26)
	
	wait(ReloadTime)
	
	Tool.Enabled = true
	
end

function SetMaxHealth(humanoid, MaxHealth)
	if not humanoid then
		return
	end
	local Ratio = (humanoid.Health / humanoid.MaxHealth)
	humanoid.MaxHealth = MaxHealth
	humanoid.Health = (Ratio * MaxHealth)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Shoot()
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	SetMaxHealth(Humanoid, 200)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	SetMaxHealth(Humanoid, 100)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)