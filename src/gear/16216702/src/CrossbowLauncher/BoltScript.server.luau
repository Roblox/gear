--Rescripted by Luckymaxer

Bolt = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Bolt:FindFirstChild("creator")

BodyForce = Bolt:FindFirstChild("BodyForce")
BodyGyro = Bolt:FindFirstChild("BodyGyro")

HitSound = Bolt:FindFirstChild("Hit")

Stuck = false

Damage = 33

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

function Stick(Object, Hit)
	local Weld = Instance.new("Weld")
	Weld.Part0 = Bolt
	Weld.Part1 = Hit
	local HitPos = Bolt.Position + (Bolt.Velocity.unit * 3)
	local CJ = CFrame.new(HitPos)
	Weld.C0 = Bolt.CFrame:inverse() * CJ
	Weld.C1 = Hit.CFrame:inverse() * CJ
	Weld.Parent = Object
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function Touched(Hit)
	if not Hit or not Hit.Parent or Stuck then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	local CreatorPlayer
	if Creator and Creator.Value and Creator.Value:IsA("Player") then
		CreatorPlayer = Creator.Value
	end
	if CreatorPlayer and CreatorPlayer.Character == character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if CreatorPlayer and player and IsTeamMate(CreatorPlayer, player) then
		return
	end
	Stuck = true
	Stick(Bolt, Hit)
	if HitSound then
		HitSound:Play()
	end
	for i, v in pairs({BodyForce, BodyGyro}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		if CreatorPlayer then
			TagHumanoid(humanoid, CreatorPlayer)
		end
		humanoid:TakeDamage(Damage)
	end
end
	
Bolt.Touched:connect(Touched)

for i = 1, 100 do
	wait(0.1 * i)
	if BodyGyro and BodyGyro.Parent then
		BodyGyro.cframe = CFrame.new(Vector3.new(0,0,0), -Bolt.Velocity.unit)
	end
end