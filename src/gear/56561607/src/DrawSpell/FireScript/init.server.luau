local Tool = script.Parent
local myCharacter = Tool.Parent
if not myCharacter then script:Remove() end
local Torso = myCharacter:FindFirstChild("Torso")
local myHumanoid = myCharacter:FindFirstChild("Humanoid")
if not (Torso and myHumanoid) then script:Remove() end

local myPlayer

local debris = game:GetService("Debris")

function tagAndUntagHumanoid(humanoid, player)
	local Tag = Instance.new("ObjectValue")
	Tag.Name = "creator"
	Tag.Value = player
	Tag.Parent = humanoid
	debris:AddItem(Tag, 8)	-- Extra time to include time-based fire damage.
end

-- Again, multiple triggers are an issue -> basic debounce.
function fireBlow(hit)
	if hit:FindFirstChild("WizardWandFireHit") then return end
	local hitThing = hit.Parent
	if (hitThing == myCharacter)then return end
	if (hitThing.ClassName == "Hat" or hitThing.ClassName == "Tool") and hitThing.Parent == myCharacter then return end
	if hit.Name == "Wizard Wand Tip" then return end

	local HitRegisterer = Instance.new("BoolValue")
	HitRegisterer.Name = "WizardWandFireHit"
	HitRegisterer.Parent = hit
	debris:AddItem(HitRegisterer, 0.2)

	local hitHumanoid = hitThing:FindFirstChild("Humanoid")
	if hitHumanoid then
		myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
		if myPlayer then
			tagAndUntagHumanoid(hitHumanoid, myPlayer)
			hitHumanoid:TakeDamage(10)
		end
	end
	local HitFireScript = script:FindFirstChild("LitOnFire")
	if HitFireScript then
		HitFireScript = HitFireScript:Clone()
		HitFireScript.Parent = hit
		HitFireScript.Disabled = false
	end
end

local FlamingPart = Instance.new("Part")
FlamingPart.Shape = Enum.PartType.Ball
FlamingPart.Size = Vector3.new(5, 5, 5)
FlamingPart.CanCollide = false
FlamingPart.Transparency = 1.0
FlamingPart.Locked = true
FlamingPart.CFrame = Torso.CFrame
FlamingPart.Velocity = 100 * (myHumanoid.TargetPoint - Torso.Position).unit
FlamingPart.Name = "WizardWandFireball"
FlamingPart.Parent = game.Workspace

local AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0, 196.2 * FlamingPart:GetMass(), 0)
AntiGrav.Parent = FlamingPart

local Fire = Instance.new("Fire")
Fire.Size = 20
Fire.Heat = 20
Fire.Parent = FlamingPart

FlamingPart.Touched:connect(fireBlow)

wait(10)
FlamingPart:Remove()
script:Remove()