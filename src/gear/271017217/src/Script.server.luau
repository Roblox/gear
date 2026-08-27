--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

BirdModel = InsertService:LoadAsset(267938904)
Bird = BirdModel:GetChildren()[1]:Clone()
if BirdModel and BirdModel.Parent then
	BirdModel:Destroy()
end

MaxBirds = 3
Birds = {}
Duration = (60 * 1)

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Blow = {Animation = Tool:WaitForChild("Blow"), FadeTime = 0, Weight = nil, Speed = nil, Duration = 0.5}, 
}

Sounds = {
	Horn = Handle:WaitForChild("Horn"),
}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function RemoveDeadBirds()
	for i, v in pairs(Birds) do
		if not v or not v.Parent then
			table.remove(Birds, i)
		end
	end
end

function SpawnBird(Position)
	local NewBird = Bird:Clone()
	local OwnerRef = NewBird:WaitForChild("OwnerRef")
	OwnerRef.Value = Character
	local ToolRef = NewBird:WaitForChild("ToolRef")
	ToolRef.Value = Tool
	table.insert(Birds, NewBird)
	
	local Angle = (math.pi * 2 * #Birds / (MaxBirds + 1))
	local SpawnPosition = (Position + 200 * (Vector3.new(math.sin(Angle), 1, math.cos(Angle))))
	NewBird:TranslateBy(SpawnPosition - NewBird:GetModelCFrame().p)
	Debris:AddItem(NewBird, Duration)
	NewBird.Parent = game:GetService("Workspace")
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Animation = Animations.Blow
	InvokeClient("PlayAnimation", Animation)
	RemoveDeadBirds()
	local AddedBird = false
	Spawn(function()
		wait(Animation.Duration)
		Sounds.Horn:Play()
	end)
	while #Birds < MaxBirds do
		SpawnBird(Torso.Position)
		wait(1)
		AddedBird = true
	end
	if AddedBird then
		Tool.Enabled = true
	end
	wait(0.5)
	for i, v in pairs(Birds) do
		local BirdTarget = v:FindFirstChild("TargetPoint")
		if BirdTarget then
			BirdTarget.Value = InvokeClient("MousePosition")
		end
	end
	wait(1.5)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Hold)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)