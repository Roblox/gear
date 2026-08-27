local Tool = script.Parent

local VariableFolder = Tool:WaitForChild("Variables",10)

local Remote = Tool:WaitForChild("Remote",10)

local MouseInput = Tool:WaitForChild("MouseInput",10)

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))
}

local Player,Character,Humanoid


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


function Equipped()
	Player = Services.Players.LocalPlayer
	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid or not Humanoid.Parent or Humanoid.Health <= 0 then return end
	
	Services.Input:BindAction("PeriPrimary",PeriPrimary,true,Enum.KeyCode.E,Enum.KeyCode.ButtonX)
	Services.Input:BindAction("PeriSecondary",PeriSecondary,true,Enum.KeyCode.Q,Enum.KeyCode.ButtonY)
	Services.Input:SetTitle("PeriPrimary","Sword Stance/Counter")
	Services.Input:SetTitle("PeriSecondary","Twirl Sword")
	Services.Input:SetPosition("PeriPrimary",UDim2.new(.5,0,-.5,0))
	Services.Input:SetPosition("PeriSecondary",UDim2.new(.5,0,0,0))
end
local SavedToolAnim

function Unequipped()
	Services.Input:UnbindAction("PeriPrimary")
	Services.Input:UnbindAction("PeriSecondary")
	Services.RunService.Heartbeat:Wait()
	if Character and Character:FindFirstChildOfClass("Tool") and SavedToolAnim then
		repeat
			SavedToolAnim:Play()
		until SavedToolAnim.IsPlaying
	else
		if SavedToolAnim then 
			SavedToolAnim:Stop() 
			SavedToolAnim = nil
		end
	end
		
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)



local ToolAnimValue = VariableFolder:WaitForChild("ToolAnim")
ToolAnimValue.Changed:Connect(function(property)
	if not ToolAnimValue.Value then
		spawn(function()
			--print("Loop started")
			repeat
				for i, v in pairs(Humanoid:GetPlayingAnimationTracks()) do --Disable default tool hold pose
					if string.find(string.lower(v.Name), string.lower("Tool")) then
						SavedToolAnim = v
						v:Stop()
					end
				end
				Services.RunService.RenderStepped:Wait()
			until ToolAnimValue.Value or not Tool:IsDescendantOf(Character)
			--print("Stopping loop")
		end)
	else
		if SavedToolAnim and Tool:IsDescendantOf(Character) then
			SavedToolAnim:Play()
		end
	end
end)

function MouseInput.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end