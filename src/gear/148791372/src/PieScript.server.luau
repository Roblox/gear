--Made by Luckymaxer

Pie = script.Parent
HitSound = Pie:WaitForChild("Hit")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BodyGyro = Pie:WaitForChild("BodyGyro")
BodyForce = Pie:WaitForChild("BodyForce")
Creator = Pie:WaitForChild("creator")
Damage = Pie:WaitForChild("Damage")

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

function Stick(Hit)
	
	local Weld = Instance.new("Weld")
	Weld.Name = "PieWeld"
	Weld.Part0 = Pie
	Weld.Part1 = Hit
	
	local HitPos = Pie.Position

	local CF = CFrame.new(HitPos)
	local C0 = (Pie.CFrame:inverse() * CF)
	local C1 = (Hit.CFrame:inverse() * CF)
	
	Weld.C0 = C0
	Weld.C1 = C1

	Weld.Parent = Pie
	
end

function DamageCharacter(character)
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Creator.Value or IsTeamMate(Creator.Value, player)) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Creator)
	humanoid:TakeDamage(Damage.Value)
end

function Touched(Hit)
	if not Hit or not Hit.Parent or string.find(string.lower(Hit.Name), "pie") then
		return
	end
	local character = Hit.Parent
	if character:IsA("Tool") then
		return
	end
	if character:IsA("Accessory") then
		character = character.Parent
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and player == Creator.Value then
		return
	end
	for i, v in pairs({BodyGyro, BodyForce}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Stick(Hit)
	HitSound:Play()
	local character = Hit.Parent
	DamageCharacter(character)
	
	if Connection then
		Connection:disconnect()
	end
	
end

Connection = Pie.Touched:connect(Touched)

for i = 1, 10 do
	wait(0.1 * i)
	if BodyGyro then
		local v = Pie.Velocity.unit
		BodyGyro.maxTorque = Vector3.new(10000, 10000, 10000)
		BodyGyro.cframe = CFrame.new(Vector3.new(0, 0, 0), -v)
	end
end

wait(8)

Pie:Destroy()