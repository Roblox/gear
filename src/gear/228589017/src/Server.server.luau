local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local AttackDamage = 35
local AttackAble = true
local AttackRestTime = 1

local ProjectileSpeed = 128

local MousePoint = Vector3.new()

local Arrows = {}

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

function getArrow()
	local arrow = Instance.new("Part")
	arrow.FormFactor = "Custom"
	arrow.Size = Vector3.new(0.2, 0.4, 3)
	arrow.TopSurface = "Smooth"
	arrow.BottomSurface = "Smooth"
	arrow.CanCollide = false
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = "rbxassetid://223379254"
	mesh.TextureId = "rbxassetid://223379299"
	mesh.Scale = Vector3.new(0.6, 0.6, 0.6)
	mesh.Parent = arrow
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 196.2, 0) * arrow:GetMass() * 0.9
	lift.Parent = arrow
	
	local hit = Handle.Hit:Clone()
	hit.Parent = arrow
	hit.TimePosition = 0.2
	
	local projectile = Tool.Projectile:Clone()
	projectile.Disabled = false
	projectile.Parent = arrow
	
	return arrow
end

function onLeftDown()
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackRestTime, function()
		AttackAble = true
	end)
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "BowFire")
	
	wait(0.3)
	
	Handle.Shot.Pitch = math.random(90,110)/100
	Handle.Shot:Play()
	
	local arrow = getArrow()
	arrow.CFrame = CFrame.new(Handle.Position, MousePoint)
	arrow.Velocity = arrow.CFrame.lookVector * ProjectileSpeed
	
	local c
	c = arrow.Touched:connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		if contains(Arrows, part) then return end
		
		c:disconnect()
		arrow.Projectile:Destroy()
		
		local w = Instance.new("Weld")
		w.Part0 = part
		w.Part1 = arrow
		w.C0 = part.CFrame:toObjectSpace(arrow.CFrame)
		w.Parent = w.Part0
		
		arrow.Hit:Play()
		
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local human = part.Parent.Humanoid
			if checkTeams(human) then
				tagHuman(human)
				human:TakeDamage(AttackDamage)
			end
		end
	end)	
	
	table.insert(Arrows, arrow)
	arrow.Parent = workspace
	game:GetService("Debris"):AddItem(arrow, 10)
end

function onMouseUpdate(targetPoint)
	MousePoint = targetPoint
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	elseif func == "UpdateMouse" then
		onMouseUpdate(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
