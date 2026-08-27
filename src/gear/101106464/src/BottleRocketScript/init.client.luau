-- Made By SolarCrane


-- Not sure if we want to get content url from roblox function?
local ICON_URL = 'http://www.roblox.com/asset/?id=100856058'
local BOTTLE_MESH_URL = 'http://www.roblox.com/asset/?id=100856357'
--local ROCKET_MESH_URL = 'http://www.roblox.com/asset/?id=100856397'
local ROCKET_MESH_URL = 'http://www.roblox.com/asset/?id=101005977'
local TEXTURE_URL = 'http://www.roblox.com/asset/?id=100856280'

local NUMBER_OF_ROCKETS = 3
local ROCKET_LAUNCH_SPEED = 53
local RELOAD_TIME_PER_ROCKET = 0.9
local ROCKET_DEBRIS_TIME = 4
local PROJECTILE_NAME = 'BR_Rocket'


local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')



local BottleInstance
local Tool = script.Parent

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end


local Handle = WaitForChild(Tool, 'Handle')
local Sounds = {equip = WaitForChild(Handle, 'equipSound'),
						reload = WaitForChild(Handle, 'singleReload'),
						explode = WaitForChild(Handle, 'explodeSound'),
						launch = WaitForChild(Handle, 'launchSound')
						}


local Animations = {['EndReload'] = WaitForChild(Tool, 'EndReload'),
								['FireAnim'] = WaitForChild(Tool, 'FireAnim'),
								['ReloadLoop'] = WaitForChild(Tool, 'ReloadLoop'),
								['StartReload'] = WaitForChild(Tool, 'StartReload'),
								['StopFire'] = WaitForChild(Tool, 'StopFire')
		 						}

local AnimationTracks = {}

local RocketMineScript = WaitForChild(script, 'RocketMineScript')

-- TODO: keep a list of say object pointers of rockets fired in workspace


local DEBUG_PRINT = false
function dPrint(...)
	if DEBUG_PRINT then
		print(...)
	end
end

Bottle = {}
Bottle_mt = { __index = Bottle}


function PointOnUnitCircle(angle)
	return Vector3.new(math.cos(angle), 0, math.sin(angle))
end

function CanFire()
	local character = Tool.Parent
	if character then
		local humanoid = character:FindFirstChild('Humanoid')
		local rightArm = character:FindFirstChild('Right Arm')
		if humanoid and rightArm then
			local rightGrip = rightArm:FindFirstChild('RightGrip')
			if humanoid.Health > 0 and rightGrip then
				return true
			end
		end
	end
	return false
end

function GetHumanoid()
	local character = Tool.Parent
	return character and character:FindFirstChild('Humanoid')
end

function GetTorso()
	local character = Tool.Parent
	if character then
		return character:FindFirstChild('Torso')
	end
end

function Bottle:Create()
	return setmetatable({rockets = {}, lastRocketAddedTick = tick(), lastFiredTime = tick(), inReload = false}, Bottle_mt)
end

function Bottle:OnEquipped()
	dPrint(self.rockets)
	Handle.Transparency = 0.55
	PlaySound('equip')
	for _, child in pairs(self:GetPart():GetChildren()) do
		if child.Name == PROJECTILE_NAME then
			local nextIndex = self:FirstOpenRocketIndex()
			if nextIndex then
				self.rockets[nextIndex] = Rocket:Create(child)
			end
		end
	end
	for i = 1, NUMBER_OF_ROCKETS do
		if not self.rockets[i] then
			local tempRocket = self:AddRocket(i)
			self.rockets[i] = tempRocket
		end
	end
end

function Bottle:OnUnequipped()
	local myTorso = GetTorso()
	if myTorso then
		if myTorso:FindFirstChild('spinVelocity') then
			myTorso:FindFirstChild('spinVelocity').Parent = nil
		end
	end
end

function Bottle:FirstOpenRocketIndex()
	local firstOpenIndex = nil
	for i = 1, NUMBER_OF_ROCKETS do
		if not self.rockets[i] then
			firstOpenIndex = i
			break
		end
	end
	return firstOpenIndex
end

