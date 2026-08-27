function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local Handle = script.Parent
local Tool = Handle.Parent
local Humanoid
local Animation

local animation = WaitForChild(Tool, "wandcast")

function onEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Animation = Humanoid:LoadAnimation(animation)
end

local wasEnabled = false
function onChanged() -- A prime example of garbage.
	if Tool.Enabled and not wasEnabled then
		wasEnabled = true
		Animation = Tool.Parent:FindFirstChild'Humanoid' and Tool.Parent.Humanoid:LoadAnimation(animation)
		
		if Animation then
			Animation:Play()
		end
	elseif not Tool.Enabled and wasEnabled then
		wasEnabled = false
	end
end

function onUnequipped()
	if Animation then Animation:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Changed:connect(onChanged)
Tool.Unequipped:connect(onUnequipped)
