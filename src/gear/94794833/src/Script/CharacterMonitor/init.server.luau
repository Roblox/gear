--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = script:WaitForChild("Creator")
Model = script:WaitForChild("Model")
Tool = script:WaitForChild("Tool")
FixCamera = script:WaitForChild("FixCamera")

Camera = game:GetService("Workspace").CurrentCamera

Player = Creator.Value
Bat = Model.Value
ToolObject = Tool.Value

Destroyed = false

function DestroyScript(Delay)
	if Delay then
		Debris:AddItem(script, Delay)
	else
		script:Destroy()
	end
end

function FixPlayer(Delay)
	if Destroyed then
		return
	end
	Destroyed = true
	local FixCameraClone = FixCamera:Clone()
	FixCameraClone.Disabled = false
	local Character = Player.Character
	local Backpack = Player:FindFirstChild("Backpack")
	FixCameraClone.Parent = (((Backpack and Backpack) or (Character and Character)) or nil)
	DestroyScript(Delay)
end

if Player and Player:IsA("Player") and Bat then
	Player.Changed:connect(function(Property)
		if Propety == "Parent" and not Player.Parent then
			DestroyScript()
		elseif Property == "Character" then
			FixPlayer()
		end
	end)
	Bat.Changed:connect(function(Property)
		if Property == "Parent" and not Bat.Parent then
			FixPlayer()
		end
	end)
	ToolObject.Changed:connect(function(Property)
		if (not ToolObject.Parent or not ToolObject.Parent.Parent or (ToolObject.Parent ~= Player.Character and ToolObject.Parent.Parent ~= Player)) then
			Spawn(function()
				if Player.Character and Player.Character.Parent then
					Player.Character:BreakJoints()
				end
			end)
			Spawn(function()
				FixPlayer()
			end)
		end
	end)
else
	DestroyScript(1)
end