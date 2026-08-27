local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local CanSlow = true
local SlowAmount = 6
local SlowTime = 1.5
local SlowRange = 48

local RainbowColors = {"Bright red", "Bright orange", "Bright yellow", "Bright green", "Bright blue", "Bright violet"}

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
function canTarget(otherHuman)
	return not (sameTeam(otherHuman) and not FriendlyFire)
end

function basePart()
	local part = Instance.new("Part")
	part.FormFactor = "Custom"
	part.Anchored = true
	part.CanCollide = false
	part.Material = "SmoothPlastic"
	
	return part
end

function pointFromPartOffset(part, offset)
	return (part.CFrame * offset).p
end

function rainbowBeam(startPart, startOffset, endPart, endOffset)	
	local colorBeamSize = 0.2
	local numColors = #RainbowColors
	
	local beamsCreated = {}
	
	local t = SlowTime
	repeat
		local startPoint = pointFromPartOffset(startPart, startOffset)
		local endPoint = pointFromPartOffset(endPart, endOffset)
		local midPoint = (startPoint + endPoint) / 2
		local distance = (endPoint - startPoint).magnitude
		local cframe = CFrame.new(midPoint, endPoint)
		local yOffset = -(numColors / 2) * colorBeamSize
		
		for _, color in pairs(RainbowColors) do
			local beam
			
			if beamsCreated[color] then
				beam = beamsCreated[color]
			else
				beam = basePart()
				beam.BrickColor = BrickColor.new(color)
				beam.Parent = workspace
				game:GetService("Debris"):AddItem(beam, t)
				
				beamsCreated[color] = beam
			end
			
			beam.Size = Vector3.new(colorBeamSize, colorBeamSize, distance)
			beam.CFrame = cframe * CFrame.new(0, yOffset, 0)
			yOffset = yOffset + colorBeamSize
		end
		
		t = t - Heartbeat:wait()
	until t <= 0
end

function fireRainbowBeam(human)
	local char = human.Parent
	if char and char:FindFirstChild("HumanoidRootPart") then
		local startPart = Handle
		local startOffset = CFrame.new(0, 0.6, 0)
		local endPart = char.HumanoidRootPart
		local endOffset = CFrame.new()
		rainbowBeam(startPart, startOffset, endPart, endOffset)
	end
end

function slow(human)
	human.WalkSpeed = human.WalkSpeed - SlowAmount
	delay(SlowTime, function()
		human.WalkSpeed = human.WalkSpeed + SlowAmount
	end)
end

function inRange(human)
	local char = human.Parent
	if char and char:FindFirstChild("HumanoidRootPart") then
		local root = char.HumanoidRootPart
		return (root.Position - Handle.Position).magnitude < SlowRange
	end
	return false
end

function onLeftDown(target)
	if target == nil then return end
	if target.Parent == nil then return end
	if not CanSlow then return end
	
	local human = target.Parent:FindFirstChild("Humanoid")
	if human and canTarget(human) and inRange(human) then
		CanSlow = false
		slow(human)
		fireRainbowBeam(human)
		CanSlow = true
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

Remote.OnServerEvent:connect(onRemote)