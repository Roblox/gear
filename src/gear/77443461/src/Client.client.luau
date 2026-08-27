local Tool = script.Parent

local Remote = Tool:WaitForChild("Remote",10)

local MouseInput = Tool:WaitForChild("MouseInput",10)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))
}

local Player,Character,Humanoid


function Primary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.Q)
	end
end

function Secondary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.E)
	end
end


function Equipped()
	Player = Services.Players.LocalPlayer
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end
	
	Services.Input:BindAction("Primary",Primary,true,Enum.KeyCode.Q,Enum.KeyCode.ButtonX)
	Services.Input:BindAction("Secondary",Secondary,true,Enum.KeyCode.E,Enum.KeyCode.ButtonY)
	Services.Input:SetTitle("Primary","Time Change")
	Services.Input:SetTitle("Secondary","Light Travel")
	Services.Input:SetPosition("Primary",UDim2.new(.5,0,-.5,0))
	Services.Input:SetPosition("Secondary",UDim2.new(.5,0,0,0))
end

function Unequipped()
	Services.Input:UnbindAction("Primary")
	Services.Input:UnbindAction("Secondary")		
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)


function MouseInput.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end