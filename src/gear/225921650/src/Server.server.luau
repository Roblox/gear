local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local AttackAble = true
local AttackReloadTime = 25

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

function getFlute()
	local root = Tool.Parent:FindFirstChild("HumanoidRootPart")
	if root then
		local flute = Handle:Clone()
		flute.CanCollide = true
		flute.Transparency = 0
		flute.Size = Vector3.new(1, 10, 1)
		flute.CFrame = CFrame.new(root.Position + Vector3.new(0, 1024, 0))
		flute.Mesh.Scale = Vector3.new(1, 1, 1)
		
		Instance.new("Fire", flute)
		
		flute.Parent = Tool.Parent
		return flute
	end
end

function globalWarn()
	local warning = Handle.Warning:Clone()
	warning.Parent = workspace
	warning:Play()
	game:GetService("Debris"):AddItem(warning)
end

function onLeftDown()
	if not AttackAble then return end
	
	AttackAble = false
	Handle.Transparency = 1
	delay(AttackReloadTime, function()
		AttackAble = true
		Handle.Transparency = 0
	end)
	
	globalWarn()
	
	local flute = getFlute()
	
	local touchedConnection
	
	local function onFluteTouched(part)
		local e = Instance.new("Explosion")
		e.Position = flute.Position
		e.BlastRadius = 12
		e.Hit:connect(function(part)
			if part.Parent and part.Parent:FindFirstChild("Humanoid") then
				local human = part.Parent.Humanoid
				tagHuman(human)
			end
		end)
		e.Parent = workspace
		
		flute.Anchored = true
		flute.CanCollide = false
		flute.Transparency = 1
		flute.Fire.Enabled = false
		
		flute.Explosion:Play()
		game:GetService("Debris"):AddItem(flute)
		
		touchedConnection:disconnect()
	end
	
	touchedConnection = flute.Touched:connect(onFluteTouched)
	
	Remote:FireClient(getPlayer(), "FluteLaunch", flute)
	Remote:FireClient(getPlayer(), "PlayAnimation", "FlutePlay")
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown()
	end
end

Remote.OnServerEvent:connect(onRemote)
