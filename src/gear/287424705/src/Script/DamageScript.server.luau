--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Part:WaitForChild("Creator")
Damage = Part:WaitForChild("Damage")

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

--[[function Float()
	local Wobble = {
		Size = 3,
		Speed = 0.3,
		Factor = 0,
	}
	local UpVector = Vector3.new(0, 0, 0)
	local SpeedVector = Part.Velocity
	local PerpVector = SpeedVector.Unit:Cross(UpVector)
	local RandomAngle = (math.random() * math.pi * 2) --Get random angle in the perpendicular plane we just solved for
	local WobbleVector = (PerpVector * math.cos(RandomAngle) + UpVector * math.sin(RandomAngle)) --Get a random "wobble vector" in the perpendicular plane
	Spawn(function()
		while true do
			if not Part or not Part.Parent then
				break
			end
			--Part.RotVelocity = (Part.RotVelocity + Vector3.new(0, ((math.random() - 0.5) * 2), 0)) --See if is z instead of x value
			Part.Velocity = (SpeedVector + WobbleVector * math.sin(Wobble.Factor) * Wobble.Size)
			Wobble.Factor = (Wobble.Factor + Wobble.Speed)
			wait(0.25)
		end
	end)
end]]

function GetCreator()
	return ((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value) or nil)
end

function Blow(Object)
	local TouchedConnection
	TouchedConnection = Object.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		local CreatorPlayer = GetCreator()
		local player = Players:GetPlayerFromCharacter(character)
		if player and CreatorPlayer and (player == CreatorPlayer or IsTeamMate(CreatorPlayer, player)) then
			return
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, CreatorPlayer)
		humanoid:TakeDamage(Damage.Value)
		Part.Anchored = true
		Part.Transparency = 1
	end)
	return TouchedConnection		
end

Blow(Part)