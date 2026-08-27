function waitForChild(parent, childName)
	local child = parent:findFirstChild(childName)
	if child then return child end
   while true do
		child = parent.ChildAdded:wait()
		if child.Name==childName then return child end
   end
end

local Tool = script.Parent

local Explosion = waitForChild(Tool, 'Explosion')
Explosion.Volume = 2.5

function explode()
		if Explosion then
			Explosion:Play()
		end
end

explode()