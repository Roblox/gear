local Tool = script.Parent

local BeginTransform = Tool:WaitForChild('BeginTransform')
local RunLocal_SSTool = Tool:WaitForChild('RunLocal_SSTool')

local Handle = Tool:WaitForChild('Handle')
local Mesh = Handle:WaitForChild('Mesh')

-- Fix up the grip / mesh from the profile one
Tool.Grip = CFrame.new(-0.4,0,0) * CFrame.Angles(1.5, 1.7, 0.3) * CFrame.Angles(0.2, 0, 0)
Mesh.MeshId = 'rbxassetid://168892363'

Tool.Equipped:connect(function(mouse)
	local character = Tool.Parent
	mouse.Button1Down:connect(function()
		if not character:FindFirstChild('RunLocal_SSTool') then
			local clone = RunLocal_SSTool:Clone()
			clone.Disabled = false
			clone.Parent = character
			--
			BeginTransform:InvokeServer()
		end
	end)
end)