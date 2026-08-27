local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=204023449"

local FriendlyFire = false

local ArrowMeshData = "http://www.roblox.com/asset/?id=204023415"
local ArrowTextureData = "http://www.roblox.com/asset/?id=204023580"

local AttackAble = true
local AttackReloadTime = 1.5
local AttackReloadTimeMax = 1.5
local AttackReloadTimeMin = 0.08
local AttackReloadTimeDecrease = 0.4
local AttackReloadIncreaseRate = AttackReloadTimeDecrease/(AttackReloadTimeMax + 0.5)
local AttackRoarThreshold = AttackReloadTimeDecrease
local AttackLastReloadTime = 0
local AttackDamage = 4
local AttackSpeed = 128
local AttackArrows = {}

local LoopConnection = nil
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
		return player.TeamColor == otherPlayer.TeamColor
	end
	return false
end

--use this to determine if you want this human to be harmed or not, returns boolean
function checkTeams(otherHuman)
	return not (sameTeam(otherHuman) and not FriendlyFire)
end

function loop(dt)
	AttackReloadTime = AttackReloadTime + AttackReloadIncreaseRate * dt
	if AttackReloadTime > AttackReloadTimeMax then
		AttackReloadTime = AttackReloadTimeMax
	end
	
	if AttackLastReloadTime > AttackRoarThreshold and AttackReloadTime < AttackRoarThreshold then
		Handle.Roar:Play()
	end
	
	AttackLastReloadTime = AttackReloadTime
end

function createArrow()
	local part = Instance.new("Part")
	part.FormFactor = "Custom"
	part.Size = Vector3.new(0.2, 0.2, 3)
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	part.CanCollide = false
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = ArrowMeshData
	mesh.TextureId = ArrowTextureData
	mesh.Parent = part
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 196.2, 0) * part:GetMass() * 0.7
	lift.Parent = part
	
	local projectileScript = Tool.Projectile:Clone()
	projectileScript.Disabled = false
	projectileScript.Parent = part
	
	if AttackReloadTime < AttackRoarThreshold then
		local fire = Instance.new("Fire")
		fire.Size = 1
		fire.Parent = part
	end
	
	return part
end

function onLeftDown(mousePos)
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackReloadTime, function()
		AttackAble = true
	end)
	AttackReloadTime = AttackReloadTime - AttackReloadTimeDecrease
	if AttackReloadTime < AttackReloadTimeMin then
		AttackReloadTime = AttackReloadTimeMin
	end
	
	local arrow = createArrow()
	arrow.CFrame = CFrame.new((Handle.CFrame * CFrame.new(0, 0.2, -2)).p, mousePos) * CFrame.new(0, 0, -arrow.Size.Z/2)
	arrow.Velocity = arrow.CFrame.lookVector * AttackSpeed
	
	local touched
	touched = arrow.Touched:connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		if contains(AttackArrows, part) then return end
		
		arrow.Projectile:Destroy()
		
		local w = Instance.new("Weld")
		w.Part0 = part
		w.Part1 = arrow
		w.C0 = part.CFrame:toObjectSpace(arrow.CFrame)
		w.Parent = w.Part0
		
		touched:disconnect()
		
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local human = part.Parent.Humanoid
			if checkTeams(human) then
				tagHuman(human)
				human:TakeDamage(AttackDamage)
			end
		end
	end)
	
	table.insert(AttackArrows, arrow)
	arrow.Parent = workspace
	game:GetService("Debris"):AddItem(arrow, 1.5)
	
	local sound = Handle.Shot
	sound.Pitch = math.random(90, 110)/100
	sound:Play()
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

function onEquip()
	onUnequip()
	
	LoopConnection = Heartbeat:connect(loop)
end

function onUnequip()
	if LoopConnection then
		LoopConnection:disconnect()
	end
	
	AttackReloadTime = AttackReloadTimeMax
end

Remote.OnServerEvent:connect(onRemote)
Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
