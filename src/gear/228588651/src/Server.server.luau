local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local AttackAble = true
local AttackReloadTime = 1

local ProjectileSpeed = 128

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

function splatter(character)
	local splatterScript = Tool.Splatter:Clone()
	splatterScript.Disabled = false
	splatterScript.Parent = character
end

function getEgg()
	local egg = Instance.new("Part")
	egg.CanCollide = false
	egg.TopSurface = "Smooth"
	egg.BottomSurface = "Smooth"
	egg.FormFactor = "Custom"
	egg.Size = Vector3.new(1, 1, 1)
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = "rbxassetid://225334624"
	mesh.TextureId = "rbxassetid://225334944"
	mesh.Parent = egg
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 196.2, 0) * egg:GetMass() * 0.9
	lift.Parent = egg
	
	local sound = Handle.Egg:Clone()
	sound.Pitch = math.random(90, 110)/100
	sound.Parent = egg
	
	return egg
end

function onLeftDown(targetPoint)
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackReloadTime, function()
		AttackAble = true
	end)
	
	Handle.Shot.Pitch = math.random(90, 110)/100
	Handle.Shot:Play()
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Fire")
	
	local egg = getEgg()
	egg.Position = Handle.Position
	egg.Velocity = (targetPoint - egg.Position).unit * ProjectileSpeed
	local c
	c = egg.Touched:connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		
		c:disconnect()
		
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local human = part.Parent.Humanoid
			
			if checkTeams(human) then
				splatter(part.Parent)
			end
		end
		
		egg.CFrame = CFrame.new(egg.Position) * CFrame.Angles(math.pi, 0, 0)
		egg.Velocity = Vector3.new(0, 0, 0)
		egg.Transparency = 1
		egg.Egg:Play()
		game:GetService("Debris"):AddItem(egg, 5)
		
		local yolk = Instance.new("Fire")
		yolk.Size = 2
		yolk.Heat = 18
		yolk.Color = Color3.new(1, 1, 0)
		yolk.SecondaryColor = yolk.Color
		yolk.Parent = egg
	end)
	egg.Parent = workspace
	game:GetService("Debris"):AddItem(egg, 10)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
