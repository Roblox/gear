--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
ExplosionScript = script:WaitForChild("ExplosionScript")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 30

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		local Table = Handle:Clone()
		Handle.Friction = 2
		Handle.Elasticity = 1
		Table.CanCollide = true
		Handle.Transparency = 1
		Table.Name = "ExplodingLabExperiment"
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = Table
		local ExplosionScriptClone = ExplosionScript:Clone()
		ExplosionScriptClone.Disabled = false
		ExplosionScriptClone.Parent = Table
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.cframe = Table.CFrame
		BodyGyro.Parent = Table
		Debris:AddItem(Table, 30)
		Table.Parent = game:GetService("Workspace")
		wait(ReloadTime)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end
end

function Unequipped()
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)