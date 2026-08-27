--Made by Luckymaxer

Debris = Game:GetService("Debris")
Players = Game:GetService("Players")

Tool = script.Parent
Handle = Tool:FindFirstChild("Handle")

Tool.Enabled = true
Handle.Transparency = 0

Music = Handle:WaitForChild("Music")
MeteorBassDropScript = script:WaitForChild("MeteorBassDropScript")
BassDrop = Tool:WaitForChild("BassDrop")

COOLDOWN_TIME = 35
LAUNCH_DISTANCE = 200

LastActivation = 0

PossibleIncomingVectors = {}

-- Create table of possible incoming vectors
for x = -1, 1 do
	for z = -1, 1 do
		table.insert(PossibleIncomingVectors, Vector3.new(x, 1, z).unit)
	end
end

function GetRandomFloat(minimum, maximum)
	local unitRandom = math.random()
	local interval = maximum - minimum
	-- there is potential overflow here if the interval is larger than max float
	if interval <= 0 then
		print("GetRandomFloat: The range beween minimum and maximum is less than zero.")
		return nil
	end
	local randomNum = (unitRandom * interval) + minimum
	return randomNum
end

function RandomPointInCircle(minRadius, maxRadius)
	local outwardVector = Vector3.new(0,0,GetRandomFloat(minRadius, maxRadius))
	local rotation = math.random() * math.pi * 2
	return CFrame.Angles(0, rotation, 0) * outwardVector	
end

function RayIgnoreCheck(hit)
	if hit then
		if hit.Transparency >= 1 or string.lower(hit.Name) == "water" or
				hit.Name == "Effect" or hit.Name == "Rocket" or hit.Name == "Bullet" or
				hit.Name == "Handle" then
			return true
		end
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
function RayCast(startPos, vec, rayLength)
	local hitObject, hitPos = game.Workspace:FindPartOnRay(Ray.new(startPos + (vec * .01), vec * rayLength), Handle)
	if hitObject and hitPos then
		local distance = rayLength - (hitPos - startPos).magnitude
		if RayIgnoreCheck(hitObject) and distance > 0 then
			-- there is a chance here for potential infinite recursion
			return RayCast(hitPos, vec, distance)
		end
	end
	return hitObject, hitPos
end

local function FindTargetSpot()
	return Workspace:FindFirstChild("TargetSpot")
end

local function FindOptimalLaunchVector(destination)
	local bestDist = 0
	local bestVec = Vector3.new(0, 1, 0)
	local bestPos = destination + bestVec
	for k, v in pairs(PossibleIncomingVectors) do
		local hitObject, hitPos = RayCast(destination, v, LAUNCH_DISTANCE)
		if (hitPos - destination).magnitude > bestDist then
			bestVec = v
			bestDist = (hitPos - destination).magnitude
			bestPos = hitPos
		end
	end
	return bestVec, bestPos, bestDist
end



function onActivated()
	if tick() - LastActivation > COOLDOWN_TIME then
		Tool.Enabled = false
		LastActivation = tick()
		if MyTorso then
			BassDropAnim = MyHumanoid:LoadAnimation(BassDrop)
			BassDropAnim.KeyframeReached:connect(function()
				local newBassDrop = Handle:Clone()
				newBassDrop.CanCollide = true
				local fire = Instance.new("Fire")
				fire.Enabled = true
				fire.Heat = 14
				fire.Parent = newBassDrop
				local offset = MyTorso.CFrame.lookVector * 1.5
				newBassDrop.CFrame = CFrame.new(MyTorso.CFrame.p + offset, MyTorso.CFrame.p)
				newBassDrop.Parent = game:GetService("Workspace")
				Debris:AddItem(newBassDrop, COOLDOWN_TIME - 1)
				Handle.Transparency = 1
				delay(COOLDOWN_TIME - 1, function() Handle.Transparency = 0 Tool.Enabled = true end)
				wait(2)
				if newBassDrop:FindFirstChild("Music") then
					newBassDrop.Music:Play()
				end
				for i = 1, 14 do
					fire.Enabled = true
					fire.Size = 3 + i
					local BassDropOffset = RandomPointInCircle(20, 100)
					if i == 14 then -- hard-code last one to hit you
						BassDropOffset = Vector3.new()
					end
					local meteorBassDrop = Handle:Clone()
					meteorBassDrop.Transparency = 0
					meteorBassDrop.Size = Vector3.new(3, 4, 1.5)
					meteorBassDrop.Mesh.Scale = Vector3.new(2, 2, 2)
					local creator = Instance.new("ObjectValue")
					creator.Name = "creator"
					creator.Value = MyPlayer
					creator.Parent = meteorBassDrop
					local meteorFire = Instance.new("Fire")
					local newScript = MeteorBassDropScript:Clone()
					meteorFire.Heat = 20
					meteorFire.Size = 18
					meteorFire.Parent = meteorBassDrop
					meteorBassDrop.Parent = Workspace
					local targetPoint = Instance.new("Part")
					targetPoint.Transparency = 1
					targetPoint.CanCollide = false
					targetPoint.Anchored = true
					targetPoint.CFrame = CFrame.new(BassDropOffset) + MyTorso.CFrame.p
					Debris:AddItem(targetPoint, 30)
					Debris:AddItem(meteorBassDrop, 30)
					local BassDropPropulsion = Instance.new("RocketPropulsion")
					BassDropPropulsion.Target = targetPoint
					BassDropPropulsion.MaxThrust = 100000
					BassDropPropulsion.MaxSpeed = 40
					BassDropPropulsion.Parent = meteorBassDrop
					targetPoint.Parent = Workspace
					local bestVec, bestPos, bestDist = FindOptimalLaunchVector(targetPoint.CFrame.p)
					meteorBassDrop.CFrame = CFrame.new(bestPos)
					BassDropPropulsion:Fire()
					newScript.Parent = meteorBassDrop
					newScript.Disabled = false
					wait(2)
				end
				wait(3)
				newBassDrop:Destroy()
			end)
			BassDropAnim:Play(0.5)
		end
	end
end

function onEquipped()
	MyCharacter = Tool.Parent
	MyPlayer = MyCharacter and Players:GetPlayerFromCharacter(MyCharacter)
	MyTorso = MyCharacter and MyCharacter:FindFirstChild("Torso")
	MyHumanoid = MyCharacter and MyCharacter:FindFirstChild("Humanoid")
end
	
function onUnequipped()
	if BassDropAnim then
		BassDropAnim:Stop()
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

