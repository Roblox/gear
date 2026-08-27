--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SpecialReady = true
SpecialActive = false

Damage = 10
ReloadTime = 0
SpecialReloadTime = 60

IgnoreParts = {"Head", "Torso", "HumanoidRootPart", "Right Arm"}

AnimPlaying = nil

ControlFunction = (Tool:FindFirstChild("ControlFunction") or Instance.new("RemoteFunction"))
ControlFunction.Name = "ControlFunction"
ControlFunction.Parent = Tool

ControlFunction.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "AnimationPlaying" and not AnimPlaying then
		AnimPlaying = Value
		wait(Value.Duration)
		AnimPlaying = nil
	elseif Mode == "KeyDown" and Value == "q" and SpecialReady then
		Spawn(function()
			ActivateSpecial()
		end)
		return true
	end
	return false
end)

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

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function CheckTableForInstance(Table, String)
	for i, v in pairs(Table) do
		if v == String then
			return true
		end
	end
	return false
end

Handle.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local HitParent = Hit.Parent
	if HitParent:IsA("Hat") or HitParent:IsA("Tool") then
		HitParent = HitParent.Parent
	end
	if Hit.Parent == Character then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	if AnimPlaying and AnimPlaying.Name == "Swing4" and not CheckTableForString(IgnoreParts, Hit.Name) then
		local Sparkles = Instance.new("Sparkles")
		Sparkles.Color = Color3.new(255, 255, (127 / 255))
		Debris:AddItem(Sparkles, 2)
		Sparkles.Parent = Handle
		Hit:BreakJoints()
	end
	local humanoid = HitParent:FindFirstChild("Humanoid")
	if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage((AnimPlaying and AnimPlaying.Damage) or Damage)
	end
end)

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function ActivateSpecial()
	SpecialActive = true
	SpecialReady = false
	Humanoid.WalkSpeed = 0
	wait(0.5)
	Spawn(function()
		local IgnoreObjects = {Character}
		local Radius = 30
		local CharacterSize = Character:GetModelSize()
		local CharacterCFrame = Character:GetModelCFrame()
		local NegativePartRadius = Vector3.new(((CharacterSize.X / 2) + (Radius / 1)), ((CharacterSize.Y / 2) + (Radius / 1)), ((CharacterSize.Z / 2) + (Radius / 1)))
		local PositivePartRadius = Vector3.new(((CharacterSize.X / 2) + (Radius / 1)), ((CharacterSize.Y / 2) + (Radius / 1)), ((CharacterSize.Z / 2) + (Radius / 1)))
		local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(CharacterCFrame.p - NegativePartRadius, CharacterCFrame.p + PositivePartRadius), IgnoreObjects, 100)
		local Humanoids = {}
		local Characters = {}
		local Orbs = {}
		for i, v in pairs(Parts) do
			if v and v.Parent then
				local character = v.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 and not CheckTableForInstance(Humanoids, humanoid) then
					humanoid.PlatformStand = true
					table.insert(Humanoids, humanoid)
					table.insert(Characters, character)
				end
			end
		end
		for i, v in pairs(Characters) do
			if v and v.Parent then
				local torso = v:FindFirstChild("Torso")
				if torso then
					local Orb = Instance.new("Part")
					Orb.Name = "Orb"
					Orb.BrickColor = BrickColor.new("Bright violet")
					Orb.Transparency = 0.5
					Orb.Material = Enum.Material.Plastic
					Orb.Shape = Enum.PartType.Block
					Orb.TopSurface = Enum.SurfaceType.Smooth
					Orb.BottomSurface = Enum.SurfaceType.Smooth
					Orb.FormFactor = Enum.FormFactor.Custom
					local ModelSize = v:GetModelSize()
					local SizeY = (ModelSize.Y * 1.5)
					Orb.Size = Vector3.new(SizeY, SizeY, SizeY)
					Orb.Locked = true
					Orb.CanCollide = false
					Orb.Anchored = false
					local Mesh = Instance.new("SpecialMesh")
					Mesh.MeshType = Enum.MeshType.Sphere
					Mesh.Scale = Vector3.new(1, 1, 1)
					Mesh.Parent = Orb
					local TotalMass = (GetTotalMass(v) + Orb:GetMass())
					local BodyForce = Instance.new("BodyVelocity")
					BodyForce.maxForce = Vector3.new(0, (TotalMass * 196.20 ^ 2), 0)
					BodyForce.Parent = Orb
					BodyForce.velocity = Vector3.new(0, 1.5, 0)
					Orb.CFrame = torso.CFrame
					local Weld = Instance.new("Weld")
					Weld.Part0 = Orb
					Weld.Part1 = torso
					Weld.Parent = Orb
					table.insert(Orbs, Orb)
					Debris:AddItem(Orb, 20)
					Orb.Parent = game:GetService("Workspace")
				end
			end
		end
		Delay(10, function()
			for i = 1, 100 do
				for ii, v in pairs(Orbs) do
					if v and v.Parent then
						local Mesh = v:FindFirstChild("Mesh")
						if Mesh then
							Mesh.Scale = Mesh.Scale - Vector3.new(0.01, 0.01, 0.01)
							wait(0.001)
						end
					end
				end
			end
			for i, v in pairs(Orbs) do
				if v and v.Parent then
					local Explosion = Instance.new("Explosion")
					Explosion.BlastRadius = 25
					Explosion.BlastPressure = 0
					Explosion.ExplosionType = Enum.ExplosionType.NoCraters
					Explosion.Position = v.Position
					Explosion.Parent = game:GetService("Workspace")
					v:Destroy()
				end
			end
			for i, v in pairs(Characters) do
				if v and v.Parent then
					local humanoid = v:FindFirstChild("Humanoid")
					if humanoid then
						humanoid.PlatformStand = false
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(humanoid.MaxHealth)
					end
				end
			end
		end)
	end)
	wait(4.5)
	Humanoid.WalkSpeed = 16
	SpecialActive = false
	wait(SpecialReloadTime)
	SpecialReady = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)