-- // Created by StarWars
local ContextActionService = game:GetService("ContextActionService")

local Tool = script.Parent
local R15Hold = Tool:WaitForChild("R15Hold")
local Hold = Tool:WaitForChild("Hold")

local ToolEquipped = false

local Humanoid = nil

local CurrentAnimation = nil

function Equipped()
	if ToolEquipped then return end 
	ToolEquipped = true
	
	local Character = Tool.Parent
	
	Humanoid = Character:FindFirstChildOfClass("Humanoid")	
	
	ContextActionService:BindActionAtPriority("HoldShield", function(ActionName, InputState, InputObject)
		if InputState == Enum.UserInputState.Begin then
			local Animation = Hold
			if Humanoid then
				if Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = R15Hold
				end
				
				CurrentAnimation = Humanoid:LoadAnimation(Animation)
				CurrentAnimation:Play()
				print("Play")
			end
		elseif InputState == Enum.UserInputState.End then
			if CurrentAnimation then
				CurrentAnimation:Stop()
			end
			CurrentAnimation = nil
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton2)
end

function Unequipped()
	if not ToolEquipped then return end
	ToolEquipped = false
	ContextActionService:UnbindAction("HoldShield")
	if CurrentAnimation then
		CurrentAnimation:Stop()
	end
	
	CurrentAnimation = nil
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)