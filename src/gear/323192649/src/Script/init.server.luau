--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:FindFirstChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BallScript = script:WaitForChild("BallScript")

ReloadTime = (60 / 2)
BallDuration = (60 * 2)

Handle.Transparency = 0
Handle.CanCollide = true
Tool.Enabled = true

ToolEquipped = false

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	
	local Floatieness = 0.618
	local Gravity = 196.20
	local Weight = ((Handle:GetMass() * Gravity) * Floatieness)
	
	local Ball = Handle:Clone()
	Ball.Name = "Ball"
	Ball.Elasticity = 1
	Ball.Friction = 2
	Ball.CanCollide = true
	
	local Force = Instance.new("BodyForce")
	Force.force = Vector3.new(0, Weight, 0)
	Force.Parent = Ball
	
	local BallScriptCopy = BallScript:Clone()
	BallScriptCopy.Disabled = false
	BallScriptCopy.Parent = Ball
	
	Debris:AddItem(Ball, BallDuration)	
	
	Ball.CFrame = ((Handle.CFrame + Torso.CFrame.lookVector * Handle.Size.Z) + Vector3.new(0, (Handle.Size.Y * 1.25), 0))
	Ball.Parent = game:GetService("Workspace")
	
	Tool.Enabled = false
	Handle.Transparency = 1
	
	wait(ReloadTime)
	
	Tool.Enabled = true
	Handle.Transparency = 0
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool:GetPropertyChangedSignal("Parent"):Connect(function()
	if Tool.Parent then
		Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and ((Tool.Enabled and 0) or 1)) or 0)
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)