local Tool = script.Parent
local Sword = Tool.Handle

local myCharacter
local myPlayer
local myHumanoid
local Torso

local shotSound

local connection

local PROJECTILE_DAMAGE = 30
local FIRE_DAMAGE = 5

local debris = game:service("Debris")

-- Standard tagging and untagging functions for kill-counting purposes
function tagHumanoid(humanoid, player)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if not humanoid then return end
	local creatorTag = humanoid:FindFirstChild("creator")
	if creatorTag then creatorTag:Remove() end
end

-- Hit from projectile
function projectileBlow(hit)
	if not hit or not hit.Parent then return end
	myCharacter = Tool.Parent
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myCharacter or not myPlayer then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	local hitHumanoid = hit.Parent:FindFirstChild("Humanoid")
	print (myCharacter)
	print (myHumanoid)
	print (hit.Parent)

	if myHumanoid and hitHumanoid and myHumanoid ~= hitHumanoid then
		tagHumanoid(hitHumanoid, myPlayer)
		hitHumanoid:TakeDamage(PROJECTILE_DAMAGE)
		-- Random chance of lighting victim on fire, as long as they aren't already on fire.
		if (math.random() > 0.8 and (hit:FindFirstChild("DragonSwordHitFire") == nil)) then
			local hitHumFire = Instance.new("Fire")
			hitHumFire.Name = "DragonSwordHitFire"
			hitHumFire.Size = 3.5
			hitHumFire.Parent = hit
			for i = 1, 5 do
				wait(1)
				hitHumanoid:TakeDamage(FIRE_DAMAGE)
			end
			hitHumFire:Remove()
		else
			wait(1)	-- To give time to update the leaderboard before we untag.
		end
		untagHumanoid(hitHumanoid, myPlayer)
	end		
end

-- Shoot a flaming projectile forward.

-- Make sure our person still has a torso, so we can shoot from it.
myCharacter = Tool.Parent
if not myCharacter then return end
Torso = myCharacter:FindFirstChild("Torso")
if not Torso then return end

shotSound = Tool:FindFirstChild("ShotSound")
if shotSound then shotSound:Play() end
-- Create a new part as the projectile, light it on fire, and send it flying!
local Projectile = Instance.new("Part")

Projectile.CanCollide = false
Projectile.Transparency = 0
Projectile.formFactor = 3	--Custom
Projectile.Shape = 0	--Ball
Projectile.Size = Vector3.new(.5, .5, .5)
Projectile.Locked = true
Projectile.Parent = game.Workspace
Projectile.CFrame = Torso.CFrame + Torso.CFrame.lookVector.unit * 4
Projectile.BrickColor = BrickColor.new(106)	-- Bright orange
Projectile.Material = Enum.Material.CorrodedMetal

local ProjectileFire = Instance.new("Fire")
ProjectileFire.Size = 3.5
ProjectileFire.Parent = Projectile

local AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0.0, Projectile:GetMass() * 196.1, 0.0)
AntiGrav.Parent = Projectile

Projectile.Velocity = Torso.CFrame.lookVector.unit * 50
connection = Projectile.Touched:connect(projectileBlow)
for i = 1, 30 do
	print(connection)
	wait(1)
end

Projectile:Remove()
script:Remove()