local Tool = script.Parent
local Mouse = nil

local event = Tool:WaitForChild('CampfireEvent')


local function OnActivated()
	if Mouse then
		local character = Tool.Parent
		if character then
			local humanoid = character:FindFirstChild('Humanoid')
			if humanoid and not humanoid.Sit then	-- Don't let them create a new campfire if they're already sitting at one
				event:FireServer(Mouse.Hit)
			end
		end	
	end
end

local function OnEquipped(mouse)
	if mouse then
		Mouse = mouse
	end
end

local function OnUnequipped()
end

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
