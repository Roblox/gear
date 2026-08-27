-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end


local EVENING_MINUTES_AFTER_MIDNIGHT = 1070
local ICON_ID = 93664760
local TEXTURE_ID = 93664784
local MESH_ID = 93664805
local URL_PREFIX = 'http://www.roblox.com/asset/?id='


local INTERVAL_BETWEEN_LIGHTNING = 5
local LIGHTNING_RADIUS = 1
local MAX_SHOOTING_DISTANCE = 100
local LIGHTNING_DAMAGE = 30

local MyCharacter
local MyLeftArm
local MyMouse

local Tool = script.Parent
local Handle 

local MolecularAtomizer

local LightingService = Game:GetService('Lighting')
local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local OriginalTime
local RevertingTimeOfDay = false

local ShootSound

local ShootTrack
local IdleTrack

local FreezeTorsoScript

local LightningPart = Instance.new("Part")
LightningPart.Name = "Lightning"
LightningPart.FormFactor = 3
LightningPart.Size = Vector3.new(1, 1, 10)
LightningPart.Anchored = true

local LightningMesh = Instance.new("SpecialMesh")
LightningMesh.Scale = Vector3.new(0.6, 0.7, 0.6)
LightningMesh.MeshId = "http://www.roblox.com/asset/?id=65419828"
LightningMesh.TextureId = "http://www.roblox.com/asset/?id=65419395"
LightningMesh.VertexColor = Vector3.new(0.6, 1, 0.85)
LightningMesh.Parent = LightningPart

