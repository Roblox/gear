local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local AttackDamage = 45

local LeftDown = false
local MousePos, MouseTarget

local Lasers = {}
local LaserLength = 8
local LaserSound = Handle:WaitForChild("Laser")

local Heartbeat = game:GetService("RunService").Heartbeat

--returns the wielding player of this tool
function getPlayer()
	local char = Tool.Parent
	return game:GetService("Players"):GetPlayerFromCharacter(char)
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

function getHandleTip()
	return (Handle.CFrame * CFrame.new(0, 0.1, -1.7)).p
end

function laserBetween(a, b)
	local d = (b - a)
	local m = d.magnitude
	local lasersNeeded = math.ceil(m/LaserLength)
	
	--this following is basically witchcraft so that we replicate as little as possible
	if #Lasers > lasersNeeded then
		for i = lasersNeeded+1, #Lasers do
			Lasers[i]:Destroy()
			Lasers[i] = nil
		end
	elseif #Lasers < lasersNeeded then
		repeat
			local laser = Instance.new("Part")
			laser.FormFactor = "Custom"
			laser.Anchored = true
			laser.CanCollide = false
			laser.Size = Vector3.new(0.2, 0.2, LaserLength)
			laser.BrickColor = BrickColor.new("Teal")
			
			local light = Instance.new("PointLight")
			light.Color = laser.BrickColor.Color
			light.Parent = laser
			
			table.insert(Lasers, laser)
		until #Lasers >= lasersNeeded
	end
	
	for index, laser in pairs(Lasers) do
		local factor = index - 1
		
		local laserStart = a + d.unit * factor * LaserLength
		local laserFinish = laserStart + d.unit * LaserLength
		local laserPos = (laserStart + laserFinish) / 2
		
		laser.CFrame = CFrame.new(laserPos, laserFinish)
		laser.Parent = Tool
	end
end

function clearLasers()
	for index, laser in pairs(Lasers) do
		laser:Destroy()
		Lasers[index] = nil
	end
end

function firingLoop()
	LaserSound:Play()
	while LeftDown do
		local ray = Ray.new(getHandleTip(), (MousePos-getHandleTip()).unit * 256)
		local targetPart, targetPos = workspace:FindPartOnRay(ray, Tool.Parent)
		
		laserBetween(getHandleTip(), targetPos)

		local dt = Heartbeat:wait()
		
		if targetPart and targetPart.Parent and targetPart.Parent:FindFirstChild("Humanoid") then
			local human = targetPart.Parent.Humanoid
			if checkTeams(human) then
				tagHuman(human)
				human:TakeDamage(AttackDamage * dt)
			end
		end
	end
	LaserSound:Stop()
	clearLasers()
end

function onEquip()
	Remote:FireClient(getPlayer(), "PlayAnimation", "GunHold")
end

function onUnequip()
	Remote:FireClient(getPlayer(), "StopAnimation", "GunHold")
end

function onLeftDown(mousePos, mouseTarget)
	LeftDown = true
	MousePos = mousePos
	MouseTarget = mouseTarget
	firingLoop()
end

function onLeftMoved(mousePos, mouseTarget)
	MousePos = mousePos
	MouseTarget = mouseTarget
end

function onLeftUp(mousePos, mouseTarget)
	LeftDown = false
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	elseif func == "LeftMoved" then
		onLeftMoved(...)
	elseif func == "LeftUp" then
		onLeftUp(...)
	end
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Remote.OnServerEvent:connect(onRemote)