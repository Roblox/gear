local Tool = script.Parent
local Handle = Tool.Handle

local InitRotVel
local InitVel

local myCharacter = Tool.Parent
local myHumanoid
local myPlayer

local Target = Tool:FindFirstChild("TargetPos")
if Target then
	Target = Target.Value
else
	if myCharacter then
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		if myHumanoid then
			Target = myHumanoid.TargetPoint
		end
	end
end

if not Target then script:Remove() end

local daggerReturning = false
local ctr = 0

local debris = game:GetService("Debris")

local Dagger = Handle:Clone()
Dagger.Transparency = 0.0
Dagger.CFrame = Handle.CFrame
local DaggerPos = Dagger.Position
local VelVector = Target - Dagger.Position
InitVel = 100 * VelVector.unit
Dagger.Velocity = InitVel
InitRotVel = 20 * Dagger.CFrame.lookVector
Dagger.RotVelocity = InitRotVel
Dagger.Name = "BoomerangDaggerProjectile"

local Fire = Handle:FindFirstChild("Fire")
if Fire then Fire.Enabled = false end
Handle.Transparency = 1.0

local AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0, 196.2 * Dagger:GetMass(), 0)
AntiGrav.Parent = Dagger

local WhipSound
local ThudSound
local soundCo

Dagger.Parent = game.Workspace

Tool.Unequipped:connect(function()
	if ThudSound then ThudSound:Stop() end
	Dagger:Remove()
	script:Remove()
end)

function tagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = player
	CreatorTag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if not humanoid then return end
	local Tag = humanoid:FindFirstChild("creator")
	if Tag then Tag:Remove() end
end

function blow(hit)
	if hit:FindFirstChild("BoomerangDaggerRecentlyHit") then
		return
	else
		local DebounceTag = Instance.new("BoolValue")
		DebounceTag.Name = "BoomerangDaggerRecentlyHit"
		DebounceTag.Parent = hit
		debris:AddItem(DebounceTag, 0.3)

		local hitThing = hit.Parent
		if not hitThing then return end
		if hitThing.ClassName == "Hat" then hitThing = hitThing.Parent end
		
		local myCharacter = Tool.Parent
		if not myCharacter then return end
		
		local hitHumanoid = hitThing:FindFirstChild("Humanoid")
		if hitThing ~= myCharacter and hitHumanoid ~= nil then
			myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
			tagHumanoid(hitHumanoid, myPlayer)
			hitHumanoid:TakeDamage(12)
			wait(1)
			untagHumanoid(hitHumanoid)
		elseif hitThing == Tool and daggerReturning then
			Dagger:Remove()
			wait()	-- To avoid an error
			Dagger = nil
		end
	end
end

function manageSound()
	WhipSound = Dagger:FindFirstChild("WhipSound")
	if WhipSound then
		WhipSound:Play()
		wait(5/30)
		WhipSound:Play()
		wait(7/30)
		WhipSound:Play()
		wait(10/30)
		WhipSound:Play()
		wait(17/30)
		WhipSound:Play()
		wait(17/30)
		if Dagger then
			WhipSound:Play()
			wait(10/30)
		end
		if Dagger then
			WhipSound:Play()
			wait(7/30)
		end
		while Dagger do
			WhipSound:Play()
			wait(5/30)
		end
	end
end

soundCo = coroutine.create(manageSound)
coroutine.resume(soundCo)

Dagger.Touched:connect(blow)

for i = 50, 0, -1 do
	Dagger.Velocity = i/50 * InitVel
	Dagger.RotVelocity = i/50 * InitRotVel
	wait()
end

daggerReturning = true

	

while Handle and Dagger do
	Dagger.Velocity = 2 * ctr * (Handle.Position - Dagger.Position).unit
	Dagger.RotVelocity = -ctr/50 * InitRotVel
	ctr = ctr + 1
	wait()
end

Tool.Enabled = true
Handle.Transparency = 0.0
if Fire then Fire.Enabled = true end
ThudSound = Handle:FindFirstChild("ThudSound")
if ThudSound then ThudSound:Play() end

wait(0.3)	-- (for sound to finish)
script:Remove()