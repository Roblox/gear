function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local character = script.Parent
local Humanoid = WaitForChild(character, "Humanoid")
local IceSound = WaitForChild(script, "IceSound")

local charParts = {}
local freezeParts = {}


local iceMesh = WaitForChild(script, "IceMesh")

local iceBall = Instance.new("Part")
iceBall.formFactor = "Custom"
iceBall.Size = Vector3.new(0.2, 0.2, 0.2)
iceBall.CanCollide = false
iceBall.Anchored = true
iceBall.Transparency = .5
iceMesh:Clone().Parent = iceBall

-- add all the parts in the character (or his hats) to charParts
local charChildren = character:GetChildren()
for i = 1, #charChildren do
	if charChildren[i]:IsA("Hat") then
		local hatChildren = charChildren[i]:GetChildren()
		for j = 1, #hatChildren do
			if hatChildren[j]:IsA("BasePart") then table.insert(charParts, hatChildren[j]) end
		end
	elseif charChildren[i]:IsA("BasePart") then
		table.insert(charParts, charChildren[i])
	end
end


-- freeze all the parts
Humanoid.WalkSpeed = 0

for i = 1, #charParts do
	charParts[i].Anchored = true

	local newFreezePart = iceBall:Clone()
	newFreezePart.IceMesh.Scale = newFreezePart.IceMesh.Scale * charParts[i].Size
	newFreezePart.CFrame = charParts[i].CFrame
	newFreezePart.Parent = workspace

	table.insert(freezeParts, newFreezePart)
end



wait(4)



-- unfreeze all the parts
for i = 1, #freezeParts do
	freezeParts[i].Anchored = false
	freezeParts[i].Velocity = 25 * Vector3.new(math.random()-.5, 1, math.random()-.5)
	freezeParts[i].RotVelocity = 2 * Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)
end

for i = 1, #charParts do
	charParts[i].Anchored = false
end

IceSound:Play() 
wait(.45) 
IceSound:Stop()

Humanoid.WalkSpeed = 16

script:Remove()
