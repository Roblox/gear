--Updated for R15 avatar by StarWars

local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")
local Heartbeat = game:GetService("RunService").Heartbeat

Handle.Transparency = 1

local Equipping = false
local Equipped = false

local Feet = {}
local FootFrame = CFrame.new(0, -0.7, 0)

local FlowerTime = 0.25

function getPlayer()
	local char = Tool.Parent
	return game:GetService("Players"):GetPlayerFromCharacter(char)
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
	local tag = Instance.new("ObjectValue")
	tag.Value = getPlayer()
	tag.Name = "creator"
	tag.Parent = human
	game:GetService("Debris"):AddItem(tag)
end

function flower(pos)
	local flower = Instance.new("Part")
	flower.FormFactor = "Custom"
	flower.Anchored = true
	flower.CanCollide = false
	flower.Size = Vector3.new(0.2, 0.2, 0.2)
	flower.CFrame = CFrame.new(
		pos,
		pos + Vector3.new(
			math.random(-8, 8),
			-32,
			math.random(-8, 8)
		)
	)
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = "rbxassetid://225072270"
	mesh.TextureId = "rbxassetid://225072517"
	mesh.Scale = Vector3.new(0, 0, 0)
	mesh.Parent = flower
	
	flower.Parent = workspace
	game:GetService("Debris"):AddItem(flower, 5)
	
	spawn(function()
		local size = math.random() * 2
		while mesh.Scale.X < size do
			mesh.Scale = mesh.Scale + Vector3.new(1, 1, 1) * Heartbeat:wait()
		end
	end)
end

function onEquip()
	if Equipping then return end
	
	Equipping = true
	Equipped = true
	
	--attach the feet
	local foot = Handle:Clone()
	foot.Mesh.MeshId = "http://www.roblox.com/asset/?id=223832574"
	foot.Transparency = 0
	foot.CanCollide = false
	
	local right, left
	
	local char = Tool.Parent	
	if char then
		local humanoid = char:FindFirstChild("Humanoid")
	
		if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
			FootFrame = CFrame.new(0, 0.1, 0)
		end	
		local lleg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftFoot")
		if lleg then
			left = foot:Clone()
			left.Parent = char
			
			local weld = Instance.new("Weld")
			weld.Part0 = lleg
			weld.Part1 = left
			weld.C0 = FootFrame
			weld.Parent = weld.Part0
			
			table.insert(Feet, left)
		end
		
		local rleg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightFoot")
		if rleg then
			right = foot:Clone()
			right.Parent = char
			
			foot.Mesh.MeshId = "rbxassetid://223832617"
			
			local weld = Instance.new("Weld")
			weld.Part0 = rleg
			weld.Part1 = right
			weld.C0 = FootFrame
			weld.Parent = weld.Part0
			
			table.insert(Feet, right)
		end
	end
	
	Equipping = false
	
	local leftTimer = FlowerTime
	local rightTimer = 0
	while Equipped do
		local dt = Heartbeat:wait()
		
		leftTimer = leftTimer - dt
		if leftTimer <= 0 then
			flower(left.Position)
			leftTimer = FlowerTime
		end
		
		rightTimer = rightTimer - dt
		if rightTimer <= 0 then
			flower(right.Position)
			rightTimer = FlowerTime
		end
	end
end

function onUnequip()
	Equipped = false
	
	for _, foot in pairs(Feet) do
		foot:Destroy()
	end
	Feet = {}
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)