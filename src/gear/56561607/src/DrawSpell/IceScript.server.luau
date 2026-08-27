local Tool = script.Parent
local myCharacter = Tool.Parent
if not myCharacter then script:Remove() end
local Torso = myCharacter:FindFirstChild("Torso")
local myHumanoid = myCharacter:FindFirstChild("Humanoid")
if not (Torso and myHumanoid) then script:Remove() end

local myPlayer

local debris = game:GetService("Debris")

local IceBall = Instance.new("Part")
IceBall.Shape = Enum.PartType.Ball
IceBall.Material = "Ice"
IceBall.BrickColor = BrickColor.new("Pastel blue-green")
IceBall.Size = Vector3.new(3, 3, 3)
IceBall.Locked = true
IceBall.CanCollide = false
IceBall.Name = "WizardWandIceBall"
IceBall.Parent = game.Workspace
IceBall.CFrame = Torso.CFrame
IceBall.Velocity = 100 * (myHumanoid.TargetPoint - Torso.Position).unit

local AntiGrav = Instance.new("BodyForce")
AntiGrav.force = Vector3.new(0, 196.2 * IceBall:GetMass(), 0)
AntiGrav.Parent = IceBall

local IceFire = Instance.new("Fire")
IceFire.Color = IceBall.BrickColor.Color
IceFire.SecondaryColor = Color3.new(1, 1, 1)
IceFire.Size = 6
IceFire.Heat = 10
IceFire.Parent = IceBall

function tagAndUntagHumanoid(humanoid, player)
	local Tag = Instance.new("ObjectValue")
	Tag.Name = "creator"
	Tag.Value = player
	Tag.Parent = humanoid
	debris:AddItem(Tag, 1)
end

-- Some issues with multiple triggers on this one, so some basic debouncing included
function iceBlow(hit)
	if hit:FindFirstChild("WizardWandIceHit") then return end
	print(hit.Name)
   local hitThing = hit.Parent
   -- Checks to make sure the ice only affects things that aren't us
   --   or attached to us.
   if (hitThing == myCharacter) or (hitThing == Tool)
           or (hitThing.ClassName == "Hat" and hitThing.Parent == myCharacter)
           or (hit.Name == "Wizard Wand Tip") then return end

	-- Add a BoolValue for debounce purposes
	local HitRegisterer = Instance.new("BoolValue")
	HitRegisterer.Name = "WizardWandIceHit"
	HitRegisterer.Parent = hit
	debris:AddItem(HitRegisterer, 0.2)

   -- Delete any meshes underneath the thing we hit, and turn it to ice.
	local hitChildren = hit:GetChildren()
	local meshTable = {}
	for index, instance in pairs(hitChildren) do
		local className = instance.ClassName
		if (className == "SpecialMesh" or className == "BlockMesh" or className == "CylinderMesh") then
			instance.Parent = nil
			table.insert(meshTable, instance)
		end
	end
	local oldMaterial = hit.Material
	local oldBrickColor = hit.BrickColor
	hit.Material = "Ice"
	hit.BrickColor = BrickColor.new("Pastel blue-green")

	-- Have a chance of removing the hit part if it was attached to a character -- frostbite FTL.
	local hitHumanoid = hitThing:FindFirstChild("Humanoid")
	if hitThing.ClassName == "Hat" then hitHumanoid = hitThing.Parent:FindFirstChild("Humanoid") end
	if hitHumanoid then
		if myCharacter then
			myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
			tagAndUntagHumanoid(hitHumanoid, myPlayer)
		end
		hitHumanoid:TakeDamage(10)
		if (math.random() > 0.85) then
			hitHumanoid:TakeDamage(15)
			local hitCharacter = hitHumanoid.Parent
			local hitTorso = hitCharacter:FindFirstChild("Torso")

			local MotorToRemove
			if hitThing.ClassName == "Hat" or hit.Name == "Head" or hit.Name == "Torso" then
				MotorToRemove = hitTorso:FindFirstChild("Neck")
			elseif hit.Name == "Right Arm" then
				MotorToRemove = hitTorso:FindFirstChild("Right Shoulder")
			elseif hit.Name == "Right Leg" then
				MotorToRemove = hitTorso:FindFirstChild("Right Hip")
			elseif hit.Name == "Left Arm" then
				MotorToRemove = hitTorso:FindFirstChild("Left Shoulder")
			else --[[ hit.Name == "Left Leg"]]
				MotorToRemove = hitTorso:FindFirstChild("Left Hip")
			end
			
			if MotorToRemove then 
				MotorToRemove.Parent = nil
			end
		end
	end

	-- Wait for the ice to thaw...
	wait(10)
	-- Then set things back to normal.
	if hit then
		-- We just need to check that the "old" material and color aren't those of ice, which
		--   they would be if we hit the same target twice in a row. (We don't want to accidentally
		--   freeze things forever!)
		if oldMaterial ~= hit.Material then hit.Material = oldMaterial end
		if oldBrickColor ~= hit.BrickColor then hit.BrickColor = oldBrickColor end
		for i = 1, #meshTable do
			meshTable[i].Parent = hit
		end
	end
end

IceBall.Touched:connect(iceBlow)

wait(10)
if IceBall then IceBall:Remove() end
wait(11)	-- To give the effects of iceBlow time to wear off.
script:Remove()