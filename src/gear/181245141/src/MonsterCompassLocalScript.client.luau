-- Made by SolarCrane

local RS = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local PlayersService = game:GetService("Players")

local Utility = require(RS:WaitForChild('Utility'))
local Signal = require(RS:WaitForChild('Signal'))
local CreateLocalWelder = require(RS:WaitForChild('LocalEquipWeld'))
local MonsterData = require(RS:WaitForChild('MonsterData'))


local MonsterGearGui = require(RS:WaitForChild('MonsterGearGui'))


local LocalPlayer = PlayersService.LocalPlayer
local Character = nil
local PlayerGui = LocalPlayer:WaitForChild('PlayerGui')

local MonsterInfoGui = nil

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local CompassGuiPrefab = Tool:WaitForChild('CompassSurfaceGui')
local Equipped = false
local MonsterCompassGui = nil


local MESH_ARM = 180288381
local MESH_COMPASS_COMPASS = 180288400
local MESH_COMPASS = 180288413

-- Speed is in degrees per second
local CANT_FIND_TARGET_SPEED = 300
local ZERO_VECTOR = Vector3.new()
local XZ_VECTOR = Vector3.new(1,0,1)
CreateLocalWelder(Tool)

local MosterTargetType = nil

local MonsterContainer = workspace:FindFirstChild('MonsterContainer')

local CachedTarget = nil
local LastCacheLook = 0
local function FindCompassTarget(cacheBust)
	MonsterContainer = MonsterContainer or workspace:FindFirstChild('MonsterContainer')
	if tick() - LastCacheLook > 2.5 or cacheBust then
		local nearestDistance = math.huge
		local nearestGuy = nil
		if MonsterContainer and LocalPlayer and LocalPlayer.Character and MosterTargetType and MosterTargetType.DisplayName then
			for _, child in pairs(MonsterContainer:GetChildren()) do
				if child:IsA('Model') and child.Name == MosterTargetType.DisplayName then
					local distance = LocalPlayer:DistanceFromCharacter(child:GetModelCFrame().p)
					if distance < nearestDistance then
						nearestDistance = distance
						nearestGuy = child
					end
				end
			end
		end
		if nearestGuy then
			CachedTarget = nearestGuy
		end
		LastCacheLook = tick()
	end
	
	
	if CachedTarget and CachedTarget:IsA('Model') then
		return CachedTarget and CachedTarget:GetModelCFrame()
	end
end

local function DestroyGui()
	if MonsterCompassGui then
		MonsterCompassGui:Destroy()
		MonsterCompassGui = nil
	end
end

local function CreateGui()
	DestroyGui()
	local thisGui = CompassGuiPrefab:Clone()
	MonsterCompassGui = thisGui
	MonsterCompassGui.Enabled = true
	MonsterCompassGui.Adornee = Handle
	MonsterCompassGui.Parent = PlayerGui
	
	local ArmLabel = MonsterCompassGui:FindFirstChild('Arm')
	spawn(function()
		local now = tick()
		local lastTick = now
		while thisGui and thisGui == MonsterCompassGui and Equipped do
			now = tick()
			if ArmLabel then
				if Character then
					local newTarget = FindCompassTarget()
					if newTarget then
						local humanoid = Utility.GetHumanoid(LocalPlayer)
						local torso = humanoid and humanoid.Torso
						
						local torsoLookVector = (torso.CFrame.lookVector * XZ_VECTOR).unit
						local toTargetVector = ((torso.CFrame.p - newTarget.p) * XZ_VECTOR).unit
						local rotatedVector = CFrame.new(ZERO_VECTOR, torsoLookVector):vectorToObjectSpace(toTargetVector)
						
						local theta = math.atan2(rotatedVector.z,rotatedVector.x)
						
						-- Check for NaN
						if theta and theta == theta then
							ArmLabel.Rotation = math.deg(theta)
						end
					else
						ArmLabel.Rotation = ArmLabel.Rotation + CANT_FIND_TARGET_SPEED * (now - lastTick)
					end
				end
			end
			lastTick = now
			RunService.RenderStepped:wait()
		end
	end)
end

local function OnEquip()
	Equipped = true	
	Character = LocalPlayer.Character
	CreateGui()
	if not MonsterInfoGui then
		MonsterInfoGui = MonsterGearGui(true)
		MonsterInfoGui:SetName("Monster Compass")
		MonsterInfoGui.MonsterTypeSelected:connect(function(monsterInfo)
			MosterTargetType = monsterInfo
			MonsterInfoGui:Hide()
			FindCompassTarget(true)
		end)
	end
	MonsterInfoGui:Show()
end

local function OnUnequip()
	Equipped = false
	Character = nil
	DestroyGui()
	if MonsterInfoGui then
		MonsterInfoGui:Hide()
	end
end

Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
