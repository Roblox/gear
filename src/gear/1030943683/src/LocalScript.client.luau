local Tool = script.Parent

local R15Dance = Tool:WaitForChild("R15Dance")
local Dance = Tool:WaitForChild("Dance")

local Character = nil
local Humanoid = nil
local Animation = nil

local Dancing = false

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:WaitForChild("Humanoid")
	local Anim = Dance 
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Anim = R15Dance
	end
	Animation = Humanoid:LoadAnimation(Anim)
end

function Unequipped()
	if Animation then
		Animation:Stop()
	end
	Animation = nil
	Humanoid = nil
	Character = nil
end

function Activated()
	if Dancing then return end 
	Dancing = true
	local CacheSpeed = 16
	if Humanoid then
		CacheSpeed = Humanoid.WalkSpeed
	end 
	if Animation then	
		Humanoid.WalkSpeed = 0
		Animation:Play()
	end
	
	wait(3)
	if Humanoid then
		Humanoid.WalkSpeed = CacheSpeed
	end 	
	Dancing = false
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)