function Bottle:OnActivated(targetOverride)
	if CanFire() then
		print("Activated")
		local numRocketsToFire = 0
		for i, rocket in pairs(self.rockets) do
			if rocket then
				numRocketsToFire = 1 --numRocketsToFire + 1
			end
		end
		if numRocketsToFire > 0 then
			print("Has rockets")
			PlayAnimation('FireAnim')
			local firedCount = 0
			--[[
			local spinVelocity = Instance.new('BodyAngularVelocity')
			spinVelocity.angularvelocity = Vector3.new(0,11,0)
			spinVelocity.maxTorque = Vector3.new(0, 400000000, 0)
			spinVelocity.P = 9000
			spinVelocity.Name = 'spinVelocity'
			local myTorso = GetTorso()
			if myTorso then
				--spinVelocity.Parent = myTorso
			end
			--]]
			
			--local waitTime = 1.3 --((math.pi*2) / spinVelocity.angularvelocity.Y) / numRocketsToFire
			for i, rocket in pairs(self.rockets) do
				if firedCount >= numRocketsToFire then break end
				--local angle = (2 * math.pi) * (firedCount / numRocketsToFire)
				--dPrint("Angle:" , angle)
				--rocket:Launch(waitTime, PointOnUnitCircle(angle))
				self.rockets[i] = nil
				rocket:LaunchTargeted(targetOverride)
				firedCount = firedCount + 1
				self.lastFiredTime = tick()
			end
			
			--spinVelocity.Parent = nil
			StopAnimation('FireAnim')
		end
		Spawn(function() self:Reload() end)
	end
end

function Bottle:GetPart()
	return script.Parent:FindFirstChild('Handle')
end

function Bottle:WeldToBottle(otherRocket, firstOpenIndex)
	local rocketPart = otherRocket:GetPart()
	local bottlePart = self:GetPart()
	if rocketPart and bottlePart then
		if not firstOpenIndex then
			firstOpenIndex = self:FirstOpenRocketIndex()
		end
		if not firstOpenIndex then
			dPrint("Bottle:WeldToBottle: No More space for rockets.")
			return
		end
		local bottleWeld = Instance.new('ManualWeld')
		bottleWeld.Part0 = bottlePart
		bottleWeld.Part1 = rocketPart
		--bottleWeld.C0 = CFrame.Angles(math.pi/2,0,0) * CFrame.Angles(0, 0, (2 * math.pi) * (firstOpenIndex / NUMBER_OF_ROCKETS)):inverse() * CFrame.Angles(0, math.pi / 18, 0) + Vector3.new(0,0.7,0)
bottleWeld.C0 = CFrame.Angles(math.pi/2, 0,0) * CFrame.Angles(0, math.pi / 20, (2 * math.pi) * (firstOpenIndex / NUMBER_OF_ROCKETS)):inverse() + Vector3.new(0,0.87,0)
		bottleWeld.C1 = CFrame.new()
		bottleWeld.Parent = rocketPart
		otherRocket.weld = bottleWeld
	else
		dPrint("Bottle:WeldToBottle called but either the bottle or the rocket's parts have not been instantiated yet.")
	end
end

function Bottle:Reload()
	if self.inReload then return end
	self.inReload = true
	wait(3.2)
	PlayAnimation('StartReload', 1)
	PlayAnimation('ReloadLoop', 1/3)
	while Tool and Tool:IsDescendantOf(Workspace) do
		local firstOpenIndex = self:FirstOpenRocketIndex()
		if not firstOpenIndex then break end
		local now = tick()
		local waitTime = math.max(0, math.max(2.3 - math.min(2.3, now - self.lastFiredTime),
											  RELOAD_TIME_PER_ROCKET))  -- math.min(RELOAD_TIME_PER_ROCKET, now - self.lastRocketAddedTick)))
		print(waitTime)
		wait(waitTime)
		PlaySound('reload')
		local tempRocket = self:AddRocket(firstOpenIndex)
		self.rockets[firstOpenIndex] = tempRocket
		self.lastRocketAddedTick = now
		StopAnimation('StartReload')
	end
	StopAnimation('StartReload')
	StopAnimation('ReloadLoop')
	PlayAnimation('EndReload')
	self.inReload = false
end

function Bottle:AddRocket(index)
	local newRocket = Rocket:Create()
	newRocket:MakeRocket()
	self:WeldToBottle(newRocket, index)
	newRocket:GetPart().Parent = self:GetPart()
	return newRocket
end

Rocket = {}
Rocket_mt = { __index = Rocket}

function Rocket:Create(rocketPart)
	local newRocket = setmetatable({}, Rocket_mt)
	if rocketPart then
		newRocket.part = rocketPart
		local weld = rocketPart:FindFirstChild('ManualWeld')
		if weld then
			newRocket.weld = weld
		end
	end
	return newRocket
