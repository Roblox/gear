--Made by Stickmasterluke
--Rescripted by StarWars

local Tool = script.Parent

local WeaponEvent = Tool:WaitForChild("WeaponEvent")
local Animations = Tool:WaitForChild("Animations")
local R6Folder = Animations:WaitForChild("R6")
local R15Folder = Animations:WaitForChild("R15")

local HoldAnim = nil
local Character = nil
local Humanoid = nil

function OnEquipped(mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			HoldAnim = Humanoid:LoadAnimation(R15Folder:WaitForChild("Hold"))
		else
			HoldAnim = Humanoid:LoadAnimation(R6Folder:WaitForChild("Hold"))
		end
		HoldAnim:Play()
	end

	mouse.Button1Down:Connect(function() WeaponEvent:FireServer(mouse.Hit.p) end)
end

function OnUnequipped()
	Character = nil
	Humanoid = nil
	if HoldAnim then
		HoldAnim:Stop()
		HoldAnim:Destroy()
	end

	HoldAnim = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)