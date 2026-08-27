--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

Creator = script:FindFirstChild("Creator")
Tool = script:FindFirstChild("Tool")

FixCamera = script:FindFirstChild("FixCamera")

function DestroyModel()
	if Player and Player.Parent then
		if FixCamera then
			if Character and Character.Parent then
				local FixCameraClone = FixCamera:Clone()
				FixCameraClone.Disabled = false
				FixCameraClone.Parent = Character
			end
			local Backpack = Player:FindFirstChild("Backpack")
			if Backpack then
				local FixCameraClone = FixCamera:Clone()
				FixCameraClone.Disabled = false
				FixCameraClone.Parent = Backpack
			end
		end
	end
	Debris:AddItem(Model, 2)
end

if not Creator or not Creator.Value or not Creator.Value.Parent or not Tool or not Tool.Value or not Tool.Value.Parent then
	DestroyModel()
	return
end

ToolObject = Tool.Value
Player = Creator.Value

if not Player or not Player:IsA("Player") then
	DestroyModel()
	return
end

Character = Player.Character
if not Character or not Character.Parent then
	DestroyModel()
	return
end

Humanoid = Character:FindFirstChild("Humanoid")
if not Humanoid or Humanoid.Health == 0 then
	DestroyModel()
	return
end

Humanoid.Died:connect(function()
	DestroyModel()
end)

Player.Changed:connect(function(Property)
	if Property == "Character" then
		DestroyModel()
	end
end)

ToolObject.Changed:connect(function(Property)
	if Property == "Parent" and not ToolObject.Parent then
		DestroyModel()
	end
end)