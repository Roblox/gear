local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local Thrown = false

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
function checkTeams(otherHuman)
	return not (sameTeam(otherHuman) and not FriendlyFire)
end

function getExplosionPos()
	local char = Tool.Parent
	if char and char:FindFirstChild("HumanoidRootPart") then
		return char.HumanoidRootPart.Position - Vector3.new(0, 2.5, 0)
	end
	return Vector3.new()
end

function blindEnemies()
	local e = Instance.new("Explosion")
	e.BlastRadius = 15
	e.BlastPressure = 0
	e.Position = getExplosionPos()
	e.Hit:connect(function(part)
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			if checkTeams(part.Parent.Humanoid) then
				local blind = Tool.Blind:Clone()
				blind.Disabled = false
				blind.Parent = part.Parent
			end
		end
	end)
	e.Parent = workspace
end

function onLeftDown()
	if Thrown then return end
	Thrown = true
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Throw")
	wait(0.25)
	
	blindEnemies()
	
	local bomb = Handle:clone()
	bomb.Position = getExplosionPos()
	bomb.Anchored = true
	
	local smoke = Instance.new("Smoke")
	smoke.Size = 15
	smoke.Opacity = 1
	smoke.Parent = bomb
	
	bomb.Parent = workspace
	bomb.Pop:Play()
	
	delay(2, function()
		smoke.Enabled = false
		game:GetService("Debris"):AddItem(bomb, 8)
		game:GetService("Debris"):AddItem(Tool, 0)
	end)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
