local Tool = script.Parent
local Bow = Tool.Handle

local myCharacter = Tool.Parent
local myHumanoid
local myTorso
local myPlayer
local TargetPoint

local defensiveModeOn
if not Tool:FindFirstChild("DefensiveModeOn") then
	defensiveModeOn = false
else
	defensiveModeOn = Tool.DefensiveModeOn.Value
end

if myCharacter then
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	myTorso = myCharacter:FindFirstChild("Torso") or myCharacter:FindFirstChild("UpperTorso")
	if defensiveModeOn then
		if myTorso then
			TargetPoint = myTorso.Position
		end
	else
		if myHumanoid then
			TargetPoint = myHumanoid.TargetPoint
		end
	end
end

local TargetedPart
if defensiveModeOn and myTorso then
	TargetedPart = myTorso
else
	TargetedPart = Tool:FindFirstChild("TargetedPart")
	if TargetedPart then 
		TargetedPart = TargetedPart.Value 
	end
end

local inAir = true

local SPEED = 50
local ACCURACY
if defensiveModeOn then
	ACCURACY = .25
else
	ACCURACY = .15
end

local idealVelocity

local debris = game:GetService("Debris")

local Mouse = Tool:FindFirstChild("Mouse")
if Mouse then Mouse = Mouse.Value end

local ActualTarget
local TargetWeld

local HitWeld
local recentlyHit = false

if TargetPoint and TargetedPart then
	ActualTarget = Instance.new("Part")
	ActualTarget.formFactor = Enum.FormFactor.Custom
	ActualTarget.Size = Vector3.new(0.2, 0.2, 0.2)
	ActualTarget.Transparency = 1.0
	ActualTarget.Name = "PumpkinCrossbowTarget"
	ActualTarget.CanCollide = false
	ActualTarget.CFrame = CFrame.new(TargetPoint)
	ActualTarget.Parent = game.Workspace

	TargetWeld = Instance.new("Weld")
	TargetWeld.Part0 = TargetedPart
	TargetWeld.Part1 = ActualTarget
	TargetWeld.C1 = ActualTarget.CFrame:inverse() * TargetedPart.CFrame
	TargetWeld.Parent = ActualTarget
end

local Bolt = Instance.new("Part")
Bolt.Name = "PumpkinBolt"
Bolt.formFactor = Enum.FormFactor.Custom
Bolt.Size = Vector3.new(0.5, 0.3, 1.9)
Bolt.CanCollide = false
Bolt.Locked = true
Bolt.BrickColor = BrickColor.new("Neon orange")
Bolt.Material = "Wood"

local BoltMesh = Instance.new("SpecialMesh")
BoltMesh.MeshId = "http://www.roblox.com/asset/?id=58553264"
BoltMesh.TextureId = "http://www.roblox.com/asset/?id=58367341"
BoltMesh.Parent = Bolt

local AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0, 196.2 * Bolt:GetMass(), 0)
AntiGrav.Parent = Bolt

local CackleSound
CackleSound = Tool:FindFirstChild("Cackle")
if CackleSound then
	CackleSound = CackleSound:Clone()
	CackleSound.Parent = Bolt
end

local ScreamSound = Tool:FindFirstChild("Scream")
if ScreamSound then
	ScreamSound = ScreamSound:Clone()
	ScreamSound.Parent = Bolt
end

function tagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Value = player
	CreatorTag.Name = "creator"
	if humanoid then CreatorTag.Parent = humanoid end
end

function untagHumanoid(humanoid)
	local Tag = humanoid:FindFirstChild("creator")
	if Tag then Tag:Destroy() end
end

function weldAndMaim(hit)
	local otherChar = hit.Parent
	if TargetedPart then
		local TargetedObject = TargetedPart.Parent
		if TargetedObject then
			if TargetedObject == otherChar or (TargetedObject.ClassName == "Hat" and TargetedObject.Parent == otherChar) then
				local otherHumanoid = otherChar:FindFirstChild("Humanoid")
				if otherHumanoid and otherHumanoid.ClassName == "Humanoid"  and not recentlyHit then
					recentlyHit = true
					myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
					tagHumanoid(otherHumanoid, myPlayer)
					otherHumanoid:TakeDamage(30)
					HitWeld = Instance.new("Weld")
					HitWeld.Part0 = hit
					HitWeld.Part1 = Bolt
					HitWeld.C1 = Bolt.CFrame:inverse() * hit.CFrame
					HitWeld.Parent = Bolt
					if AntiGrav then AntiGrav:Destroy() end
					if CackleSound then CackleSound:Stop() end
					if ScreamSound then ScreamSound:Play() end
					wait(1)
					untagHumanoid(otherHumanoid)
				end
			end
		end
	end
end

function defensiveWeldAndMaim(hit)
	local otherCharacter = hit.Parent
	if otherCharacter then
		if otherCharacter ~= myCharacter then
			local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
			if otherHumanoid and otherHumanoid.ClassName == "Humanoid"  and not recentlyHit then
				recentlyHit = true
				myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
				tagHumanoid(otherHumanoid, myPlayer)
				otherHumanoid:TakeDamage(30)
				HitWeld = Instance.new("Weld")
				HitWeld.Part0 = hit
				HitWeld.Part1 = Bolt
				HitWeld.C1 = Bolt.CFrame:inverse() * hit.CFrame
				HitWeld.Parent = Bolt
				if AntiGrav then AntiGrav:Destroy() end
				if CackleSound then CackleSound:Stop() end
				if ScreamSound then ScreamSound:Play() end
				wait(1)
				untagHumanoid(otherHumanoid)
			end
		end
	end
end


if defensiveModeOn then
	Bolt.Touched:connect(defensiveWeldAndMaim)
else
	Bolt.Touched:connect(weldAndMaim)
end


Bolt.CFrame = Bow.CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.new(0, 0.42, -0.45)
if defensiveModeOn then
	Bolt.Velocity = SPEED * Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).unit
else
	Bolt.Velocity = SPEED * Bolt.CFrame.lookVector
end
Bolt.Parent = game.Workspace
debris:AddItem(Bolt, 10)
if CackleSound then CackleSound:Play() end

if ActualTarget then
	idealVelocity = SPEED * (ActualTarget.Position - Bolt.Position).unit
else
	idealVelocity = Bolt.Velocity
end


while Bolt do
	if not recentlyHit then
		if ActualTarget then idealVelocity = SPEED * (ActualTarget.Position - Bolt.Position).unit end
		Bolt.Velocity = SPEED * (Bolt.Velocity + ACCURACY * (idealVelocity - Bolt.Velocity)).unit
		Bolt.CFrame = CFrame.new(Bolt.Position, Bolt.Position + Bolt.Velocity)	* CFrame.Angles(0, math.pi, 0)
	end
	wait()
end

if CackleSound then CackleSound:Stop() end
if ActualTarget then ActualTarget:Destroy() end
wait(2)	-- For the wait in weldAndMaim
script:Destroy()
	
