local Tool = script.Parent

local ServerControls = Tool:WaitForChild("ServerControls")
local Animations = Tool:WaitForChild("Animations")
local R6Folder = Animations:WaitForChild("R6")
local R15Folder = Animations:WaitForChild("R15")

local Character = nil
local Humanoid = nil

local MoonWalkAnim = nil

ServerControls.OnClientEvent:Connect(function()
	if not MoonWalkAnim then return end

	MoonWalkAnim:Play(0.1, 1, 2)
end)

function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			MoonWalkAnim = Humanoid:LoadAnimation(R15Folder:WaitForChild("moonwalk"))
		else
			MoonWalkAnim = Humanoid:LoadAnimation(R6Folder:WaitForChild("moonwalk"))
		end
	end
end

function OnUnequipped()
	Character = nil
	Humanoid = nil
	if MoonWalkAnim then
		MoonWalkAnim:Stop()
		MoonWalkAnim:Destroy()
	end

	MoonWalkAnim = nil
end

Tool.Unequipped:Connect(OnUnequipped)
Tool.Equipped:Connect(OnEquipped)