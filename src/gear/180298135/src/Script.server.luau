--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

CoffinModel = InsertService:LoadAsset(179174097)
Coffin = CoffinModel:GetChildren()[1]:Clone()
if CoffinModel and CoffinModel.Parent then
	CoffinModel:Destroy()
end

ZombieModel = InsertService:LoadAsset(180205370)
Zombie = ZombieModel:GetChildren()[1]:Clone()
if ZombieModel and ZombieModel.Parent then
	ZombieModel:Destroy()
end

SpecialReady = true
SpecialActive = false

Damage = 10
ReloadTime = 0.25
SpecialReloadTime = 60

AnimPlaying = nil

ControlFunction = (Tool:FindFirstChild("ControlFunction") or Instance.new("RemoteFunction"))
ControlFunction.Name = "ControlFunction"
ControlFunction.Parent = Tool

Tool.Enabled = true

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


function TransformModel(Objects, Center, NewCFrame, Recurse)
	Objects = ((type(Objects) ~= "table" and {Objects}) or Objects)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			v.CFrame = NewCFrame:toWorldSpace(Center:toObjectSpace(v.CFrame))
		end
		if Recurse then
			TransformModel(v:GetChildren(), Center, NewCFrame, true)
		end
	end
end

function CreateCoffin(CoffinModel, Center, Pos)
	local CoffinClone = Coffin:Clone()
	CoffinClone.Parent = CoffinModel
	Pos = CFrame.new(Pos.p, Center) * CFrame.Angles(0, (math.pi / 2), 0)
	Pos = Pos + Vector3.new(0, ((CoffinClone:GetModelSize().Y / 2) - (Torso.Size.Y * 1.5)), 0)
	TransformModel({CoffinClone}, CoffinClone:GetModelCFrame(), Pos, true)
	local ModelCFrame = CoffinClone:GetModelCFrame()
	TransformModel({CoffinClone}, CoffinClone:GetModelCFrame(), (CFrame.new(ModelCFrame.p, Vector3.new(Torso.Position.X, ModelCFrame.p.Y, Torso.Position.Z)) * CFrame.Angles(0, math.pi, 0)), true)
	return CoffinClone
end

function SpawnCoffins(Center)
	
	local CoffinModel = Instance.new("Model")
	CoffinModel.Name = "Coffins"
	Debris:AddItem(CoffinModel, 20)
	CoffinModel.Parent = game:GetService("Workspace")
	
	local NumberOfCoffins = 8
	local Increment = ((math.pi * 2) / NumberOfCoffins)
	local LookVector = CFrame.new(Center).lookVector
	local PosX = (10 * LookVector.x)
	local PosZ = (10 * LookVector.z)
	local Pos = Vector3.new((Center.x + PosX), Center.y, (Center.z + PosZ))
	local Coffins = {}

	for i = 1, NumberOfCoffins do
		local Coffin = CreateCoffin(CoffinModel, Center, CFrame.new(Pos))
 		local Angle = (Increment * i)
		table.insert(Coffins, Coffin)
		Pos = Vector3.new(((Pos.x - Center.x) * math.cos(Angle)) - ((Pos.z - Center.z) * math.sin(Angle)) + Center.x, Center.y, ((Pos.x - Center.x) * math.sin(Angle)) + ((Pos.z - Center.z) * math.cos(Angle)) + Center.z)
	end
	
	return Coffins

end

