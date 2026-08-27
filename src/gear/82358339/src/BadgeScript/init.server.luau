local function WaitForChild(parent,name)
	while not parent:FindFirstChild(name) do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end


local reloadTime = 8

local Tool = script.Parent

local freezeScript = WaitForChild(script,"FreezeScript")


local running = false

function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		Tool.Enabled = true
		return 
	end

	Tool.Handle.FreezeSound:play()

	local targetPos = humanoid.TargetPoint

	local direction = (targetPos - Tool.Handle.Position).unit
	local minRange = 3
	local maxRange = 150

	local hit = game.Workspace:FindPartOnRay(Ray.new(Tool.Handle.Position + direction * minRange, direction * maxRange), vCharacter)


	if hit and hit.Parent then
		local humTarget = hit.Parent:FindFirstChild("Humanoid")
		if humTarget and humTarget ~= humanoid then	
			local freezeCopy = freezeScript:Clone()
			freezeCopy.Parent =  hit.Parent
			freezeCopy.Disabled = false
			wait(reloadTime/2)
		end
	end
	

	wait(reloadTime/2)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
