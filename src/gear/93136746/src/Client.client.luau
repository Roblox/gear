local Tool = script.Parent

local Remote = Tool:WaitForChild("Remote",10)

local MouseInput = Tool:WaitForChild("MouseLoc",10)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))
}

local Player,Character,Humanoid


function TelaPrimary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.Q)
	end
end

function TelaSecondary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.E)
	end
end


function Equipped()
	Player = Services.Players.LocalPlayer
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end
	
	Services.Input:BindAction("TelaPrimary",TelaPrimary,true,Enum.KeyCode.Q,Enum.KeyCode.ButtonX)
	Services.Input:BindAction("TelaSecondary",TelaSecondary,true,Enum.KeyCode.E,Enum.KeyCode.ButtonY)
	Services.Input:SetTitle("TelaPrimary","Chaos Cluster")
	Services.Input:SetTitle("TelaSecondary","Unwing Flyers")
	Services.Input:SetPosition("TelaPrimary",UDim2.new(.5,0,-.5,0))
	Services.Input:SetPosition("TelaSecondary",UDim2.new(.5,0,0,0))
end

function Unequipped()
	Services.Input:UnbindAction("TelaPrimary")
	Services.Input:UnbindAction("TelaSecondary")		
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)


function MouseInput.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end