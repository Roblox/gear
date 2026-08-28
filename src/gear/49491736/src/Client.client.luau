--Rescripted by TakeoHonorable

local Tool = script.Parent

local Remote = Tool:WaitForChild("ClientInput")
--local MouseLoc = Tool:WaitForChild("MouseLoc")

local Input = (game:FindService("ContextActionService") or game:GetService("ContextActionService"))

local function SetSpell(ActionName,InputState,InputObj)
	if InputState == Enum.UserInputState.Begin then
		Remote:FireServer(InputObj.KeyCode)
	end
end


function Unequipped()
	Input:UnbindAction("SetFirstSpell")
	Input:UnbindAction("SetSecondSpell")
	Input:UnbindAction("SetThirdSpell")
	Input:UnbindAction("SetFourthSpell")
end

function Equipped()
	Input:BindAction("SetFirstSpell",SetSpell,false,Enum.KeyCode.Q)
	Input:BindAction("SetSecondSpell",SetSpell,false,Enum.KeyCode.E)
	Input:BindAction("SetThirdSpell",SetSpell,false,Enum.KeyCode.R)
	Input:BindAction("SetFourthSpell",SetSpell,false,Enum.KeyCode.X)
end



Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)

--[[function MouseLoc.OnClientInvoke()
	return game:GetService("Players").LocalPlayer:GetMouse().Hit.p
end]]