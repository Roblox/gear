local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local DropAble = true
local DropReloadTime = 1

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

function rpi()
	return math.random() * math.pi * 2
end

function getEgg(scale)
	scale = scale or 1
	
	local egg = Instance.new("Part")
	egg.FormFactor = "Custom"
	egg.TopSurface = "Smooth"
	egg.BottomSurface = "Smooth"
	egg.Shape = "Ball"
	egg.Size = Vector3.new(2, 2, 2)
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = "rbxassetid://1527559"
	mesh.TextureId = "rbxassetid://24463480"
	mesh.Parent = egg
	
	local fire = Instance.new("Fire", egg)
	fire.Size = 30
	
	local sound = Handle.Explosion:Clone()
	sound.Parent = egg
	
	local c
	c = egg.Touched:connect(function(part)
		egg.Explosion.Pitch = math.random(90, 110)/100
		egg.Explosion:Play()
		
		if part:IsGrounded() then
			c:disconnect()
			
			fire.Enabled = false
			
			egg.Anchored = true
			egg.Velocity = Vector3.new(0, 0, 0)
			egg.RotVelocity = Vector3.new(0, 0, 0)
			egg.CFrame = egg.CFrame + Vector3.new(0, -egg.Size.Y/2, 0)
		end
	end)
	
	egg.Size = egg.Size * scale
	mesh.Scale = mesh.Scale * scale
	
	return egg
end

function onLeftDown(targetPoint)
	if not DropAble then return end
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Cast")
	Handle.Cast:Play()
	
	DropAble = false
	delay(DropReloadTime, function()
		DropAble = true
	end)
	
	local egg = getEgg(math.random(2, 4))
	egg.CFrame = CFrame.new(targetPoint.X, Handle.Position.Y + 128, targetPoint.Z) * CFrame.Angles(rpi(), rpi(), rpi())
	egg.Parent = workspace
	game:GetService("Debris"):AddItem(egg, 15)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

Remote.OnServerEvent:connect(onRemote)