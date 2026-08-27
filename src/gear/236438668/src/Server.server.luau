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

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

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
	arrow.Transparency = 0.25
	arrow.Reflectance = 0.5
	arrow.FormFactor = "Custom"
	arrow.Size = Vector3.new(0.2, 0.2, 2.5)
	arrow.TopSurface = "Smooth"
	arrow.BottomSurface = "Smooth"
	arrow.CanCollide = false
	
	local mesh = Handle.Mesh:Clone()
	mesh.MeshId = "rbxassetid://235107348"
	mesh.Parent = arrow
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 1, 0) * arrow:GetMass() * 196.2 * 0.9
	lift.Parent = arrow
	
	local proj = Tool.Projectile:Clone()
	proj.Disabled = false
	proj.Parent = arrow
	
	Handle.Hit:Clone().Parent = arrow
	
	return arrow
end

function waterExplosion(point)
	local scale = 8 + (4 * math.random(1, 3))
	local terrain = workspace.Terrain
	for dx = -scale, scale, 4 do
		for dy = -scale, scale, 4 do
			for dz = -scale, scale, 4 do
				if Vector3.new(dx, dy, dz).magnitude <= scale then
					local v = terrain:WorldToCell(point + Vector3.new(dx, dy, dz))
					local x, y, z = v.x, v.y, v.z
					local material, block, orientation = terrain:GetCell(x, y, z)
					
					if material == Enum.CellMaterial.Empty then
						terrain:SetCell(x, y, z, "Water", "Solid", "Z")
						delay(3, function()
							terrain:SetCell(x, y, z, material, block, orientation)
						end)
					end
				end
			end
		end
	end
end

function onLeftDown(targetPoint)
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackReloadTime, function()
		AttackAble = true
		Handle.Mesh.MeshId = "rbxassetid://235107630"
	end)
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Fire", 0)
	Handle.Mesh.MeshId = "rbxassetid://235107551"
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
		waterExplosion(arrow.Position)
		
		arrow.Anchored = true
		arrow.CanCollide = false
		arrow.Transparency = 1
		arrow.Hit:Play()
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