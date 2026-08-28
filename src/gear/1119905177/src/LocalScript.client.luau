local Player = game.Players.LocalPlayer

local Character = nil
local Humanoid = nil

local Tool = script.Parent
local Animations = Tool:WaitForChild("Animations")

local R6 = Animations:WaitForChild("R6")
local R15 = Animations:WaitForChild("R15")

local R15HoldAnimation = R15:WaitForChild("Hold")
local HoldAnimation = R6:WaitForChild("Hold")

local CurrentAnimation = nil

function OnEquipped()
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end
	
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		CurrentAnimation = Humanoid:LoadAnimation(R15HoldAnimation)
	elseif Humanoid.RigType == Enum.HumanoidRigType.R6 then
		CurrentAnimation = Humanoid:LoadAnimation(HoldAnimation)
	end
	
	if CurrentAnimation then
		CurrentAnimation:Play()
	end
end

function OnUnequipped()
	if CurrentAnimation then
		CurrentAnimation:Stop()
		CurrentAnimation = nil
	end
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)