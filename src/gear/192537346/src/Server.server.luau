local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")

local AmmoMeshData = "http://www.roblox.com/asset/?id=191294160"

local AttackAble = true
local AttackReloadTime = 0.5

local Penguins = {}

function penguinsOut()
	for index, penguin in pairs(Penguins) do
		if not penguin.Parent then
			table.remove(Penguins, index)
		end
	end
	return #Penguins
end

function R(lower, upper)
	return lower + (upper - lower) * math.random()
end

function createAttackPenguin()
	local part = Instance.new("Part")
	part.FormFactor = "Custom"
	part.Size = Vector3.new(0.6, 0.6, 0.6)
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	part.Material = "SmoothPlastic"
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = AmmoMeshData
	mesh.TextureId = Handle.Mesh.TextureId
	mesh.Parent = part
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 35, 0)
	lift.Parent = part
	part.Touched:connect(function(hit)
		if part:FindFirstChild("Cooldown") then return end
		if hit:IsDescendantOf(Tool.Parent) then return end
		
		if lift.Parent then
			print("Start bouncing")
			lift:Destroy()
			spawn(function()
				while part.Parent do
					wait(0.75)
					part.Velocity = part.Velocity + Vector3.new(R(-10, 10), R(30, 60), R(-10, 10))
				end
			end)
		else
			if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
				local human = hit.Parent.Humanoid
				tagHuman(human)
				human:TakeDamage(10)
				
				local cooldown = Instance.new("BoolValue")
				cooldown.Name = "Cooldown"
				cooldown.Parent = part
				game:GetService("Debris"):AddItem(cooldown, 1)
			end
		end
	end)
	game:GetService("Debris"):AddItem(part, 10)
	
	return part
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function getLaunchPosition()
	return (Handle.CFrame * CFrame.new(0, 0.75, -0.9)).p
end

function onActivate(targetPosition)
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackReloadTime, function()
		AttackAble = true
	end)
	
	if penguinsOut() < 15 then
		local penguin = createAttackPenguin()
		penguin.CFrame = CFrame.new(getLaunchPosition(), targetPosition)
		penguin.Velocity = penguin.CFrame.lookVector * 50
		penguin.Parent = workspace
		table.insert(Penguins, penguin)
	end
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		onActivate(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