end

function Rocket:GetPart()
	return self.part
end

function Rocket:MakeRocket()
	local rocketPart = Instance.new('Part')
	rocketPart.TopSurface = 'Smooth'
	rocketPart.BottomSurface = 'Smooth'
	rocketPart.FormFactor = 'Custom'
	rocketPart.Size = Vector3.new(0.2, 0.2, 3.4)
	rocketPart.Locked = true
	rocketPart.CanCollide = false
	rocketPart.Name = PROJECTILE_NAME
	local rocketMesh = Instance.new('SpecialMesh')
	rocketMesh.MeshId = ROCKET_MESH_URL
	rocketMesh.TextureId = TEXTURE_URL
	rocketMesh.Parent = rocketPart
	self.part = rocketPart
	return rocketPart
end

function Rocket:CreateCreatorTag()
	local myPlayer = PlayersService:GetPlayerFromCharacter(Tool.Parent)
	if myPlayer then
		-- Attach creator tags
		local creatorTag = Instance.new('ObjectValue', rocket)
		creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
		creatorTag.Value = myPlayer
		local iconTag = Instance.new('StringValue', creatorTag)
		iconTag.Name = 'weaponIcon'
		iconTag.Value = Tool.TextureId
		local nameTag = Instance.new('StringValue', creatorTag)
		nameTag.Name = 'weaponName'
		nameTag.Value = Tool.Name
		return creatorTag
	end
end

function Rocket:LaunchTargeted(targetPosition)
	local rocketPart = self:GetPart()
	local humanoid = GetHumanoid()
	if rocketPart and humanoid then
		PlaySound('launch')
		local fire = Instance.new('Fire')
		fire.Size = 3
		fire.Heat = 5
		fire.Name = 'RocketTrail' 
		fire.Parent = rocketPart

		targetPosition = targetPosition or humanoid.TargetPoint
		dPrint("TargetPos:", targetPosition)
		--[[
		local targetPart = Instance.new('Part')
		targetPart.Transparency = 1
		targetPart.CanCollide = false
		targetPart.Anchored = true
		targetPart.FormFactor = 'Custom'
		targetPart.Size = Vector3.new()
		targetPart.CFrame = CFrame.new(targetPosition)
		targetPart.Parent = Workspace
		DebrisService:AddItem(targetPart, ROCKET_DEBRIS_TIME + 1)
		--]]
		rocketPart.Parent = Workspace
		if self.weld then
			self.weld:Destroy()
			self.weld = nil
		end

		rocketPart.Velocity = Vector3.new(0,1,0) * ROCKET_LAUNCH_SPEED * 1.8

		local rocketPropulsion = Instance.new('RocketPropulsion')
		--rocketPropulsion.Target = targetPart
		rocketPropulsion.TargetOffset = rocketPart.CFrame.p + (targetPosition - rocketPart.CFrame.p) -- .unit * 1000000000
		rocketPropulsion.CartoonFactor = 0.1
		rocketPropulsion.TurnP = 23000
		rocketPropulsion.MaxTorque = Vector3.new(1000000000, 100000000, 100000000)
		rocketPropulsion.MaxSpeed = ROCKET_LAUNCH_SPEED
		rocketPropulsion.Parent = rocketPart

		DebrisService:AddItem(rocketPart, ROCKET_DEBRIS_TIME)

		local rocketScriptClone = RocketMineScript:Clone()
		rocketScriptClone.Parent = rocketPart
		rocketScriptClone.Disabled = false


		local tag = self:CreateCreatorTag()
		if tag then
			tag.Parent = rocketPart
		else
			dPrint("Was unable to make creator tag in MakeRocket")
		end
		if Sounds['explode'] then
			Sounds['explode']:Clone().Parent = rocketPart
		end

		wait(0.3)
		rocketPropulsion.TargetOffset = rocketPart.CFrame.p + (targetPosition - rocketPart.CFrame.p).unit * 1000000000
		rocketPropulsion:Fire()
	end
end

