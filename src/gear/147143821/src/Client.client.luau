--Rescripted by TakeoHonorable

local Tool = script.Parent


local Remote = Tool:WaitForChild("ThrowAxe")

local MouseLoc = Tool:WaitForChild("MouseLoc")

local Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))

local function ThrowAxe(ActionName,InputState,InputObj)
	if InputState == Enum.UserInputState.Begin then
		Remote:InvokeServer(InputObj.KeyCode)
	end
end


function MouseLoc.OnClientInvoke()
	return game:GetService("Players").LocalPlayer:GetMouse().Hit.p
end

function Unequipped()
	Input:UnbindAction("ThrowAxe")
end

function Equipped()
	Input:BindAction("ThrowAxe",ThrowAxe,false,Enum.KeyCode.Q)
end



Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
