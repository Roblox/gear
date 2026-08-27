local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local AttackAble = true
local AttackReloadTime = 1.33

local ProjectileSpeed = 128
local ProjectileDamageMin = 10
local ProjectileDamageMax = 110
local ProjectileExplosionSizeMin = 4
local ProjectileExplosionSizeMax = 16
local ProjectileMaxPowerTime = 1.5

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

function lerp(a, b, p)
	return a + (b - a) * p
end

function getProjectileDamage(p)
	return lerp(ProjectileDamageMin, ProjectileDamageMax, p)
end

function getProjectileBlastRadius(p)
	return lerp(ProjectileExplosionSizeMin, ProjectileExplosionSizeMax, p)
end

function getArrow()
	local arrow = Instance.new("Part")
	arrow.FormFactor = "Custom"
	arrow.Size = Vector3.new(0.2, 0.2, 2.5)
	arrow.TopSurface = "Smooth"
	arrow.BottomSurface = "Smooth"
	arrow.CanCollide = false
	
	local mesh = Handle.Mesh:Clone()
	mesh.MeshId = "rbxassetid://220392363"
	mesh.Parent = arrow
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 1, 0) * arrow:GetMass() * 196.2 * 0.9
	lift.Parent = arrow
	
	local proj = Tool.Projectile:Clone()
	proj.Disabled = false
	proj.Parent = arrow
	
	Handle.Beep:Clone().Parent = arrow
	Handle.Boom:Clone().Parent = arrow
	Handle.Hit:Clone().Parent = arrow
	
	return arrow
end

function onLeftDown(targetPoint)
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackReloadTime, function()
		AttackAble = true
	end)
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Fire", 0)
	delay(1/3, function()
		Remote:FireClient(getPlayer(), "PlayAnimation", "Reload", 0)
	end)
	
	Handle.Shot.Pitch = math.random(90, 110)/100
	Handle.Shot:Play()
	
	local launchPoint = Handle.Position
	local launchTime = tick()
	local arrow = getArrow()	
	arrow.CFrame = CFrame.new(launchPoint, targetPoint)
	arrow.Velocity = arrow.CFrame.lookVector * ProjectileSpeed
	
	local c
	c = arrow.Touched:connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		
		c:disconnect()
		
		arrow.Projectile:Destroy()
		arrow.Velocity = Vector3.new()
		
		local w = Instance.new("Weld")
		w.Part0 = part
		w.Part1 = arrow
		w.C0 = part.CFrame:toObjectSpace(arrow.CFrame)
		w.Parent = w.Part0
		
		local power = math.min(tick() - launchTime, ProjectileMaxPowerTime) / ProjectileMaxPowerTime
		local damage = getProjectileDamage(power)
		local radius = getProjectileBlastRadius(power)
		
		arrow.Hit.TimePosition = 0.3
		arrow.Hit:Play()
		
		wait(1)
		
		arrow.Beep:Play()
		
		delay(1, function()
			local point = arrow.Position
			arrow.Boom:Play()
			arrow.Transparency = 1
			arrow:BreakJoints()
			arrow.Anchored = true
			
			local e = Instance.new("Explosion")
			e.Position = point
			e.BlastPressure = 0
			e.BlastRadius = radius
			
			local victims = {}
			e.Hit:connect(function(part)
				if part.Parent and part.Parent:FindFirstChild("Humanoid") then
					local human = part.Parent.Humanoid
					if not contains(victims, human) and checkTeams(human) then
						table.insert(victims, human)
						tagHuman(human)
						human:TakeDamage(damage)
					end
				end
			end)
			
			e.Parent = workspace
		end)
	end)
	
	arrow.Parent = workspace
	game:GetService("Debris"):AddItem(arrow, 10)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

function onEquip()
	Remote:FireClient(getPlayer(), "PlayAnimation", "Hold", 0)
end

function onUnequip()
	Remote:FireClient(getPlayer(), "StopAnimation", "Hold")
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Remote.OnServerEvent:connect(onRemote)