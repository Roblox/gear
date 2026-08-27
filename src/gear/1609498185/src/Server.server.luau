local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local Heartbeat = game:GetService("RunService").Heartbeat

local FriendlyFire = false

local LeftDown = false

local AttackHoldTime = 1
local AttackAble = true
local AttackRestTime = 1
local AttackWindupTime = 0.2
local AttackDamaging = false
local AttackWindow = 0.6
local AttackVictims = {}
local AttackDamage = 30
local AttackProjectileSpeed = 128
local AttackProjectileDamage = 30
local AttackProjectileVictims = {}

local Character = nil
local Humanoid = nil

--returns the wielding player of this tool
function getPlayer()
	local char = Tool.Parent
	return game:GetService("Players"):GetPlayerFromCharacter(Character)
end

--helpfully checks a table for a specific value
function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

--tags a human for the ROBLOX KO system
function tagHuman(human)
	local tag = Instance.new("ObjectValue")
	tag.Value = getPlayer()
	tag.Name = "creator"
	tag.Parent = human
	game:GetService("Debris"):AddItem(tag)
end

--used by checkTeams
function sameTeam(otherHuman)
	local player = getPlayer()
	local otherPlayer = game:GetService("Players"):GetPlayerFromCharacter(otherHuman.Parent)
	if player and otherPlayer then
		if player == otherPlayer then
			return true
		end
		if otherPlayer.Neutral then
			return false
		end
		return player.TeamColor == otherPlayer.TeamColor
	end
	return false
end

--use this to determine if you want this human to be harmed or not, returns boolean
function checkTeams(otherHuman)
	return not (sameTeam(otherHuman) and not FriendlyFire)
end

function onHandleTouched(part)
	if not AttackDamaging then return end
	if part:IsDescendantOf(Tool.Parent) then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if checkTeams(human) and not contains(AttackVictims, human) then
			tagHuman(human)
			table.insert(AttackVictims, human)
			human:TakeDamage(AttackDamage)
		end
	end
end

function onProjectileTouched(part)
	if part:IsDescendantOf(Tool.Parent) then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if checkTeams(human) and not contains(AttackProjectileVictims, human) then
			tagHuman(human)
			table.insert(AttackProjectileVictims, human)
			human:TakeDamage(AttackDamage)
		end
	end
end

function onLeftHold()
	print("Hold")
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Remote:FireClient(getPlayer(), "PlayAnimation", "R15Swing2")
	else
		Remote:FireClient(getPlayer(), "PlayAnimation", "Swing2")
	end	
	
	delay(0.1, function()
		Handle.Swing.Pitch = 0.8
		Handle.Swing:Play()
		delay(0.4, function()
			Handle.Swing.Pitch = 1
			Handle.Swing:Play()
			delay(0.3, function()
				Handle.Swing.Pitch = 1.2
				Handle.Swing:Play()
				Handle.Shot.Pitch = math.random(90, 110)/100
				Handle.Shot:Play()
			end)
		end)
	end)
	
	wait(0.8)
	
	local root = Tool.Parent:FindFirstChild("HumanoidRootPart")
	if root then
		local slash = Instance.new("Part")
		slash.CanCollide = false
		slash.FormFactor = "Custom"
		slash.TopSurface = "Smooth"
		slash.BottomSurface = "Smooth"
		slash.BrickColor = BrickColor.new("Lime green")
		slash.Size = Vector3.new(3, 0.2, 3)
		slash.CFrame = root.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, math.pi/2)
		
		Instance.new("CylinderMesh", slash)
		
		local bv = Instance.new("BodyVelocity")
		bv.maxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.velocity = root.CFrame.lookVector * AttackProjectileSpeed
		bv.Parent = slash
		
		local spark = Instance.new("Fire")
		spark.Color = slash.BrickColor.Color
		spark.SecondaryColor = spark.Color
		spark.Parent = slash
		
		local light = Instance.new("PointLight")
		light.Range = 16
		light.Color = slash.BrickColor.Color
		light.Parent = slash
		
		slash.Parent = workspace
		game:GetService("Debris"):AddItem(slash, 5)
		
		AttackProjectileVictims = {}
		local c = slash.Touched:connect(onProjectileTouched)
		
		wait(0.5)
		slash.Anchored = true
		slash.Transparency = 1
		c:disconnect()
		spark.Enabled = false
		light:Destroy()
	end 
end

function onLeftDown()
	if not AttackAble then return end
	AttackAble = false
	
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Remote:FireClient(getPlayer(), "PlayAnimation", "R15Swing1")
	else
		Remote:FireClient(getPlayer(), "PlayAnimation", "Swing1")
	end
	
	
	delay(0.2, function()
		Handle.Swing.Pitch = math.random(90, 110)/100
		Handle.Swing:Play()
	end)
	
	delay(AttackWindupTime, function()
		AttackVictims = {}
		AttackDamaging = true
		delay(AttackWindow, function()
			AttackDamaging = false
		end)
	end)
	
	LeftDown = true
	local t = 0
	while LeftDown do
		t = t + Heartbeat:wait()
		if t > AttackHoldTime then
			onLeftHold()
			break
		end
	end
	
	delay(AttackRestTime, function()
		AttackAble = true
	end)
end

function onLeftUp()
	LeftDown = false
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	elseif func == "LeftUp" then
		onLeftUp(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
Handle.Touched:connect(onHandleTouched)
Tool.Equipped:Connect(function()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end)

Tool.Unequipped:Connect(function()
	Character = nil
	Humanoid = nil
end)