--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

GhostScript = script:WaitForChild("GhostScript")

Grips = {
	Equip = CFrame.new(0, -0.5, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Display = CFrame.new(3.25, -0.75, -0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

GhostModel = InsertService:LoadAsset(179296736)
Ghost = GhostModel:GetChildren()[1]:Clone()
if GhostModel and GhostModel.Parent then
	GhostModel:Destroy()
end

Tool.Grip = Grips.Equip

Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or game:GetService("Workspace"):FindFirstChild(Player.Name .. Ghost.Name) then
		return
	end
	
	GhostClone = Ghost:Clone()
	GhostClone.Name = (Player.Name .. Ghost.Name)
	
	local GhostHumanoid = GhostClone:FindFirstChild("Humanoid")
	local GhostTorso = GhostClone:FindFirstChild("Torso")
	
	if GhostHumanoid and GhostTorso and GhostHumanoid.Health > 0 then
		
		Tool.Enabled = false
	
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = GhostClone
		
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.Parent = GhostTorso
		
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.maxForce = Vector3.new(0, 0, 0)
		BodyPosition.Parent = GhostTorso
		
		local GhostScriptClone = GhostScript:Clone()
		GhostScriptClone.Disabled = false
		GhostScriptClone.Parent = GhostClone
		
		GhostClone.Parent = game:GetService("Workspace")
		
		GhostTorso.CFrame = Torso.CFrame - Torso.CFrame.lookVector * (Torso.Size.Z + 3)
		
		Tool:Destroy()
			
	end
	
end

function CheckIfAlive()
	return (Character.Parent and Player.Parent and Humanoid.Parent and Humanoid.Health > 0 and Torso.Parent)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
end

function Unequipped()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)