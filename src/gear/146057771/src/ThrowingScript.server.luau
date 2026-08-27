--By Luckymaxer

CoolDown = 0.75 -- Seconds until another can be thrown
Duration = 10 -- Seconds until each old one is destroyed
Throw_Speed = 100

Players = Game:GetService("Players")
Debris = Game:GetService("Debris")

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

ThrowSound = Handle:WaitForChild("Throw")

Player = nil
Character = nil

function OnEquipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
end

function OnActivated()
	if not Character or not Character:FindFirstChild("Humanoid") or not Tool.Enabled then
		return
	end
	
	Tool.Enabled = false
	Handle.Transparency = 1

	ThrowSound:Play()

	local HandleClone = Handle:Clone()
	Debris:AddItem(HandleClone, 30)
	HandleClone.Velocity = (Character.Humanoid.TargetPoint - Handle.CFrame.p).unit * Throw_Speed
	HandleClone.Name = "Cake"
	HandleClone.Parent = game:GetService("Workspace")
	HandleClone.Transparency = 0
	HandleClone.CanCollide = true
	Instance.new("BodyGyro", HandleClone) -- Keeps it upright
	local SelfDestructScript = HandleClone:FindFirstChild("SelfDestruct")
	if SelfDestructScript and SelfDestructScript:FindFirstChild("TimeToLive") then
		SelfDestructScript.TimeToLive.Value = Duration
		SelfDestructScript.Disabled = false
	end
	local EffectsScript = HandleClone:FindFirstChild("EffectsScript")
	if EffectsScript then
		local Creator = Instance.new("ObjectValue", EffectsScript)
		Creator.Name = "creator"
		Creator.Value = Player
		EffectsScript.Disabled = false
	end

	wait(CoolDown)

	Handle.Transparency = 0
	Tool.Enabled = true
end

function OnUnequipped()
	Handle.Transparency = 0
end

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)
