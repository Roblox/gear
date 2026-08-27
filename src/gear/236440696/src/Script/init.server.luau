--Made by Luckymaxer
--Edited by NonstopEpic
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

EatScript = script:WaitForChild("EatScript")
FoodScript = script:WaitForChild("FoodScript")

Gravity = 196.20

ReloadTime = 2

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Burger = BasePart:Clone()
Burger.Name = "Burger"
Burger.Size = Vector3.new(0.4, 0.5, 1.125)
BurgerMesh = Instance.new("SpecialMesh")
BurgerMesh.MeshType = Enum.MeshType.FileMesh
BurgerMesh.MeshId  = (BaseUrl .. "230851424")
BurgerMesh.TextureId = (BaseUrl .. "230851532")
BurgerMesh.Scale = Vector3.new(1, 1, 1)
BurgerMesh.Parent = Burger
Burger = {
	Object = Burger:Clone(),
	Offset = CFrame.new(0.125, 0, 0.35) * CFrame.Angles(0, 0, (math.pi / 2)),
}

Fries = BasePart:Clone()
Fries.Name = "Fries"
Fries.Size = Vector3.new(0.4, 0.5, 1.125)
FriesMesh = Instance.new("SpecialMesh")
FriesMesh.MeshType = Enum.MeshType.FileMesh
FriesMesh.MeshId  = (BaseUrl .. "230851485")
FriesMesh.TextureId = (BaseUrl .. "230851532")
FriesMesh.Scale = Vector3.new(2, 2, 2)
FriesMesh.Parent = Fries
Fries = {
	Object = Fries:Clone(),
	Offset = CFrame.new(0.125, 0, 0.35) * CFrame.Angles(-(math.pi / 2), 0, 0),
}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

function ProjectileTouched(Projectile, ProjectileType)
	local PartTouched
	local ProjectileHit = false
	PartTouched = Projectile.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or ProjectileHit then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		ProjectileHit = true
		if Projectile and Projectile.Parent then
			Projectile:Destroy()
		end
		local DamageValue = ((Projectile.Name == "Burger" and 20) or 35)
		local RightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
		if RightArm then
			local DurationTime = 1.5
			local FoodPart = ProjectileType.Object:Clone()
			local WeldGrip = Instance.new("Weld")
			WeldGrip.Part0 = RightArm
			WeldGrip.Part1 = FoodPart
			WeldGrip.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			WeldGrip.C1 =  ProjectileType.Offset
			WeldGrip.Parent = FoodPart
			local EatScriptClone = EatScript:Clone()
			local Food = Instance.new("ObjectValue")
			Food.Name = "Food"
			Food.Value = FoodPart
			Food.Parent = EatScriptClone
			EatScriptClone.Disabled = false
			Debris:AddItem(EatScriptClone, 7)
			Debris:AddItem(FoodPart, DurationTime)
			EatScriptClone.Parent = humanoid
			FoodPart.Parent = Hit.Parent
			local FoodScriptClone = FoodScript:Clone()
			local Duration = Instance.new("NumberValue")
			Duration.Name = "Duration"
			Duration.Value = DurationTime
			Duration.Parent = FoodScriptClone
			local Damage = Instance.new("NumberValue")
			Damage.Name = "Damage"
			Damage.Value = DamageValue
			Damage.Parent = FoodScriptClone
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "Creator"
			Creator.Value = Player
			Creator.Parent = FoodScriptClone
			FoodScriptClone.Disabled = false
			FoodScriptClone.Parent = character
		else
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DamageValue)
		end
	end)
	return PartTouched
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Speed = 100
	local SpawnPosition = (Handle.CFrame * CFrame.new(0, 0, -0.5))
	local TargetPosition = InvokeClient("MousePosition").Position
	SpawnPosition = (SpawnPosition + Handle.CFrame.lookVector * ((Handle.Size.Z / 2) + (Fries.Object.Size.Y / 2)))
	local Direction = CFrame.new(SpawnPosition.p, TargetPosition)
	local FoodType = math.random(1, 4)
	FoodType = ((FoodType == 1 and Fries) or Burger)
	local ProjectileClone = FoodType.Object:Clone()
	local Mass = (ProjectileClone:GetMass() * Gravity)
	local Velocity = (Direction.lookVector * Speed)
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = ProjectileClone
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyVelocity.velocity = Velocity
	BodyVelocity.Parent = ProjectileClone
	local RotationDirection = (Direction * CFrame.Angles(0, 0, 0))
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = RotationDirection
	BodyGyro.Parent = ProjectileClone
	ProjectileClone.CFrame = RotationDirection
	ProjectileClone.Velocity = Velocity
	Debris:AddItem(ProjectileClone, 5)
	Debris:AddItem(BodyVelocity, 0.2)
	ProjectileClone.Parent = game:GetService("Workspace")
	ProjectileTouched(ProjectileClone, FoodType)
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

--[[ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end)]]

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)