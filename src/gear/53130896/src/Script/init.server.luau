-- Voodoo Doll
-- Can cast FireBall and IceBall

--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Woohoo = Tool:WaitForChild("Woohoo")

VoodooScript = script:WaitForChild("VoodooScript")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 25

BillboardGui = Instance.new("BillboardGui")
BillboardGui.Name = "Announcement"
BillboardGui.Active = false
BillboardGui.Size = UDim2.new(1, 0, 1, 0)
BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
BillboardGui.AlwaysOnTop = true
TextLabel = Instance.new("TextLabel")
TextLabel.Text = ""
TextLabel.TextColor = BrickColor.new(Color3.new(1, 0, 0))
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.FontSize = 4
TextLabel.Parent = BillboardGui

Ball = Instance.new("Part")
Ball.Name = "HC"
Ball.Material = Enum.Material.Granite
Ball.Shape = Enum.PartType.Ball
Ball.TopSurface = Enum.SurfaceType.Smooth
Ball.BottomSurface = Enum.SurfaceType.Smooth
Ball.FormFactor = Enum.FormFactor.Custom
Ball.Size = Vector3.new(1, 1, 1) 
Ball.Transparency = 0.25
Ball.CanCollide = false

BodyForce = Instance.new("BodyForce") 
BodyForce.force = Vector3.new(0, Ball:GetMass() * workspace.Gravity, 0)
BodyForce.Name = "BodyForce"


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

function Blow(Hit, BallClone)
	if Hit and Hit.Parent then
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= Humanoid then
			if not Hit.Parent:FindFirstChild(VoodooScript.Name) then
				local VoodooScriptClone = VoodooScript:Clone()
				VoodooScriptClone.Disabled = false
				local creator = Instance.new("ObjectValue")
				creator.Name = "creator"
				creator.Value = Player
				creator.Parent = VoodooScriptClone
				local Tag = BallClone:FindFirstChild("Debuff")
				Tag.Parent = VoodooScriptClone
				VoodooScriptClone.Parent = Hit.Parent
			end
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage)
		end
	end
	if BallClone and BallClone.Parent then
		BallClone:Destroy()
	end
end

function Shoot(Position)
	local SpawnPosition = Torso.Position
	SpawnPosition = SpawnPosition + Position.unit * 5

	local BallClone = Ball:Clone()
	BallClone.CFrame = CFrame.new(SpawnPosition, (SpawnPosition + Position))
	Debris:AddItem(BallClone, 5)
	BallClone.Parent = game:GetService("Workspace")
	BallClone.Velocity = (Position * 75)
	
	local BallFloat = BodyForce:Clone()
	BallFloat.Parent = BallClone

	local Random = math.random(1, 2)	
	
	BallClone.BrickColor = BrickColor.new((Random == 1 and "Bright red") or "Pastel Blue")

	local Tag = Instance.new("StringValue")
	Tag.Name = "Debuff"
	Tag.Value = ((Random == 1 and "Fire") or "Ice")
	Tag.Parent = BallClone
	local Fire = Instance.new("Fire")
	Fire.Color = ((Random == 2 and Color3.new(0, 0, 10.75)) or Fire.Color)
	Fire.Parent = BallClone

	BallClone.Touched:connect(function(Hit)
		Blow(Hit, BallClone)
	end)
	
end

function Activated()
	
	if not Tool.Enabled then
		return
	end
	
	Tool.Enabled = false

	BillboardGui.Adornee = Head

	Woohoo:Play()
	
	local Random = math.random(1, 2)
	
	if Random == 1 then
		TextLabel.Text = "EXTRA HEALTH!!"
		local Ratio = (Humanoid.Health / Humanoid.MaxHealth)
		Humanoid.MaxHealth = 160
		Humanoid.Health = (Ratio * 160)
	else
		TextLabel.Text = "HASTE!!"
		Humanoid.WalkSpeed = 22
	end
	
	wait(1)
	
	TextLabel.Text = ""

	wait(5)
	
	local Ratio = (Humanoid.Health / Humanoid.MaxHealth)
	Humanoid.Health = (Ratio * 100)
	Humanoid.MaxHealth = 100
	Humanoid.WalkSpeed = 16
	
	wait(2.0)
	
	Tool.Enabled = true
	
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Head or not Torso then
		return
	end
	BillboardGui.Parent = Player.PlayerGui
	
	HumanoidDamagedConnection = Humanoid.ChildAdded:connect(function(Child)
		if Child:IsA("ObjectValue") and Child.Name == "creator" then
			local Enemy = Child.Value
			if Enemy and Enemy.Parent and Enemy ~= Player then
				local EnemyCharacter = Enemy.Character
				local EnemyTorso = EnemyCharacter:FindFirstChild("Torso")
				if EnemyTorso then
					TextLabel.Text = "YOUR ENEMY IS MY ENEMY"
					local Direction = (EnemyTorso.Position - Head.Position).unit
					Shoot(Direction)
				end
			end
		end
	end)
	
end

function Unequipped()
	if BillboardGui and BillboardGui.Parent then
		BillboardGui.Parent = nil
	end
	if HumanoidDamagedConnection then
		HumanoidDamagedConnection:disconnect()
	end
	if Humanoid and Humanoid.Parent then
		local Ratio = (Humanoid.Health / Humanoid.MaxHealth)
		Humanoid.Health = (Ratio * 100)
		Humanoid.MaxHealth = 100
		Humanoid.WalkSpeed = 16
	end
	Woohoo:Stop()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)