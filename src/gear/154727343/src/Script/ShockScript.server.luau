--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = script:WaitForChild("Creator")
Damage = script:WaitForChild("Damage")

AlreadyHit = false

function GetCreatorPlayer()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function ShockPlayer(character)
	local SelectionBoxes = {}
	if not character then
		return
	end
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not torso then
		return
	end
	local Parts = GetAllConnectedParts(torso)
	for i, v in pairs(Parts) do
		local SelectionBox = Create("SelectionBox"){
			Color = BrickColor.new("Cyan"),
			LineThickness = 0.1,
			Transparency = 0,
			Adornee = v,
		}
		table.insert(SelectionBoxes, SelectionBox)
		Debris:AddItem(SelectionBox, 2)
		SelectionBox.Parent = v
	end
	Spawn(function()
		for i = 1, 100, 0.05 do
			for i, v in pairs(SelectionBoxes) do
				v.Transparency = v.Transparency + 0.05
				if v.Transparency >= 0.999 then
					v:Destroy()
				end
			end
			wait()
		end
	end)
end

function Blow(Hit)
	if not Hit or not Hit.Parent or AlreadyHit then
		return
	end
	local CreatorPlayer = GetCreatorPlayer()
	local character = Hit.Parent
	if character:IsA("Accessory") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and CreatorPlayer and (player == CreatorPlayer or IsTeamMate(CreatorPlayer, player)) then
		return
	end
	AlreadyHit = true
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	ShockPlayer(character)
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage.Value)
end

Part.Touched:connect(Blow)