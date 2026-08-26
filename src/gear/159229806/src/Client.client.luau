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


local function HasPeri(PeriName)
	return (Player:FindFirstChild("Backpack") and Player:FindFirstChild("Backpack"):FindFirstChild(PeriName.."Periastron") and true) or false
end

function PeriPrimary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.E)
	end
end

function PeriSecondary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.Q)
	end
end


function PeriTertiary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.R)
	end
end

function PeriQuaternary(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then 
		Remote:FireServer(Enum.KeyCode.X)
	end
end

function Equipped()
	Player = Services.Players.LocalPlayer
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end
	
	Services.Input:BindAction("PeriPrimary",PeriPrimary,HasPeri("Chartreuse"),Enum.KeyCode.E,Enum.KeyCode.ButtonX)
	Services.Input:BindAction("PeriSecondary",PeriSecondary,true,Enum.KeyCode.Q,Enum.KeyCode.ButtonY)
	Services.Input:BindAction("PeriTertiary",PeriTertiary,HasPeri("Hazel"),Enum.KeyCode.R,Enum.KeyCode.ButtonR2)
	Services.Input:BindAction("PeriQuaternary",PeriQuaternary,HasPeri("Amethyst"),Enum.KeyCode.X,Enum.KeyCode.ButtonL2)
	Services.Input:SetTitle("PeriPrimary","Pulse")
	Services.Input:SetTitle("PeriSecondary","Peri-laser")
	Services.Input:SetTitle("PeriTertiary","Rock Lift")
	Services.Input:SetTitle("PeriQuaternary","Singularity")
	Services.Input:SetPosition("PeriPrimary",UDim2.new(0.4,0,-.3,0))
	Services.Input:SetPosition("PeriSecondary",UDim2.new(.7,0,-.3,0))
	Services.Input:SetPosition("PeriTertiary",UDim2.new(0.4,0,0,0))
	Services.Input:SetPosition("PeriQuaternary",UDim2.new(.7,0,0,0))
end

function Unequipped()
	Services.Input:UnbindAction("PeriPrimary")
	Services.Input:UnbindAction("PeriSecondary")
	Services.Input:UnbindAction("PeriTertiary")
	Services.Input:UnbindAction("PeriQuaternary")	
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)


function MouseInput.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end