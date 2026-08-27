--Made by Luckymaxer

Knife = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Knife:WaitForChild("Creator")
Damage = Knife:WaitForChild("Damage")

KnifeHit = false

Rate = (1 / 60)

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

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

function Blow(Hit)
	if not Hit or not Hit.Parent or KnifeHit then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	local creator = GetCreator()
	local player = Players:GetPlayerFromCharacter(character)
	if player and creator and (player == creator or IsTeamMate(creator, player)) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, creator)
		humanoid:TakeDamage(Damage.Value)
	end
	KnifeHit = true
end

while Knife and Knife.Parent and not KnifeHit do
	local creator = GetCreator()
	local IgnoreList = {}
	if creator and creator.Character then
		table.insert(IgnoreList, creator.Character)
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") and IsTeamMate(creator, v) and v.Character then
				table.insert(IgnoreList, v.Character)
			end
		end
	end
	local BodyVelocity = Knife:FindFirstChild("BodyVelocity")
	if BodyVelocity then
		local RayHit, RayPos, RayNormal = CastRay(Knife.Position, BodyVelocity.velocity.Unit, (Knife.Size.Z * 1), IgnoreList, false)
		if RayHit then
			local PartCFrame = (CFrame.new(Knife.Position, RayPos) * CFrame.new(0, 0, -(Knife.Size.Z * 0.75)) * CFrame.Angles(0, 0, (math.pi / 2)))
			local Weld = Create("Motor"){
				Name = "Stick",
				Part0 = Knife,
				Part1 = RayHit,
				C0 = PartCFrame:inverse(),
				C1 = RayHit.CFrame:inverse(),
				Parent = Knife,
			}
			for i, v in pairs(Knife:GetChildren()) do
				if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then
					v:Destroy()
				end
			end
			Blow(RayHit)
		end
	end
	wait(Rate)
end