function ActivateSpecial()
	if not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	SpecialActive = true
	SpecialReady = false
	Humanoid.WalkSpeed = 0
	wait(0.5)
	if not Equipped then
		return
	end
	local Zombies = {}
	Spawn(function()
		local Coffins = SpawnCoffins(Torso.Position)
		for i, v in pairs(Coffins) do
			if v and v.Parent then
				local CoffinBottom = v:FindFirstChild("CoffinBottom")
				if CoffinBottom then
					local Smoke = Instance.new("Smoke")
					Smoke.Color = BrickColor.new("Institutional white").Color
					Smoke.Opacity = 0.25
					Smoke.RiseVelocity = 0.25
					Smoke.Size = 2
					Smoke.Enabled = true
					Debris:AddItem(Smoke, 8)
					Smoke.Parent = CoffinBottom
				end
			end
		end
		for i, v in pairs(Coffins) do
			if  v and v.Parent then
				local ZombieClone = Zombie:Clone()
				local Creator = ZombieClone:FindFirstChild("Creator")
				if Creator then
					Creator.Value = Player
				end
				table.insert(Zombies, {Zombie = ZombieClone, Coffin = v})
				local CoffinSize = v:GetModelSize()
				local CoffinCFrame = v:GetModelCFrame()
				local ZombieSize = ZombieClone:GetModelSize()
				for ii, vv in pairs(ZombieClone:GetChildren()) do
					if vv:IsA("BasePart") then
						vv.Anchored = true
					end
				end
				Debris:AddItem(ZombieClone, 30)
				ZombieClone.Parent = v
				TransformModel({ZombieClone}, ZombieClone:GetModelCFrame(), ((CoffinCFrame + Vector3.new(0, ((CoffinSize.Z / 2) - (ZombieSize.Y / 2)), 0)) * CFrame.Angles(0, math.pi, 0)), true)
			end
		end
		wait(3)
		local MaximumInterval = 100
		for i = 1, MaximumInterval do
			for ii, v in pairs(Coffins) do
				if  v and v.Parent then
					local CoffinCover = v:FindFirstChild("CoffinCover")
					if CoffinCover then
						local CoverSize = CoffinCover:GetModelSize()
						local CoverCFrame = CoffinCover:GetModelCFrame()
						TransformModel({CoffinCover}, CoverCFrame, (CoverCFrame - Vector3.new(0, (CoverSize.Z / MaximumInterval), 0)), true)
					end
					if i == MaximumInterval then
						local CoffinTop = CoffinCover:FindFirstChild("CoffinTop")
						if CoffinTop then
							CoffinTop.CanCollide = false
						end
					end
				end
			end
			wait(0.01)
		end
		wait(2)
		local MaximumInterval = 10
		for i = 1, MaximumInterval do
			for ii, v in pairs(Zombies) do
				if v.Zombie and v.Zombie.Parent and v.Coffin and v.Coffin.Parent then
					local CoffinSize = v.Coffin:GetModelSize()
					local CoffinCFrame = v.Coffin:GetModelCFrame()
					local ZombieSize = v.Zombie:GetModelSize()
					local ZombieCFrame = v.Zombie:GetModelCFrame()
					local NewCFrame = (ZombieCFrame + CoffinCFrame.lookVector * -((((CoffinSize.Z / 2) + (ZombieSize.Z / 2)) / 2) / i))
					TransformModel({v.Zombie}, ZombieCFrame, NewCFrame, true)
				end
			end
			wait(0.01)
		end
		for i, v in pairs(Zombies) do
			if v.Zombie and v.Zombie.Parent and v.Coffin and v.Coffin.Parent then
				local CoffinSize = v.Coffin:GetModelSize()
				local ZombieSize = v.Zombie:GetModelSize()
				local ZombieCFrame = v.Zombie:GetModelCFrame()
				local NewCFrame = ZombieCFrame - Vector3.new(0, 1, 0)
				TransformModel({v.Zombie}, ZombieCFrame, NewCFrame, true)
			end
		end
		for i, v in pairs(Zombies) do
			if v.Coffin and v.Coffin.Parent then
				Debris:AddItem(v.Coffin, 4)
			end
			if v.Zombie and v.Zombie.Parent then
				v.Zombie.Parent = game:GetService("Workspace")
				for ii, vv in pairs(v.Zombie:GetChildren()) do
					if vv:IsA("BasePart") then
						vv.Anchored = false
					end
				end
				local torso = v.Zombie:FindFirstChild("Torso")
				v.Zombie.Humanoid.Jump = true
				local BodyGyro = Instance.new("BodyGyro")
				Debris:AddItem(BodyGyro, 3)
				BodyGyro.Parent = torso
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
	Equipped = true
end

function Unequipped()
	Equipped = false
	Character = nil
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)