local function WeldToLeftArm(object)
	if not object or not object.Name then print("Invalid object given to WeldToLeftArm.") return end
	if not MyLeftArm then print("Cannot weld" , object.Name , "to an arm you don't have.") return nil end
	local weld = Instance.new('ManualWeld')
	weld.Part0 = MyLeftArm
	weld.Part1 = object
	-- This CFrame data was collected through studio
	weld.C0 = CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0)
	-- this weld is on right side of left arm
	--weld.C1 = CFrame.new(0, -0.3, -0.7, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	-- this weld is on the top of right arm
	weld.C1 = CFrame.new(0, -0.3, -0.7, 0, 1, 0, -1, 0, 0, 0, 0, 1)
	weld.Parent = object
end

local function CreateMolecularAtomizer()
	local atomizer = Instance.new('Part')
	atomizer.FormFactor = Enum.FormFactor.Custom
	atomizer.Size = Vector3.new(1, 1.6, 1.4)
	local mesh = Instance.new('SpecialMesh')
	mesh.MeshId = URL_PREFIX .. MESH_ID
	mesh.TextureId = URL_PREFIX .. TEXTURE_ID
	mesh.Parent = atomizer
	return atomizer
end

local function Lerp(start, finish, ratio)
	ratio = math.min(1, math.max(ratio, 0))
	return (1 - ratio) * start + ratio * finish
end

-- Think of this circle as one in local space with its normal pointing in the pos-y
-- so, if we use the points from this circle function we need to remember to rotate the return values
-- into the world-space circle that we want
local function PointOnCircle(originX, originZ, radius, theta)
	local X = originX + radius * math.cos(theta)
	local Z = originZ + radius * math.sin(theta)
	return X, Z
end

local function CreateLightningOutline(character)
	wait(0.5)
	for i = 1, 5 do
		if not character then print("No character to outline") return end
		for _, child in pairs(character:GetChildren()) do
			if child:IsA('Part') then
				local selectionBox = Instance.new('SelectionBox')
				DebrisService:AddItem(selectionBox, 0.1)
				selectionBox.Adornee = child
				selectionBox.Transparency = 0.3
				selectionBox.Parent = child
			end
		end
		wait(0.3)
	end
end

-- It is conceptually easier to construct the lightning beam pointing up along
-- the pos-y axis and then rotate each point by the direction vector
local function CreateLightningBeam(start, direction, distance)
	local boltList = {}
	distance = math.min(MAX_SHOOTING_DISTANCE, math.max(distance, INTERVAL_BETWEEN_LIGHTNING))
	direction = direction.unit
	local orientationCFrame = CFrame.new(Vector3.new(), direction.unit) * CFrame.Angles(0, -math.pi / 2, math.pi / 2)
	for i = 1, distance / INTERVAL_BETWEEN_LIGHTNING do
		local currOrigin = Vector3.new(0, INTERVAL_BETWEEN_LIGHTNING, 0) * i
		local nextOrigin = Vector3.new(0, INTERVAL_BETWEEN_LIGHTNING, 0) * (i + 1)
		local rotationRandomness = math.random() * math.pi / 2
		for j = 1, 4 do
			local currX, currZ = PointOnCircle(currOrigin.x, currOrigin.z, LIGHTNING_RADIUS, (math.pi / 2) * j + rotationRandomness)
			local nextX, nextZ = PointOnCircle(nextOrigin.x, nextOrigin.z, LIGHTNING_RADIUS, (math.pi / 2) * (j+1) + rotationRandomness)
			local currBolt = Instance.new('Part')
			currBolt.Anchored = true
			currBolt.Size = Vector3.new(0.2, 0.2, INTERVAL_BETWEEN_LIGHTNING * 1.2)
			currBolt.CanCollide = false
			currBolt.Transparency = math.min(1, (math.random() + 0.5) / 2 + 0.08)
			table.insert(boltList, currBolt)
			local currPoint = Vector3.new(currX, currOrigin.Y, currZ)
			local nextPoint = Vector3.new(nextX, nextOrigin.Y, nextZ)
			-- Adjust because the part is centered in the middle not the tip
			currPoint = currPoint + ((nextPoint - currPoint).unit * (currBolt.Size.Y / 2))
			currPoint = (orientationCFrame * currPoint) + start
			nextPoint = (orientationCFrame * nextPoint) + start
			currBolt.CFrame = CFrame.new(currPoint, nextPoint) * CFrame.Angles(0, 0, -math.pi / 2)
			LightningMesh:Clone().Parent = currBolt
			DebrisService:AddItem(currBolt, 1.6)
			currBolt.Parent = Workspace
		end
	end
	for i = 1, 5 do
		Spawn(function()
			for k, v in pairs(boltList) do
				if v then
					if k % 4 == 0 then
						wait(0.05)
					end
					v.Transparency = v.Transparency / 3
				end
			end
		end)
		Delay(0.1, function()
			for k, v in pairs(boltList) do
				if v then
					if k % 4 == 0 then
						wait(0.05)
					end
					v.Transparency = v.Transparency * 3
				end
			end
		end)
		wait(0.3)
	end
end

local function ChangeTimeToEvening()
	if RevertingTimeOfDay then return end
	OriginalTime = LightingService:GetMinutesAfterMidnight()
	for i = 0, 1, 0.01 do
		if RevertingTimeOfDay then break end
		LightingService:SetMinutesAfterMidnight(Lerp(OriginalTime, EVENING_MINUTES_AFTER_MIDNIGHT, i))
		wait(0.02)
	end
end

-- Everyone likes Braid
local function RevertTimeBack()
	if RevertingTimeOfDay then return end
	RevertingTimeOfDay = true
	local currTime = LightingService:GetMinutesAfterMidnight()
	for i = 0, 1, 0.01 do
		LightingService:SetMinutesAfterMidnight(Lerp(currTime, OriginalTime, i))
		wait(0.02)
	end
	RevertingTimeOfDay = false
end

function OnButton1Up()

end


function OnEquipped(mouse)
	Handle = WaitForChild(Tool, 'Handle')
	Handle.Transparency = 1
	MyCharacter = Tool.Parent
	ShootSound = WaitForChild(Handle, 'ShootSound')
	MyLeftArm = WaitForChild(MyCharacter, 'Left Arm')
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	IdleTrack = MyHumanoid:LoadAnimation(WaitForChild(Tool, 'IdleGvM'))
	if IdleTrack then
		IdleTrack:Play()
	end
	ShootTrack = MyHumanoid:LoadAnimation(WaitForChild(Tool, 'Shoot2GvM'))
	MyMouse = mouse
	if MyMouse then
		MyMouse.Button1Up:connect(OnButton1Up)
	end
	wait(0.1)
	MolecularAtomizer = CreateMolecularAtomizer()
	WeldToLeftArm(MolecularAtomizer)
	FreezeTorsoScript = WaitForChild(Tool, 'FreezeTorso')
	MolecularAtomizer.Parent = Tool
	ChangeTimeToEvening()
end

function OnUnequipped()
	Handle.Transparency = 0
	if ShootTrack then
		ShootTrack:Stop()
	end
	if IdleTrack then
		IdleTrack:Stop()
	end
	if MolecularAtomizer then
		-- Destroying sets the parent which can be problematic if
		-- in the same call stack the unequip function is setting the parent to be Backpack or workspace
		wait(0.1)
		MolecularAtomizer:Destroy()
		MolecularAtomizer = nil
	end
	RevertTimeBack()
end

function Blow(hit)
	if hit then
		print("blow:" , hit.Name)
	end
	if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') then
		local character = hit.Parent
		local hum = character.Humanoid
		-- Make sure it is an NPC -- if the character has no player then it is an npc
		if not PlayersService:GetPlayerFromCharacter(character) then
			if (hit.CFrame.p - MolecularAtomizer.CFrame.p).magnitude < MAX_SHOOTING_DISTANCE then
				-- uncomment if you want to deal damage
				-- Delay(1.4, function() if hum then hum:TakeDamage(LIGHTNING_DAMAGE) end end)
				if FreezeTorsoScript then
					local freezeTorsoCopy = FreezeTorsoScript:Clone()
					freezeTorsoCopy.Parent = hit.Parent
					freezeTorsoCopy.Disabled = false
				end
				coroutine.resume(coroutine.create(CreateLightningOutline), hit.Parent)
			end
		else
			print("Is a Player.")
		end
	else
		print("Not a character")
	end
end


local Attacking = false
function OnActivate()
	-- Engage lightning blasters
	if Attacking or not MyHumanoid or MyHumanoid.Health <= 0 then return end
	Attacking = true
	Tool.Enabled = false

	if MyMouse then
		local hitPos = MyMouse.Hit.p
		if MyMouse.Target then
			Blow(MyMouse.Target)
			if FreezeTorsoScript and MyCharacter then
				local freezeTorsoCopy = FreezeTorsoScript:Clone()
				freezeTorsoCopy.Parent = MyCharacter
				freezeTorsoCopy.Disabled = false
			end
		else
			print('no target')
		end
		if ShootTrack then
			ShootTrack:Play()
		end
		wait(0.2)
		if ShootSound then
			ShootSound:Play()
		end
		wait(0.2)
		--[[
		Spawn(function()
		for i = 1, 3 do
			local currTime = LightingService:GetMinutesAfterMidnight()
			LightingService:SetMinutesAfterMidnight(600)
			wait(0.1)
			LightingService:SetMinutesAfterMidnight(currTime)
			wait(0.1)
		end
		end)
		--]]
		CreateLightningBeam(MolecularAtomizer.CFrame.p, (hitPos - MolecularAtomizer.CFrame.p), (hitPos - MolecularAtomizer.CFrame.p).magnitude)
	end
	wait(2)
	Tool.Enabled = true
	Attacking = false
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivate)
