--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

NPCModule = require(191816425)

SelfDestruct = script:WaitForChild("SelfDestruct")

Animations = {
	Drink = {Animation = Tool:WaitForChild("Drink"), FadeTime = nil, Weight = nil, Speed = nil},
}

Sounds = {
	Drink = Handle:WaitForChild("Drink"),
}

ReloadTime = 30

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	local Data = NPCModule.GetTable({Key = "MakeNPC", Player = Player})
	if not Data then
		return
	end
	NPCData = Data.GetData({Player = Player, Tool = Tool})
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function CreateDecoy()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Drink)
	end)
	wait(0.75)
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
		return
	end
	local Decoy = NPCData.MakeNPC({Appearance = Character})
	local DecoyTorso = Decoy:FindFirstChild("Torso")
	Decoy.Name = Player.Name
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = Decoy
	local SelfDestructCopy = SelfDestruct:Clone()
	SelfDestructCopy.Disabled = false
	SelfDestructCopy.Parent = Decoy
	Debris:AddItem(Decoy, math.random(60, 90))
	Decoy.Parent = game:GetService("Workspace")
	if DecoyTorso then
		DecoyTorso.CFrame = (Torso.CFrame + Torso.CFrame.lookVector * 10)
	end
end


function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	Sounds.Drink:Play()
	CreateDecoy()
	wait(ReloadTime)
	Tool.Enabled = true
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
Tool.Activated:connect(Activated)