--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

GlassScript = script:WaitForChild("GlassScript")

Sounds = {
	GlassBreak = Handle:WaitForChild("GlassBreak"),
	Drink = Handle:WaitForChild("Drink"),
	Slateskin = Handle:WaitForChild("Slateskin"),
}

Grips = {
	Normal = CFrame.new(0.1, 0, 0.1, 0.217036337, 0, 0.976163626, 0, 1, -0, -0.976163507, 0, 0.217036366),
	Drinking = CFrame.new(1.5, -0.35, 0.1, 1, 0, -0, -0, 0.651038408, 0.759044766, 0, -0.759044766, 0.651038408),
}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Normal
Tool.Enabled = true

function Transform(character)
end

function SlateMe(character)
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("Clothing") then
			v:Destroy()
		elseif v:IsA("BasePart") then
			v.Material = Enum.Material.Slate
			v.BrickColor = BrickColor.new("Dark stone grey")
		elseif v:IsA("Humanoid") then
			v.WalkSpeed = (16 * 0.9)
			v.MaxHealth = 150
			v.Health = v.MaxHealth
		end
	end
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end	
	
	local CurrentlyEquipped = true

	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)

	Tool.Enabled = false
	Tool.Grip = Grips.Drinking
	
	Sounds.Drink:Play()
	
	wait(3)
	
	if not CurrentlyEquipped then
		Tool.Grip = Grips.Normal
		Tool.Enabled = true
		return
	end
	
	Sounds.Slateskin:Play()
	
	SlateMe(Character)

	Tool.Grip = Grips.Normal

	wait(1)
	
	if CurrentlyEquipped then
		local Part = Handle:Clone()
		local GlassBreakSound = Sounds.GlassBreak:Clone()
		GlassBreakSound.Parent = Part
		Part.Transparency = 0
		local Direction = Head.CFrame.lookVector
		Part.Velocity = (Direction * 45) + Vector3.new(0, 45, 0)
		Part.CanCollide = true
		local GlassScriptClone = GlassScript:Clone()
		GlassScriptClone.Disabled = false
		GlassScriptClone.Parent = Part
		Debris:AddItem(Part, 30)
		Part.Parent = game:GetService("Workspace")
	end

	Debris:AddItem(Tool, 0)
	
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)