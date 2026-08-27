local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Mesh = Handle:WaitForChild("Mesh")

local Remote = Tool:WaitForChild("Remote")

local R = math.random

local Meshes = {
	"http://www.roblox.com/asset/?id=181202592",
	"http://www.roblox.com/asset/?id=181202617",
	"http://www.roblox.com/asset/?id=181209030",
}
local MeshIndex = 1
local MaxMeshIndex = #Meshes
local MeshSwitchTime = 1/3
local MeshSwitchTimer = MeshSwitchTime

local Neons = {
	Color3.new(1, 0, 0),
	Color3.new(0, 1, 0),
	Color3.new(0, 0, 1),
	Color3.new(1, 1, 0),
	Color3.new(1, 0, 1),
	Color3.new(0, 1, 1),
}

local HBConnection
local Heartbeat = game:GetService("RunService").Heartbeat

local Damage = 12.5
local ReloadTime = 0.25
local ReloadTimer = 0
local Reloading = false

local Projectiles = {}



function getPlayer()
	local char = Tool.Parent
	return game:GetService("Players"):GetPlayerFromCharacter(char)
end

function handleMeshSwitch(dt)
	MeshSwitchTimer = MeshSwitchTimer - dt
	if MeshSwitchTimer <= 0 then
		MeshIndex = MeshIndex + 1
		if MeshIndex > MaxMeshIndex then
			MeshIndex = 1
		end
		
		Mesh.MeshId = Meshes[MeshIndex]
				
		MeshSwitchTimer = MeshSwitchTime
	end
end

function handleReload(dt)
	if Reloading then
		Handle.Transparency = 1
		
		ReloadTimer = ReloadTimer - dt
		if ReloadTimer < 0 then
			Reloading = false
		end
	else
		Handle.Transparency = 0
	end
end

function onTick(dt)
	handleMeshSwitch(dt)
	handleReload(dt)
end

function onEquipped()
	onUnequipped()
	
	HBConnection = Heartbeat:connect(onTick)
end

function onUnequipped()
	if HBConnection then
		HBConnection:disconnect()
	end
end

function playSound(name, pitch)
	local sound = Handle:FindFirstChild(name)
	if sound then
		sound.Pitch = pitch or math.random(90, 110)/100
		sound:Play()
	end
end

function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function reload()
	Reloading = true
	ReloadTimer = ReloadTime
end

function attack(targetPosition)
	if Reloading then return end
	reload()
	
	local launchPosition = Handle.CFrame:pointToWorldSpace(Vector3.new(0, 0, -1))
	local vector = targetPosition - launchPosition
	
	local projectile = Handle:Clone()
	projectile.CFrame = CFrame.new(launchPosition, targetPosition)
	
	local bv = Instance.new("BodyVelocity")
	bv.velocity = vector.unit * 96
	bv.Parent = projectile
	
	local fire = Instance.new("Fire")
	fire.Size = 2
	fire.Color = Neons[math.random(1, #Neons)]
	fire.SecondaryColor = fire.Color
	fire.Parent = projectile
	
	local touched
	touched = projectile.Touched:connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		if contains(Projectiles, part) then return end
		
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local human = part.Parent.Humanoid
			tagHuman(human)
			human:TakeDamage(Damage)
		end
		
		local delta = part.CFrame:toObjectSpace(projectile.CFrame)
		local w = Instance.new("Weld")
		w.Part0 = part
		w.Part1 = projectile
		w.C0 = delta
		w.Parent = w.Part0
		
		projectile.CanCollide = false
		fire.Enabled = false
		bv:Destroy()
		
		touched:disconnect()
	end)
	
	projectile.Parent = workspace
	game:GetService("Debris"):AddItem(projectile, 10)
	
	table.insert(Projectiles, projectile)
	
	playSound("ThrowSound")
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Throw")
end

function main()	
	Tool.Equipped:connect(onEquipped)
	Tool.Unequipped:connect(onUnequipped)
	
	Remote.OnServerEvent:connect(function(player, func, ...)
		if player ~= getPlayer() then return end
		
		local args = {...}
		
		if func == "Attack" then
			attack(args[1])
		end
	end)
	
	for _, obj in pairs(Tool:GetChildren()) do
		if obj.Name == "Graphics" then
			obj:Destroy()
		end
	end
end

main()