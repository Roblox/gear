--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SpecialReady = true
SpecialActive = false

Damage = 10
SpecialDamage = 35
ReloadTime = 0.25
SpecialReloadTime = 15

Gravity = 196.20

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

function MakeCircle(Diameter, Consistency, Size, Position)
	local Parts = {}
	for i = 1, 360, Consistency do
		local Part = Handle:Clone()
		Part.CFrame = CFrame.new(Position) * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, Diameter)
		table.insert(Parts, Part)
	end
	return Parts
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

Handle.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or not Character then
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
	if not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	SpecialActive = true
	SpecialReady = false
	Humanoid.WalkSpeed = 0
	wait(0.5)
	Spawn(function()
		local SwordCircle = MakeCircle(18, 12, (Handle.Size * 2), Torso.Position + Vector3.new(0, ((Torso.Size.Y * 2) + 20), 0))
		for i, v in pairs(SwordCircle) do
			if v then
				v.Name = Tool.Name
				v.Size = (v.Size * 2)
				v.Mesh.Scale = (v.Mesh.Scale * 2)
				v.Friction = 2
				local Position = v.CFrame
				v.Anchored = true
				v.CanCollide = true
				local BodyGyro = Instance.new("BodyGyro")
				BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
				local BodyPosition = Instance.new("BodyPosition")
				BodyPosition.maxForce = Vector3.new(math.huge, 0, math.huge)
				Debris:AddItem(v, 10)
				v.Parent = game:GetService("Workspace")
				v.CFrame = CFrame.new(Position.p, Vector3.new(Torso.Position.X, Position.p.Y, Torso.Position.Z)) * CFrame.Angles(0, (math.pi / 2), math.pi)
				BodyGyro.cframe = v.CFrame
				BodyGyro.Parent = v
				BodyPosition.position = v.Position
				BodyPosition.Parent = v
			end
		end
		for i, v in pairs(SwordCircle) do
			if v and v.Parent then
				local HitGround = false
				v.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent or Hit.Name == Tool.Name then
						return
					end
					local HitParent = Hit.Parent
					if HitParent:IsA("Hat") or HitParent:IsA("Hat") then
						HitParent = HitParent.Parent
					end
					if not HitParent or HitParent == Character then
						return
					end
					local humanoid = HitParent:FindFirstChild("Humanoid")
					if not humanoid and not HitGround then
						HitGround = true
						local BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.maxForce = Vector3.new(0, ((v:GetMass() * Gravity)), 0)
						BodyVelocity.velocity = Vector3.new(0, -100000, 0)
						BodyVelocity.Parent = v
					elseif humanoid and humanoid.Health > 0 and humanoid ~= Humanoid then
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(SpecialDamage)
					end
				end)
				v.Anchored = false
			end
		end
	end)
	wait(2)
	Humanoid.WalkSpeed = 16
	SpecialActive = false
	wait(SpecialReloadTime)
	SpecialReady = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Character or not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Character = nil
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)