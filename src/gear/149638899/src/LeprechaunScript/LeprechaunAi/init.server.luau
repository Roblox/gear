--Made by Luckymaxer

-----------------
--| Constants |--
-----------------

THROWABLE_DAMAGE = 15
THROWABLE_CHANCE = 0.05
THROWABLE_TIMETOLIVE = 15

ONE_STEP = 1 / 30

--------------------
--| WaitForChild |--
--------------------

-----------------
--| Variables |--
-----------------

Debris = Game:GetService("Debris")
Players = Game:GetService("Players")

ThrowSound = script:WaitForChild("Throw")
SwooshSound = script:WaitForChild("Swoosh")
SmackSound = script:WaitForChild("Smack")

Pet = script.Parent
PetHumanoid = Pet:WaitForChild("Humanoid")
Throwable = Pet:WaitForChild("Throwable")

CreatorTag = script:WaitForChild("creator")

MyPlayer = CreatorTag.Value
MyModel = MyPlayer.Character
MyHumanoid = MyModel.Humanoid

LastThrowTime = 0

-----------------
--| Functions |--
-----------------

-- Returns the closest living Humanoid to position who isn"t in excludeList
function FindClosestHumanoid(position, excludeList) -- (Vector3, table)
	if not position then print("Need a Vector3 position") return nil end

	-- Change list values to keys so we can use indexing
	local excludeSet = {}
	if excludeList and type(excludeList) == "table" then
		for _, l in ipairs(excludeList) do
			excludeSet[l] = true
		end
	end

	-- Search through Workspace children
	local closestHumanoid = nil
	for _, child in pairs(Game.Workspace:GetChildren()) do
		if (child and child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and not excludeSet[child.Humanoid])
		and (not closestHumanoid or (child.Humanoid.Torso.Position - position).magnitude < (closestHumanoid.Torso.Position - position).magnitude) then
			closestHumanoid = child.Humanoid
		end
	end
	return closestHumanoid --NOTE: Can be nil
end

-- Removes any old creator tags and applies new ones to the specified target
function ApplyTags(target)
	while target:FindFirstChild("creator") do
		target.creator:Destroy()
	end
	local creatorTag = CreatorTag:Clone()
	Debris:AddItem(creatorTag, 4)
	creatorTag.Parent = target
end

function OnThrowableReachedTarget(throwable, targetHumanoid)
	local smackSound = throwable:FindFirstChild("Smack")
	if smackSound then
		smackSound:Play()
	end
	if targetHumanoid.Health > 0 then
		ApplyTags(targetHumanoid)
		targetHumanoid:TakeDamage(THROWABLE_DAMAGE)
	end
	local CoinRadius = 5
	for i = 1, math.random(1, 5) do
		local Coin = Instance.new("Part")
		Coin.Material = Enum.Material.SmoothPlastic
		Coin.FormFactor = Enum.FormFactor.Custom
		Coin.TopSurface = Enum.SurfaceType.Smooth
		Coin.BottomSurface = Enum.SurfaceType.Smooth
		Coin.Size = Vector3.new(1, 0.4, 1)
		Coin.Name = "Coin"
		Coin.Anchored = false
		Coin.CanCollide = true
		Coin.Locked = true
		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshType = Enum.MeshType.FileMesh
		Mesh.MeshId = "http://www.roblox.com/asset/?id=149636787"
		Mesh.TextureId = "http://www.roblox.com/asset/?id=19059111"
		Mesh.Scale = Vector3.new(1, 1, 1)
		Mesh.Parent = Coin
		Debris:AddItem(Coin, 10)
		Coin.Parent = game:GetService("Workspace")
		Coin.CFrame = CFrame.new((throwable.Position.X + math.random(-CoinRadius, CoinRadius)), (throwable.Position.Y + math.random(0, CoinRadius)), (throwable.Position.Z + math.random(-CoinRadius, CoinRadius)))
	end
	throwable:Destroy()
end

function PickNewTarget(throwable)
	local homing = throwable:FindFirstChild("Homing")
	if homing then
		local targetHumanoid = FindClosestHumanoid(throwable.Position, {MyHumanoid, PetHumanoid})
		if targetHumanoid and targetHumanoid.Torso then
			local targetHead = targetHumanoid.Parent:FindFirstChild("Head")
			homing.Target = targetHead or targetHumanoid.Torso
			return
		end
		-- Otherwise, fall
		homing:Destroy()
	end
	-- Fall to kill plane
	throwable.CanCollide = false
end

-- Change target when the old target disappears
function OnTargetModelChanged(targetModel, property, throwable)
	if property == "Parent" and targetModel.Parent == nil then
		PickNewTarget(throwable)
	end
end

--------------------
--| Script Logic |--
--------------------

ThrowSound.Parent = Throwable --NOTE: To be played from hand
SwooshSound.Parent = Throwable --NOTE: To be played from projectile
SmackSound.Parent = Throwable --NOTE: To be played from projectile on hit

PetHumanoid.Health = PetHumanoid.MaxHealth -- This never works
Delay(1, function() PetHumanoid.Health = PetHumanoid.Health + 1 end) -- So at least trigger healing

MyHumanoid.Died:connect(function()
	MyHumanoid = nil
end)

Players.PlayerRemoving:connect(function(player)
	if player == MyPlayer then
		MyHumanoid = nil
	end
end)

while PetHumanoid and MyHumanoid and MyHumanoid.Health > 0 do
	local torso = MyHumanoid.Torso
	PetHumanoid:MoveTo(torso.Position + Vector3.new(-4, 0, -4), torso)

	local now = tick()
	if now - LastThrowTime > 0.5 and math.random() <= THROWABLE_CHANCE then
		--print("Throw")
		LastThrowTime = now
		local targetHumanoid = FindClosestHumanoid(torso.Position, {MyHumanoid, PetHumanoid})
		if targetHumanoid and targetHumanoid.Torso then
			local targetModel = targetHumanoid.Parent
			local targetHead = targetModel:FindFirstChild("Head")
			Spawn(function()
				ThrowSound:Play()
				local throwable = Throwable:Clone()
				throwable.Name = "HomingTurkey"
				local homing = Instance.new("RocketPropulsion")
				homing.Name = "Homing"
				homing.Target = targetHead or targetHumanoid.Torso
				homing.ReachedTarget:connect(function()
					OnThrowableReachedTarget(throwable, targetHumanoid)
				end)
				targetModel.Changed:connect(function(property)
					OnTargetModelChanged(targetModel, property, throwable)
				end)
				homing.Parent = throwable
				Debris:AddItem(throwable, THROWABLE_TIMETOLIVE)
				throwable.Parent = Workspace
				throwable.Velocity = Vector3.new(0, 100, 0)
				wait(0.5)
				if throwable then
					local projectileSwoosh = throwable:FindFirstChild("Swoosh")
					if projectileSwoosh then
						projectileSwoosh:Play()
					end
					throwable.Size = Vector3.new(0.5, 1, 0.5)
					throwable.CanCollide = true
					homing:Fire()
				end
			end)
		end
	end
	wait(ONE_STEP)
end

Debris:AddItem(Pet, 0)
