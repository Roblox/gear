local Players = Game:GetService('Players')

local Tool = script.Parent
local Player, Character, Backpack;
local Equipped = false
local Debounce = false

local RunGlobal_SSTool = Tool:WaitForChild('RunGlobal_SSTool')
local BeginTransform = Tool:WaitForChild('BeginTransform')

local Handle = Tool:WaitForChild('Handle')
local Mesh = Handle:WaitForChild('Mesh')

-- Fix up the grip / mesh from the profile one
Tool.Grip = CFrame.new(-0.4,0,0) * CFrame.Angles(1.5, 1.7, 0.3) * CFrame.Angles(0.2, 0, 0)
Mesh.MeshId = 'rbxassetid://168892363'

BeginTransform.OnServerInvoke = function(player)
	if not Equipped or Debounce then return end	
	
	-- Someone else called the invoke??
	if player ~= Player then return end
	
	Debounce = true
	
	-- Clone the transform begin into the character to run the transformation
	local clone = RunGlobal_SSTool:Clone()
	clone.Disabled = false
	clone.Parent = Character
end

Tool.Equipped:connect(function()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Equipped = true
end)

Tool.Unequipped:connect(function()
	Equipped = false
end)