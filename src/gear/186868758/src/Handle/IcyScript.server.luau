local icyColors = {"Pastel blue", "Light blue", "Bright bluish-green"}
local function icyColor()
	return BrickColor.new(icyColors[math.random(1, #icyColors)])
end

local function lineBetween(a, b)
	local part = Instance.new("Part")
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	part.Anchored = true
	part.CanCollide = false
	part.FormFactor = "Symmetric"
	part.Size = Vector3.new(1, 1, 1)
	local mesh = Instance.new("CylinderMesh")
	mesh.Parent = part
	
	part.BrickColor = icyColor()
	part.Transparency = 0.5 + math.random() * 0.25
	part.Material = "Ice"
	
	local mid = (a + b) / 2
	local len = (b - a).magnitude
	part.CFrame = CFrame.new(mid, b) * CFrame.Angles(-math.pi/2, 0, 0)
	mesh.Scale = Vector3.new(0.5, len, 0.5)
	part.Parent = workspace
	game:GetService("Debris"):AddItem(part, 0.25)
end

local function icePatch(position)
	local part = Instance.new("Part")
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	part.Anchored = true
	part.CanCollide = false
	part.FormFactor = "Custom"
	part.Size = Vector3.new(math.random() * 3, 0.2, math.random() * 3)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, math.random() * math.pi * 2, 0)
	part.BrickColor = icyColor()
	part.Transparency = 0.5 + math.random() * 0.25
	part.Material = "Ice"
	part.Parent = workspace
	game:GetService("Debris"):AddItem(part, 0.25)
end

local part = script.Parent
local lastPos = nil
local heartbeat = game:GetService("RunService").Heartbeat
local threshold = 18.5

local function getSpawnPos()
	return part.CFrame:pointToWorldSpace(Vector3.new(0, 1, 0))
end

while heartbeat:wait() do
	--only do this in the character
	if part.Parent.Parent:IsA("Model") then
		--get the new positon
		local newPos = getSpawnPos()
		
		if lastPos then
			--trail
			local speed = part.Velocity.magnitude
			if speed > threshold then
				lineBetween(lastPos, newPos)
			end
			
			--patches
			if math.abs(newPos.Y-lastPos.Y) < 0.15 then
				local char = part.Parent.Parent
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					local foot = root.Position - Vector3.new(0, 3, 0)
					icePatch(foot)
				end
			end
		end
		
		--set the old position for next iteration
		lastPos = newPos
	end
end
