local Tool = script.Parent
local myCharacter = Tool.Parent
if not myCharacter then script:Remove() end
local myHumanoid = myCharacter:FindFirstChild("Humanoid")
local Torso = myCharacter:FindFirstChild("Torso")
if not (myHumanoid and Torso) then script:Remove() end

local myPlayer

local debris = game:GetService("Debris")

local PoisonBall = Instance.new("Part")
PoisonBall.Shape = Enum.PartType.Ball
PoisonBall.BrickColor = BrickColor.new("Earth green")
PoisonBall.Size = Vector3.new(3, 3, 3)
PoisonBall.Material = "Concrete"
PoisonBall.Locked = true
PoisonBall.CanCollide = false
PoisonBall.Name = "WizardWandPoisonBall"
PoisonBall.Parent = game.Workspace
PoisonBall.CFrame = Torso.CFrame
PoisonBall.Velocity = 100 * (myHumanoid.TargetPoint - Torso.Position).unit

local AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0, 196.2 * PoisonBall:GetMass(), 0)
AntiGrav.Parent = PoisonBall

local PoisonFire = Instance.new("Fire")
PoisonFire.Color = Color3.new(75/255, 0, 130/255)
PoisonFire.SecondaryColor = Color3.new(75/255, 0, 130/255)
PoisonFire.Size = 6
PoisonFire.Heat = 10
PoisonFire.Parent = PoisonBall

function tagAndUntagHumanoid(humanoid, player)
	local Tag = Instance.new("ObjectValue")
	Tag.Name = "creator"
	Tag.Value = player
	Tag.Parent = humanoid
	debris:AddItem(Tag, 17)	--Extra time to include the time-based poison damage.
end

function poisonBlow(hit)
	local hitThing = hit.Parent
	if (hitThing == myCharacter) or (hitThing == Tool)
           or (hitThing.ClassName == "Hat" and hitThing.Parent == myCharacter)
           or (hit.Name == "Wizard Wand Tip") then return end
	-- Don't poison the same part twice at the same time:
	if hit:FindFirstChild("WizardWandPoisoned") then return end
	local hitHumanoid = hitThing:FindFirstChild("Humanoid")
	if hitHumanoid then
		myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
		if myPlayer then
			tagAndUntagHumanoid(hitHumanoid, myPlayer)
		end
		local PoisonedScript = script:FindFirstChild("WizardWandPoisoned")
		if PoisonedScript then
			PoisonedScript = PoisonedScript:Clone()
			PoisonedScript.Parent = hit
			PoisonedScript.Disabled = false
		end
	end
end

PoisonBall.Touched:connect(poisonBlow)

wait(10)
PoisonBall:Remove()
wait(5)
script:Remove()