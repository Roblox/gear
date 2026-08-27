-- Quick fix, update this to be something better in the future
local Tool = script.Parent 

local Character = nil 
local Humanoid = nil 

local RemoteFunction = Tool:WaitForChild("RemoteFunction")

function RemoteFunction.OnClientInvoke()
	if not Humanoid then return end 
	
	return Humanoid.TargetPoint
end

function Equipped()
	Character = Tool.Parent 
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

function Unequipped()
	Character = nil
	Humanoid = nil 
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
