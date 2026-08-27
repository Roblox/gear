-- Waits for parent.child to exist then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Weld = WaitForChild(script, 'ChildToMother')

local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		if subject:FindFirstChild('Humanoid') then
			return subject
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

if Weld and Weld:IsA('JointInstance') then
	local originalParent = Weld.Parent
	local characterAncestor = FindCharacterAncestor(originalParent)
	Weld.AncestryChanged:connect(function(child, parent)
		if child == Weld and parent ~= originalParent then
			if characterAncestor and characterAncestor.Humanoid.Health <= 0 then return end
			wait(0) -- Have to wait for the parent to finish being set
			Weld.Parent = originalParent
		end
	end)
end
