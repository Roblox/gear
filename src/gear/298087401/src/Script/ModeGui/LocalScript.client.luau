--Made by Luckymaxer

Gui = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

MainFrame = Gui:WaitForChild("MainFrame")
Button = MainFrame:WaitForChild("Button")

ServerConnection = Gui:WaitForChild("ServerConnection").Value
Tool = Gui:WaitForChild("Tool").Value

function InvokeServer(mode, value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerConnection:InvokeServer(mode, value)
	end)
	return ServerReturn
end

Button.MouseButton1Click:connect(function()
	InvokeServer("KeyPress", {Key = "q", Down = true})
end)

if Tool and Tool.Parent then
	Tool.Changed:connect(function(Property)
		if Property == "Parent" then
			if not Tool.Parent or not Tool.Parent:IsA("Backpack") or not Players:GetPlayerFromCharacter(Tool.Parent) then
				Debris:AddItem(Gui, 1.5)
			end
		end
	end)
end