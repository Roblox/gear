local Tool = script.Parent
local OldAxe = Tool.Handle

local debris = game:GetService("Debris")

local myCharacter = Tool.Parent
local myHumanoid
local myPlayer
local Torso = myCharacter:FindFirstChild("Torso")
myHumanoid = myCharacter:FindFirstChild("Humanoid")
if not Torso or not myHumanoid then script:Remove() end
local TorsoFrame
if Torso then TorsoFrame = Torso.CFrame else TorsoFrame = CFrame.new() end	-- Re-checking for Torso just avoids an error message.

local LookVector = TorsoFrame.lookVector.unit
LookVector = (myHumanoid.TargetPoint - OldAxe.Position).unit 

local Rotator
local AxeHandle
local HandleWeld
local AxeBack
local BackWeld
local AxeBlade
local BladeWeld
local totalMass

local AntiGrav
local Force
local AngularVelocity

local SoundScript

local HitWeld

local WOOD_DAMAGE = 9	-- Low damage is because spinning weapons ==> many, many hits.
local BLADE_DAMAGE = 17

-- Set up the axe's parts :(

Rotator = Instance.new("Part")
Rotator.Name = "Pirate Axe Rotator"
Rotator.CanCollide = false
Rotator.Locked = true
Rotator.formFactor = 3	-- Custom
Rotator.Size = Vector3.new(0.2, 0.2, 0.2)
Rotator.Transparency = 1.0
Rotator.CFrame = TorsoFrame * CFrame.Angles(-math.pi/2, 0, math.pi) + Vector3.new(-1.52 * LookVector.Z, 1.62, 1.52 * LookVector.X - 0.75) + LookVector
Rotator.Parent = game.Workspace

AxeHandle = OldAxe:Clone()
AxeHandle.Size = Vector3.new(0.2, 0.2, 1.8)
AxeHandle.Transparency = 0.0
AxeHandle.Name = "Pirate Axe Handle"
AxeHandle.Parent = game.Workspace
AxeHandle.CFrame = Rotator.CFrame + Vector3.new(0, -0.32, 0.75)
AxeHandle.Material = "Wood"

HandleWeld = Instance.new("Weld")
HandleWeld.Name = "Pirate Axe Handle Weld"
HandleWeld.Part1 = AxeHandle
HandleWeld.Part0 = Rotator
HandleWeld.C1 = CFrame.new(0, -0.32, 0.75)
HandleWeld.Parent = game.Workspace

AxeBack = Instance.new("Part")
AxeBack.Name = "Pirate Axe Back"
AxeBack.Locked = true
AxeBack.formFactor = 3	--Custom
AxeBack.Size = Vector3.new(0.2, 0.6, 1.1)
AxeBack.Transparency = 1.0
AxeBack.CFrame = Rotator.CFrame + Vector3.new(0, -0.6, -0.1)
AxeBack.Material = "Wood"
AxeBack.Parent = game.Workspace

BackWeld = Instance.new("Weld")
BackWeld.Part1 = AxeBack
BackWeld.Part0 = Rotator
BackWeld.C1 = CFrame.new(0, -0.6, -0.1)
BackWeld.Name = "Pirate Axe Back Weld"
BackWeld.Parent = game.Workspace

AxeBlade = Instance.new("Part")
AxeBlade.Name = "Pirate Axe Blade"
AxeBlade.CanCollide = false
AxeBlade.Locked = true
AxeBlade.formFactor = 3	-- Custom
AxeBlade.Size = Vector3.new(0.2, 0.45, 1.3)
AxeBlade.Material = "Corroded Metal"
AxeBlade.Transparency = 1.0
AxeBlade.CFrame = Rotator.CFrame + Vector3.new(0, 0.3, 0)
AxeBlade.Parent = game.Workspace

BladeWeld = Instance.new("Weld")
BladeWeld.Part1 = AxeBlade
BladeWeld.Part0 = Rotator
BladeWeld.C1 = CFrame.new(0, 0.3, 0)
BladeWeld.Name = "Pirate Axe Blade Weld"
BladeWeld.Parent = game.Workspace

totalMass = Rotator:GetMass() + AxeHandle:GetMass() + AxeBack:GetMass() + AxeBlade:GetMass()

AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0, totalMass * 196.2, 0)

-- Functions and connections:
		
function tagAndUntagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = player
	CreatorTag.Parent = humanoid
	debris:AddItem(CreatorTag, 1)
end

function blow(hit, damage)
	local otherCharacter = hit.Parent
	myCharacter = Tool.Parent
	if not myCharacter or not otherCharacter then return end
	if otherCharacter ~= myCharacter and otherCharacter ~= Tool then
		if hit.CanCollide then
			Force.Parent = nil			-- Stop the axe from flying if (1) it hit a CanCollide true object, or
			AngularVelocity.Parent = nil
			if SoundScript then SoundScript:Remove() end
		end
		myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
		local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		if myHumanoid and otherHumanoid and myHumanoid ~= otherHumanoid then
			Force.Parent = nil			-- (2) it hit a person.
			AngularVelocity.Parent = nil
			if SoundScript then SoundScript:Remove() end
			tagAndUntagHumanoid(otherHumanoid, myPlayer)
			otherHumanoid:TakeDamage(damage)
		end
	end
end

function woodBlow(hit)
	blow(hit, WOOD_DAMAGE)
end

function bladeBlow(hit)
	blow(hit, BLADE_DAMAGE)
end

function impact(hit)
	local hitThing = hit.Parent
	myCharacter = Tool.Parent
	-- As with blow, we only hit objects that aren't us, aren't the axe, and either are CanCollide true
	--   or are parts of other characters.
	-- This function is connected to a hit on Rotator, rather than just on AxeBlade, to ensure that the axe is
	--   deep inside something before it sticks.
	if hitThing ~= myCharacter and hitThing ~= Tool and (hit.CanCollide or hitThing:FindFirstChild("Humanoid")) then
		Weld = Instance.new("Weld")
		Weld.Name = "Pirate Axe Hit Weld"
		Weld.Part0 = hit
		Weld.Part1 = Rotator
		Weld.C1 = Rotator.CFrame:inverse() * hit.CFrame
		Weld.Parent = game.Workspace
		
		Force.Parent = nil
		AngularVelocity.Parent = nil
		if SoundScript then SoundScript:Remove() end
	end
end
	

AxeHandle.Touched:connect(woodBlow)
AxeBack.Touched:connect(woodBlow)
AxeBlade.Touched:connect(bladeBlow)
Rotator.Touched:connect(impact)

-- Whew! Now to get to the things that actually do stuff.

Force = Instance.new("BodyForce")
Force.Name = "Pirate Axe Force"
Force.force = AntiGrav.force + LookVector * totalMass * 800
Force.Parent = Rotator

AngularVelocity = Instance.new("BodyAngularVelocity")
AngularVelocity.Name = "Pirate Axe Ang. Vel."
AngularVelocity.angularvelocity = 30 * Vector3.new(LookVector.Z, 0, -LookVector.X)
AngularVelocity.P = 100
AngularVelocity.maxTorque = Vector3.new(100, 100, 100)
AngularVelocity.Parent = Rotator

debris:AddItem(Rotator, 10)
debris:AddItem(AxeHandle, 10)
debris:AddItem(AxeBack, 10)
debris:AddItem(AxeBlade, 10)
debris:AddItem(script, 10)

SoundScript = Tool:FindFirstChild("SoundScript")
if SoundScript then
	SoundScript = SoundScript:Clone()
	SoundScript.Parent = Rotator
	SoundScript.Disabled = false
end

wait(0.1)

Force.force = AntiGrav.force








