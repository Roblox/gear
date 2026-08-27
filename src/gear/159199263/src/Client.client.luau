local Tool = script.Parent
local connection
local Input = (game:FindService("UserInputService") or game:GetService("UserInputService"))
local Remote = Tool:WaitForChild("Remote")
local InputConnection


function onEquippedL(mouse)
	InputConnection = Input.InputBegan:Connect(function(InputObject,Processed)
		if InputObject.UserInputType == Enum.UserInputType.Keyboard then
			if InputObject.KeyCode == Enum.KeyCode.Q then
				if Remote then
					Remote:FireServer(InputObject.KeyCode)
				end
			end
		end
	end)
end

Tool.Unequipped:Connect(function()
	if InputConnection then InputConnection:Disconnect() end
end)
Tool.Equipped:Connect(onEquippedL)