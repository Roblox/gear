local Tool = script.Parent

local Remote = Tool:WaitForChild("Remote",10)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))
}

local Player,Character,Humanoid


function Primary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.X)
	end
end

function Equipped()
	Player = Services.Players.LocalPlayer
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end
	
	Services.Input:BindAction("Primary",Primary,true,Enum.KeyCode.X,Enum.KeyCode.ButtonX)
	Services.Input:SetTitle("Primary","Quake")
	Services.Input:SetPosition("Primary",UDim2.new(.5,0,-.5,0))
end

function Unequipped()
	Services.Input:UnbindAction("Primary")	
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)