function Rocket:Launch(launchTime, direction)
	local rocketPart = self:GetPart()
	if rocketPart then
		DebrisService:AddItem(rocketPart, ROCKET_DEBRIS_TIME)
		rocketPart.Parent = Workspace
		local fire = Instance.new('Fire')
		fire.Size = 3
		fire.Heat = 5
		fire.Name = 'RocketTrail' 
		fire.Parent = rocketPart
		--[[
		local smoke = Instance.new('Smoke')
		smoke.Size = 0.1
		smoke.Opacity = 0.3
		smoke.RiseVelocity = 0
		smoke.Parent = rocketPart
		local sparkles = Instance.new('Sparkles')
		sparkles.SparkleColor = Color3.new(222,33,15)
		]]
		wait(launchTime)
		if self.weld then
			self.weld:Destroy()
			self.weld = nil
		end

		--rocketPart.Velocity = rocketPart.CFrame:vectorToWorldSpace(Vector3.new(0, ROCKET_LAUNCH_SPEED, 0))
		local originalCFrame = rocketPart.CFrame
		rocketPart.Size = Vector3.new(5, rocketPart.Size.Y, rocketPart.Size.Z)
		local floatForce = Instance.new('BodyForce')
		floatForce.force = Vector3.new(0, rocketPart:GetMass() * 196.2 / 1.13, 0)
		floatForce.Parent = rocketPart
		rocketPart.Velocity = direction.unit * ROCKET_LAUNCH_SPEED
		rocketPart.RotVelocity = Vector3.new()
		rocketPart.CFrame = CFrame.new(originalCFrame.p, originalCFrame.p + direction.unit) * CFrame.Angles(-math.pi / 2 , 0, 0)
		dPrint("Shooting at:" , direction.unit)
		--[[
		local myTorso = GetTorso()
		if myTorso then
			rocketPart.Velocity = myTorso.CFrame.lookVector * ROCKET_LAUNCH_SPEED
		else
			dPrint("Rocket Launch, no torso found.")
			rocketPart.Velocity = Vector3.new(0,0, ROCKET_LAUNCH_SPEED)
		end
]]
		
		local tag = self:CreateCreatorTag()
		if tag then
			tag.Parent = rocketPart
		else
			dPrint("Was unable to make creator tag in MakeRocket")
		end
		
		local rocketScriptClone = RocketMineScript:Clone()
		rocketScriptClone.Parent = rocketPart
		rocketScriptClone.Disabled = false
	end
end

function PlaySound(soundName, volume)
	local sound = Sounds[soundName]
	if sound then
		if volume then
			sound.Volume = volume
		end
		sound:Play()
	end
end


function PlayAnimation(animName, animSpeed)
	local animTrack = AnimationTracks[animName]
	if animTrack then
		animTrack:Play()
	end
	if animSpeed then
		animTrack:AdjustSpeed(animSpeed)
	end
end

function StopAnimation(animName)
	local animTrack = AnimationTracks[animName]
	if animTrack then
		animTrack:Stop()
	end
end

function LoadAnimationTracks()
	local myHumanoid = GetHumanoid()
	if myHumanoid then
		for animName, animObject in pairs(Animations) do
			AnimationTracks[animName] = myHumanoid:LoadAnimation(animObject)
		end
	end
end

function StopAllAnimations()
	for animName, animTrack in pairs(AnimationTracks) do
		StopAnimation(animName)
	end
end

-- Also activate when the Action Button is pressed
local function OnChildAdded(child)
	if child.Name == 'ActionButtonData' then
		child.Changed:connect(function(newValue)
			local bindable = child:FindFirstChild('GetTargetPosition')
			if bindable and string.sub(newValue, 1, 1) == 'v' then
				local matches = {}
				for match in string.gmatch(newValue, '%d+%.?%d*') do
					table.insert(matches, match)
				end
				if #matches == 4 then
					local screenPosition = Vector2.new(matches[1], matches[2])
					local screenSize = Vector2.new(matches[3], matches[4])
					local targetPosition = bindable:Invoke(screenPosition, screenSize, {Tool.Parent})
					BottleInstance:OnActivated(targetPosition)
				end
			end
		end)
	end
end

BottleInstance = Bottle:Create()

dPrint(BottleInstance.rockets)

Tool.Equipped:connect(function() LoadAnimationTracks() BottleInstance:OnEquipped() end)
Tool.Unequipped:connect(function() BottleInstance:OnUnequipped() StopAllAnimations() end)
Tool.Activated:connect(
	function()
		wait() -- iPad derp, doesn't update targetpoint
		BottleInstance:OnActivated()
	end)
Tool.ChildAdded:connect(OnChildAdded) --NOTE: Added for Action Button
