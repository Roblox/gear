--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

CatapultModel = InsertService:LoadAsset(174303861)
Catapult = CatapultModel:GetChildren()[1]:Clone()
CatapultModel:Destroy()

CurrentCatapult = Tool:WaitForChild("CurrentCatapult")
CurrentCatapult.Value = nil

Remover = script:WaitForChild("Remover")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Equipped = false
Spawned = false

Damage = 35

RemovalReloadTime = 5
FireReloadTime = 3

Gravity = 196.2

Rock = Instance.new("Part")
Rock.Name = "Rock"
Rock.BrickColor = BrickColor.new("Bright red")
Rock.Material = Enum.Material.Granite
Rock.Shape = Enum.PartType.Block
Rock.TopSurface = Enum.SurfaceType.Smooth
Rock.BottomSurface = Enum.SurfaceType.Smooth
Rock.FormFactor = Enum.FormFactor.Custom
Rock.Size = Vector3.new(1, 1, 1)
Rock.CanCollide = true
Rock.Locked = true
Fire = Instance.new("Fire")
Fire.Color = Color3.new((255 / 255), (127 / 255), (0 / 255))
Fire.SecondaryColor = Color3.new((255 / 255), (0 / 255), (0 / 255))
Fire.Heat = 2
Fire.Size = 7.5
Fire.Enabled = true
Fire.Parent = Rock

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

Handle.Transparency = 0

Tool.Enabled = true

function DestroyCatapult()
	if CurrentCatapult.Value then
		CurrentCatapult.Value:Destroy()
	end
	if RockClone and RockClone.Parent then
		RockClone:Destroy()
	end
	if Spawned then
		Tool.Enabled = false
		wait(RemovalReloadTime)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
	Spawned = false
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

ServerControl.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "Click" and Value.Down and Tool.Enabled and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso then
		if (not CurrentCatapult.Value  or not CurrentCatapult.Value.Parent) then
			Spawned = true
			CatapultVehicle = Catapult:Clone()
			CurrentCatapult.Value = CatapultVehicle
			local RemoverClone = Remover:Clone()
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "Creator"
			Creator.Value = Player
			Creator.Parent = CatapultVehicle
			RemoverClone.Disabled = false
			RemoverClone.Parent = CatapultVehicle
			CatapultBody = CatapultVehicle:FindFirstChild("Body")
			ArmMotor = CatapultBody:FindFirstChild("ArmMotor")
			FiringPoint = CatapultVehicle:FindFirstChild("FiringPoint")
			ArmMotor.MaxVelocity = 0.1
			ArmMotor.DesiredAngle = 0
			CatapultVehicle.Parent = game:GetService("Workspace")
			CatapultBody.CFrame = (Torso.CFrame - Vector3.new(0, 0, 0)) + Torso.CFrame.lookVector * (((CatapultVehicle:GetModelSize().Z / 2) + (Torso.Size.Z / 2)) + 1)
			Handle.Transparency = 1
		else
			local TargetInFront = math.acos((Value.Position - CatapultBody.Position).unit:Dot(CatapultBody.CFrame.lookVector))
			if TargetInFront > (math.pi / 2) then
				return
			end
			Tool.Enabled = false
			ArmMotor.DesiredAngle = 0.7
			RockClone = Rock:Clone()
			RockClone.CanCollide = true
			local RockWeld = Instance.new("Weld")
			RockWeld.Part0 = RockClone
			RockWeld.Part1 = FiringPoint
			RockWeld.C1 = CFrame.new(0, 0, -0.5) * CFrame.Angles(math.random(-math.pi, math.pi), math.random(-math.pi, math.pi), math.random(-math.pi, math.pi))
			RockWeld.Parent = RockClone
			Debris:AddItem(RockClone, 10)
			RockClone.Parent = game:GetService("Workspace")
			wait(1)
			ArmMotor.DesiredAngle = -0.75
			if RockClone and RockClone.Parent then
				RockClone.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent then
						return
					end
					local humanoid = Hit.Parent:FindFirstChild("Humanoid")
					if not humanoid or humanoid == Humanoid then
						return
					end
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
				end)
				RockClone.CanCollide = false
				Delay(0.5, function()
					if RockClone and RockClone.Parent then
						RockClone.Size = (RockClone.Size * 5)
						RockClone.Fire.Heat = (RockClone.Fire.Heat * 5)
						RockClone.Fire.Size = (RockClone.Fire.Size * 5)
						RockClone.CanCollide = true
					end
				end)
				local TargetPoint = Value.Position
				local Direction = (TargetPoint - CatapultBody.Position)
				local Distance = (TargetPoint - CatapultBody.Position).magnitude
				local Speed = 50
				local UpVector = Vector3.new(0, 1, 0)
				local DirectionY = Direction.Y
				Direction = (Direction *  Vector3.new(1, 0, 1))
				local DirectionXZ = Direction.magnitude 
				local XZVelocity = (Direction.unit * Speed)
				local YVelocity = (((Speed * DirectionY / DirectionXZ) + ((Gravity * DirectionXZ)/(2 * Speed))) * UpVector)
				RockWeld:Destroy()
				RockClone.Velocity = (XZVelocity + YVelocity)
				RockClone.RotVelocity = Vector3.new(0, 10, 0)
			end
			wait(2)
			ArmMotor.DesiredAngle = 0
			wait(FireReloadTime)
			Tool.Enabled = true
		end
	elseif Mode == "KeyPress" and Value.Key == "x" and Value.Down then
		DestroyCatapult()
	end
end)

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end

function Unequipped()
	Equipped = false
	DestroyCatapult()
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)