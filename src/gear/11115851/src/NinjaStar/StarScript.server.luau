--Rescripted by Luckymaxer

Star = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = Star:FindFirstChild("creator")

HitSound = Star:FindFirstChild("Hit")

Stuck = false

Damage = 23

function IsHuntedVictim(character)
	return character:FindFirstChild("NinjaMaskOfShadows")
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

function Stick(Object, Hit)
	local Weld = Instance.new("Weld")
	Weld.Part0 = Object
	Weld.Part1 = Hit
	local HitCFrame = CFrame.new(Object.Position)
	Weld.C0 = Object.CFrame:inverse() * HitCFrame
	Weld.C1 = Hit.CFrame:inverse() *  HitCFrame
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
	if Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character then
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
	Stick(Star, Hit)
	if HitSound then
		HitSound:Play()
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		if CreatorPlayer then
			TagHumanoid(humanoid, CreatorPlayer)
		end
		humanoid:TakeDamage(Damage * ((IsHuntedVictim(character) and 2) or 1))
	end
end
	
Star.Touched:connect(Touched)