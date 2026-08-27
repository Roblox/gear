--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

BaseBullet = BasePart:Clone()
BaseBullet.Name = "LaserBullet"
BaseBullet.Size = Vector3.new(0.2, 2, 0.2)
BaseBullet.CanCollide = false
BaseBullet.BrickColor = BrickColor.new("Lime green")
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.Head
Mesh.Scale = Vector3.new(1, 1, 1)
Mesh.Parent = BaseBullet
Light = Instance.new("PointLight")
Light.Brightness = 1
Light.Range = 8
Light.Color = BaseBullet.BrickColor.Color
Light.Shadows = false
Light.Enabled = true
Light.Parent = BaseBullet

Grips = {
	Equipped = CFrame.new(0.15, -0.3, 0.8, 0.968230426, 0, 0.250059545, 0, 1, -0, -0.250059515, 0, 0.968230546),
	Unequipped = CFrame.new(0, -0.3, 0.8, 0.99999994, 0, 0, 0, 1, 0, 0, 0, 1)
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Shot = {Animation = Tool:WaitForChild("Shot"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1},
	SideShot = {Animation = Tool:WaitForChild("SideShot"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1},
	Crouch = {Animation = Tool:WaitForChild("Crouch"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Crawl = {Animation = Tool:WaitForChild("Crawl"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Equip = Handle:WaitForChild("Equip"),
	LaserShot = Handle:WaitForChild("LaserShot"),
	LaserHit1 = Handle:WaitForChild("LaserHit1"),
	LaserHit2 = Handle:WaitForChild("LaserHit2"),
}

Gravity = 196.20

Clicks = 0
FirstClick = false

CrawlMode = 0

Damage = 15

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Unequipped
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if (Key == "x" or Key == "c") and Down and Tool.Enabled then
				CrawlMode = ((CrawlMode < 2 and (CrawlMode + 1)) or 0)
				if CrawlMode == 1 then
					InvokeClient("PlayAnimation", Animations.Crouch)
					InvokeClient("StopAnimation", Animations.Crawl)
					Tool.Grip = Grips.Equipped
					if Humanoid and Humanoid.Parent then
						Humanoid.WalkSpeed = 0
						InvokeClient("DisableJump", true)
					end
				elseif CrawlMode == 2 then
					InvokeClient("PlayAnimation", Animations.Crawl)
					InvokeClient("StopAnimation", Animations.Crouch)
					Tool.Grip = Grips.Unequipped
					if Humanoid and Humanoid.Parent then
						Humanoid.WalkSpeed = 8
						InvokeClient("DisableJump", true)
					end
				else
					for i, v in pairs({Animations.Crouch, Animations.Crawl}) do
						InvokeClient("StopAnimation", v)
					end
					Tool.Grip = Grips.Equipped
					InvokeClient("DisableJump", false)
					if Humanoid and Humanoid.Parent then
						Humanoid.WalkSpeed = 16
					end
				end
			elseif (Key == "q" or Key == "l") and Down then
				if LightPart and LightPart.Parent then
					LightPart:Destroy()
				else
					LightPart = BasePart:Clone()
					LightPart.Name = "Light"
					LightPart.BrickColor = BrickColor.new("Really red")
					LightPart.Transparency = 1
					LightPart.Size = Vector3.new(0.2, 0.2, 0.2)
					LightPart.CanCollide = false
					local Light = Instance.new("SpotLight")
					Light.Angle = 70
					Light.Brightness = 50
					Light.Color = BaseBullet.BrickColor.Color
					Light.Face = Enum.NormalId.Top
					Light.Range = 16
					Light.Shadows = false
					Light.Enabled = true
					Light.Parent = LightPart
					local Weld = Instance.new("Weld")
					Weld.Part0 = LightPart
					Weld.Part1 = Handle
					Weld.C1 = CFrame.new(0.155, 0.53, -(((Handle.Size.Z / 2) + (LightPart.Size.Y / 2)) - 5)) * CFrame.Angles(-(math.pi / 2), 0, 0)
					Weld.Parent = LightPart
					LightPart.Parent = Handle
				end
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
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

function PositionPart(Part, X, Y, Z)
	local PartClone = Part:Clone()
	local PartCloneY = PartClone:Clone()
	PartCloneY.CFrame = PartCloneY.CFrame * CFrame.Angles(-math.rad(90), 0, 0)		
	PartCloneY.CFrame = PartCloneY.CFrame - PartCloneY.CFrame.lookVector * Y
	local PartCloneZ = PartCloneY:Clone()
	PartCloneZ.CFrame = PartCloneZ.CFrame + PartClone.CFrame.lookVector * Z
	local PartCloneX = PartCloneZ:Clone()
	PartCloneX.CFrame = PartCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	PartCloneX.CFrame = PartCloneX.CFrame - PartCloneX.CFrame.lookVector * X
	return PartCloneX.CFrame
end

function FireBullet(SpawnPosition, TargetPosition)
	local Force = 150
	local Bullet = BaseBullet:Clone()
	local Mass = (Bullet:GetMass() * Gravity)
	TargetPosition = ((not TargetPosition and (SpawnPosition + Handle.CFrame.lookVector * 2).p) or TargetPosition)
	local Direction = CFrame.new(SpawnPosition.p, TargetPosition)
	local Orientation = (Direction + Direction.lookVector * (Bullet.Size.Y / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	local Velocity = Direction.lookVector * Force
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyVelocity.velocity = Velocity
	BodyVelocity.Parent = Bullet
	Bullet.Velocity = Velocity
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = Orientation
	BodyGyro.Parent = Bullet
	local HitSounds = {Sounds.LaserHit1, Sounds.LaserHit2}
	local HitSoundChosen = HitSounds[math.random(1, #HitSounds)]:Clone()
	HitSoundChosen.Name = "HitSound"
	HitSoundChosen.Parent = Bullet
	Debris:AddItem(Bullet, 3)
	Bullet.Parent = game:GetService("Workspace")
	Bullet.CFrame = Orientation
	return Bullet
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Fire(TargetPosition)
	InvokeClient("PlaySound", Sounds.LaserShot)
	local Bullets = {}
	local SpawnPosition = PositionPart(Handle, -0.1, 0.175, ((Handle.Size.Z / 2) - 0.06))
	table.insert(Bullets, FireBullet(SpawnPosition, TargetPosition))
			
	local SpawnPosition = PositionPart(Handle, -0.1, 0.385, ((Handle.Size.Z / 2) + 0.04))
	table.insert(Bullets, FireBullet(SpawnPosition, TargetPosition))
	return Bullets
end
function Activated()
	if not Tool.Enabled then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		local Animation = (((Clicks > 1 and CrawlMode == 0) and Animations.SideShot) or Animations.Shot)
		if CrawlMode == 0 then
			InvokeClient("PlayAnimation", Animation)
		end
		local Bullets = {}
		if Animation == Animations.Shot then
			
			local TargetPosition = InvokeClient("MousePosition", nil)
			Bullets = Fire(TargetPosition)
			
		else
			
			local Shots = math.random(5, 8)
			for i = 1, Shots do
				if CurrentlyEquipped then
					Bullets = Fire(nil)
					wait((Animation.Duration / Shots) / 2)
				end
			end
			
		end
		for i, v in pairs(Bullets) do
			if v and v.Parent and v:IsA("BasePart") then
				v.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent then
						return
					end
					if Hit.Parent ~= Tool and not CheckTableForInstance(Bullets, Hit) then
						v:Destroy()
					end
					local character = Hit.Parent
					if character:IsA("Hat") or character:IsA("Tool") and character.Parent then
						character = character.Parent
					end
					local HitSound = v:FindFirstChild("HitSound")
					if HitSound then
						HitSound:Play()
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(Damage)
					end
				end)
			end
		end
		wait(Animation.Duration)
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	InvokeClient("PlaySound", Sounds.Equip)
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	InvokeClient("PlayAnimation", Animations.Equip)
	Tool.Grip = Grips.Equipped
end

function Unequipped()
	CrawlMode = 0
	Clicks = 0
	FirstClick = false
	if LightPart and LightPart.Parent then
		LightPart:Destroy()
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	InvokeClient("DisableJump", false)
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	InvokeClient("StopSound", Sounds.Equip)
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	Tool.Grip = Grips.Unequipped
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)