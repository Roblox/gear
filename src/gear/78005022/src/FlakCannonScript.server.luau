-- by QuantumSama
-- click once to fire, again to detonate
-- its flak not flack.  

local ReloadTime = 5
local inbetweenTime = .07
local missileSpeed = 70.0  --The slower this is the easier it is to aim and thus the more powerful it is

local Tool = script.Parent
local Launcher = Tool.Handle

local Rocket = Instance.new("Part")
Rocket.BackSurface = 3
Rocket.BottomSurface = 3
Rocket.FrontSurface = 3
Rocket.LeftSurface = 3
Rocket.RightSurface = 3
Rocket.TopSurface = 3
Rocket.Size = Vector3.new(1, 1, 1)
Rocket.Shape = "Ball"
Rocket.BrickColor = BrickColor.new(23)
Rocket.Locked = true

--local rocketMesh = Instance.new("SpecialMesh")
--rocketMesh.MeshId = "http://www.roblox.com/asset/?id=31601976"
--rocketMesh.TextureId = "http://www.roblox.com/asset/?id=31601599"
--rocketMesh.Parent = Rocket

local debris = game:GetService("Debris")

local swooshSound
local explosionSound

local vCharacter
local vPlayer
local userGui

function blow(hit, missile)
	if missile  == nil then return end
	if swooshSound then swooshSound:stop() end
	explosion = Instance.new("Explosion")
	explosion.Position = missile.Position
	explosion.BlastPressure = 1200000
	explosion.BlastRadius = 7
	-- find instigator tag
	local creator = missile:FindFirstChild("creator")
	explosion.Hit:connect(function(part, distance) onPlayerBlownUp(part, distance, creator) end)
	explosion.Parent = game.Workspace	
	if explosionSound then explosionSound:Play() end
	--wait(.1)
	--if missile then missile:Remove() end
end

function onPlayerBlownUp(part, distance, creator)
	if part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" then	
		local humanoid = part.Parent.Humanoid
		tagHumanoid(humanoid, creator)
	end
end

function tagHumanoid(humanoid, creator)
	-- tag does not need to expire if all explosions lethal	
	if creator ~= nil then
		local new_tag = creator:clone()
		new_tag.Parent = humanoid		
	end
end

local hasMissiles = false
local numMissiles = 7
local missiles = {}

function triggerMissiles()
	if not hasMissiles then return end
	hasMissiles = false
	for j = 1, numMissiles do
		if missiles[j] ~= nil then
			blow(nil, missiles[j])
			wait(inbetweenTime)
		end
	end
	wait(.1)
	for k = 1, numMissiles do
		if missiles[k] ~= nil then missiles[k]:Destroy() end
	end

end

function fire(vTarget)
	local vCharacter = Tool.Parent	
	local vHandle = Tool:findFirstChild("Handle")
	if vHandle == nil then
		print("Handle not found")
		return 
	end
	local direction = vTarget - vHandle.Position
	direction = direction.unit
	local unitOffsetVec = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5)
	while true do
		unitOffsetVec = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5)
		unitOffsetVec = direction:Cross(unitOffsetVec)
		unitOffsetVec = unitOffsetVec.unit
		if unitOffsetVec.magnitude > 0 then break end
		wait()
	end

	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)


	for i = 1, numMissiles do
		local missile = Rocket:clone()
		missiles[i] = missile
		local offsetVec = CFrame.fromAxisAngle(direction, 2* math.pi *i /(numMissiles - 1)) * unitOffsetVec
		if i == 1 then offsetVec = Vector3.new(0,0,0) end
		offsetVec = offsetVec * 1.5 + Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5)/2
		local pos = vHandle.Position + (direction * 5.0) + offsetVec
		missile.CFrame = CFrame.new(pos,  pos + direction) * CFrame.Angles(math.pi/2, 0, 0)

		local creator_tag = Instance.new("ObjectValue")

		if vPlayer == nil then
			print("Player not found")
		else
			if (vPlayer.Neutral == false) then -- nice touch
				missile.BrickColor = vPlayer.TeamColor
			end
		end

		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, missile:GetMass() * workspace.Gravity, 0.0)
		floatForce.Parent = missile

		missile.Velocity = (direction + offsetVec * 0.15) * missileSpeed

		creator_tag.Value = vPlayer
		creator_tag.Name = "creator"
		creator_tag.Parent = missile	

		missile.Parent = game.Workspace

		if swooshSound then swooshSound:Play() end

	end
	hasMissiles = true
	local torso = vCharacter:findFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	local offset = direction * Vector3.new(-1.5,0,-1.5)
	if torso ~=  nil then
		torso.CFrame = torso.CFrame +  offset  --knockback
	end
	local fuseTime = Tool.Fuse.Value 
	local fuseGui = userGui.Background.Fuse
	while fuseTime > 2 do   
		fuseTime = fuseTime - 1
		fuseGui.Size = UDim2.new(0,fuseTime,0,20)
		wait(1/40)
	end
	Tool.Fuse.Value = -1
	triggerMissiles()
	fuseGui.Size = UDim2.new(0,0,0,20)
	wait(ReloadTime)
	--for j = 1, numMissiles do
	--	if missiles[j] ~= nil then missiles[j]:Destroy() end
	--end
	--hasMissiles = false
	Tool.Enabled = true
	fuseGui.Size = UDim2.new(0,100,0,20)
end

Tool.Enabled = true
function onActivated()
	if Tool.Fuse.Value == -1 then return end
	--if not Tool.Enabled then
	--	triggerMissiles()
	--	return
	--end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	swooshSound = Launcher:FindFirstChild("Swoosh")
	explosionSound = Launcher:FindFirstChild("Explosion")

	local targetPos = humanoid.TargetPoint

	fire(targetPos)

	wait(7)


end

function onEquipped()
	userGui = Tool.UserGui:Clone()
	vPlayer = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if vPlayer ~= nil then userGui.Parent = vPlayer.PlayerGui end
end

function onUnequipped()
	print("Tool unequipped, clean up...")
	if userGui ~= nil then userGui:Destroy() end
end

--script.Parent.Activated:connect(onActivated)
Tool.Fuse.Changed:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
