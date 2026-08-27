local Tool = script.Parent

local Remote = Tool:WaitForChild("Remote",10)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))
}

local Player,Character,Humanoid


function IceBreakerPrimary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.Q)
	end
end

function Equipped()
	Player = Services.Players.LocalPlayer
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end
	
	Services.Input:BindAction("IceBreakerPrimary",IceBreakerPrimary,true,Enum.KeyCode.Q,Enum.KeyCode.ButtonY)
	Services.Input:SetTitle("IceBreakerPrimary","Sub-Zero")
	Services.Input:SetPosition("IceBreakerPrimary",UDim2.new(.5,0,-.5,0))
end

function Unequipped()
	Services.Input:UnbindAction("IceBreakerPrimary")		
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
