--Rescripted by Luckymaxer

Plunger = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Plunger:WaitForChild("Creator")
Damage = Plunger:WaitForChild("Damage")

Sounds = {
	Hit = Plunger:WaitForChild("Hit")
}

Stuck = false

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

function GetCreator()
	local Player = (((Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
	local Character = (((Player and Player.Character and Player.Character.Parent) and Player.Character) or nil)
	return Player, Character
end

function Blow(Hit)
	if not Hit or not Hit.Parent or Plunger.Velocity.magnitude < 5 or Stuck then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	local CreatorPlayer, CreatorCharacter = GetCreator()
	if character == CreatorCharacter then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (CreatorPlayer and IsTeamMate(CreatorPlayer, player)) then
		return
	end
	Stuck = true
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage.Value)
	local plunger = character:FindFirstChild("Plunger")
	if not plunger then
		local head = character:FindFirstChild("Head")
		if head then
			Sounds.Hit:Play()
			local Weld = Create("Weld"){
				Part0 = head,
				Part1 = Plunger,
				Parent = Plunger,
				C1 = (CFrame.new(0, 0, -((head.Size.Z + Plunger.Size.Z) / 2)) * CFrame.Angles(math.pi, 0, 0)),
			}
			Plunger.Parent = character
		end
	elseif plunger then
		Plunger:Destroy()
	end
end

Plunger.Touched:connect(Blow)