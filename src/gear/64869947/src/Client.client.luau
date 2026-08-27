--Rescripted by TakeoHonorable

local Tool = script.Parent

local Hold = Tool:WaitForChild("Hold")

local Input = (game:FindService("UserInputService") or game:GetService("UserInputService"))

local MouseLoc = Tool:WaitForChild("MouseLoc")

function MouseLoc.OnClientInvoke()
	return game:GetService("Players").LocalPlayer:GetMouse().Hit.p
end

--[[if Input.TouchEnabled then --Gives mobile users a chance to use this tool
	Input.TouchStarted:Connect(function(inputobj,processed)
		print(inputobj,processed)
	end)
	
	Input.TouchEnded:Connect(function(inputobj,processed)
		
	end)
end]]