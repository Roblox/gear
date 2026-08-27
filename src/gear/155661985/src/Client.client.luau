Mouse_Icon = "rbxasset://textures/GunCursor.png"
Reloading_Icon = "rbxasset://textures/GunWaitCursor.png"

Tool = script.Parent
local Input = (game:FindService("UserInputService") or game:GetService("UserInputService"))
local Remote = Tool:WaitForChild("Remote")
local InputConnection
Mouse = nil

function UpdateIcon()
	if Mouse then
		Mouse.Icon = Tool.Enabled and Mouse_Icon or Reloading_Icon
	end
end

function OnEquipped(ToolMouse)
	InputConnection = Input.InputBegan:Connect(function(InputObject,Processed)
		if InputObject.UserInputType == Enum.UserInputType.Keyboard then
			if InputObject.KeyCode == Enum.KeyCode.Q then
				if Remote then
					Remote:FireServer(InputObject.KeyCode)
				end
			end
		end
	end)
	Mouse = ToolMouse
	UpdateIcon()
end

function OnChanged(Property)
	if Property == "Enabled" then
		UpdateIcon()
	end
end

function OnUnequipped()
	if InputConnection then InputConnection:Disconnect() end
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
Tool.Changed:Connect(OnChanged)
