--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PetrifyScript = script:WaitForChild("PetrifyScript")
StonesplosionScript = script:WaitForChild("StonesplosionScript")

Animations = {
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Thud = {Animation = Tool:WaitForChild("Thud"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Rockfall = Handle:WaitForChild("Rockfall"),
	Slash = Handle:WaitForChild("Slash")
}

Grips = {
	Up = CFrame.new(0, 0, -1.8, 1, 0, 0, 0, 0, -1, 0, 1, 0),
	Down = CFrame.new(0, 0, 1, 1, 0, 0, 0, 0, -1, -0, 1, 0),
	Out = CFrame.new(0, 0, -1.8, 1, 0, 0, 0, -1, 0, 0, 0, -1)
}

ToolEquipped = false

ReloadTime = 5

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "x" and Down then
				local StonesplosionScriptClone = game:GetService("Workspace"):FindFirstChild(StonesplosionScript.Name)
				if StonesplosionScriptClone then
					return
				end
				local StonesplosionDisabled = Tool:FindFirstChild("StonesplosionDisabled")
				if StonesplosionDisabled then
					return
				end
				StonesplosionDisabled = Instance.new("BoolValue")
				StonesplosionDisabled.Name = "StonesplosionDisabled"
				Debris:AddItem(StonesplosionDisabled, 20)
				StonesplosionDisabled.Parent = Tool
				Tool.Grip = Grips.Down
				local Animation = Animations.Thud
				InvokeClient("StopAnimation", Animation)
				InvokeClient("PlayAnimation", Animation)
				local CurrentlyEquipped = true
				if ToolUnequipped then
					ToolUnequipped:disconnect()
				end
				ToolUnequipped = Tool.Unequipped:connect(function()
					CurrentlyEquipped = false
				end)
				wait(0.8)
				if CurrentlyEquipped then
					StonesplosionScriptClone = StonesplosionScript:Clone()
					local Creator = Instance.new("ObjectValue")
					Creator.Name = "Creator"
					Creator.Value = Player
					Creator.Parent = StonesplosionScriptClone
					local Center = Instance.new("Vector3Value")
					Center.Name = "Center"
					Center.Value = Handle.Position - Vector3.new(0, 2.75, 0)
					Center.Parent = StonesplosionScriptClone
					StonesplosionScriptClone.Disabled = false
					StonesplosionScriptClone.Parent = game:GetService("Workspace")
					Sounds.Rockfall:Play()
					Tool.Grip = Grips.Up
				end
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function DamageAndPetrify(Hit)
	if not Hit or not Hit.Parent or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local SwordStaffRecentlyHit = Hit:FindFirstChild("SwordStaffRecentlyHit")
	if SwordStaffRecentlyHit then
		return
	end
	SwordStaffRecentlyHit = Instance.new("StringValue")
	SwordStaffRecentlyHit.Name = "SwordStaffRecentlyHit"
	Debris:AddItem(SwordStaffRecentlyHit, 0.2)
	SwordStaffRecentlyHit.Parent = Hit
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 and humanoid ~= Humanoid then
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(5)
		if math.random() < 0.08 and not Tool.Enabled then
			local Petrifying = Instance.new("StringValue")
			Petrifying.Name = "Petrifying"
			if not character:FindFirstChild("Petrifying") then
				Debris:AddItem(Petrifying, 8)
				Petrifying.Parent = character
				local PetrifyScriptClone = PetrifyScript:Clone()
				local humanoidvalue = Instance.new("ObjectValue")
				humanoidvalue.Name = "Humanoid"
				humanoidvalue.Value = humanoid
				humanoidvalue.Parent = PetrifyScriptClone
				PetrifyScriptClone.Disabled = false
				PetrifyScriptClone.Parent = game:GetService("Workspace")
			end
		end
	end
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Tool.Enabled = false
	Tool.Grip = Grips.Out
	local Animation = Animations.Swing
	InvokeClient("StopAnimation", Animation)
	InvokeClient("PlayAnimation", Animation)
	wait(0.2)
	if CurrentlyEquipped then
		Sounds.Slash:Play()
	end
	wait(0.8)
	if CurrentlyEquipped then
		Tool.Grip = Grips.Up
	end
	wait(0.5)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	Tool.Grip = Grips.Up
	ToolEquipped = true
end

function Unequipped()
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Sounds) do
		InvokeClient("StopSound", v)
		v:Stop()
	end
	ToolEquipped = false
end

Handle.Touched:connect(DamageAndPetrify)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)