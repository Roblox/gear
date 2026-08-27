--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Module = require(191816425)

Grips = {
	Normal = CFrame.new(0, -0.5, 0, 1, 0, 0, 0, 8.10044585e-005, -1, -0, 1, 8.10044585e-005),
	Blow = CFrame.new(0.25, -0.5, 0.75, 0.737681091, -0, 0.675149262, 0, 1, 0, -0.675149202, 0, 0.73768115),
}

Animations = {
	Blow = {Animation = Tool:WaitForChild("Blow"), FadeTime = 0.75, Weight = nil, Speed = 0.5, Duration = 1},
	R15Blow = {Animation = Tool:WaitForChild("R15Blow"), FadeTime = 0.75, Weight = nil, Speed = 0.5, Duration = 1},
}

Sounds = {
	BeginHorn = Handle:WaitForChild("BeginHorn"),
	EndHorn = Handle:WaitForChild("EndHorn"),
}

ReloadTime = 15
MaxUsageDistance = 500
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Grip = Grips.Normal
Tool.Enabled = true

function Activated()
	if not CheckIfAlive() then
		return
	end
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position or not MouseData.Target then
		return
	end
	if (Torso.Position - MouseData.Position).Magnitude > MaxUsageDistance then
		return
	end
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	local SoundLength = 3.5
	local Duration = SoundLength
	local Animation = Animations.Blow
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Blow
	end
	Tool.Grip = Grips.Blow
	local Target = MouseData.Position
	spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(1)
	if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
		Sounds.BeginHorn:Play()
		wait(SoundLength)
		if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
			Sounds.EndHorn:Play()
			if CurrentlyEquipped and ToolEquipped and CheckIfAlive() then
				wait(SoundLength / 2)
				spawn(function()
					LightningFunctions.Strike({Key = "LightningHorn", Target = Target})
				end)
				wait(3)
				spawn(function()
					if Humanoid then
						if Humanoid.RigType == Enum.HumanoidRigType.R6 then
							InvokeClient("StopAnimation", {Animation = Animations.Blow.Animation, FadeTime = 0.5})
						elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then
							InvokeClient("StopAnimation", {Animation = Animations.R15Blow.Animation, FadeTime = 0.5})
						end
					end
					
				end)
				Tool.Grip = Grips.Normal
			end
		end
	end
	wait(Animation.Duration)
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Tool.Grip = Grips.Normal
	if not CheckIfAlive() then
		return
	end
	local LightningData = Module.GetTable({Key = "LightningStrike", Player = Player})
	LightningFunctions = LightningData.GetData({Player = Player, Tool = Tool})
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
	Tool.Grip = Grips.Normal
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)