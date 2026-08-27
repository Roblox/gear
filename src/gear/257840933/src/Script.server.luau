--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Grips = {
	Hold = CFrame.new(0, 0, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Unequipped = (CFrame.new(0, -1, 0.75) * CFrame.Angles((math.pi / 2), math.pi, 0)),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = 0.5, Weight = nil, Speed = nil, Duration = nil},
}

ReloadTime = 3

MouseDown = false
ToolEquipped = false

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

Tool.Grip = Grips.Hold
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped or MouseDown then
		return
	end
	MouseDown = true
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Hold)
	end)
	Humanoid.WalkSpeed = 10
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Backpack = Player:FindFirstChild("Backpack")
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Hold
	Spawn(function()
		if ReduceDamage then
			ReduceDamage:disconnect()
		end
		IgnoreHealthChange = false
		local CurrentHealth = Humanoid.Health
		ReduceDamage = Humanoid.Changed:connect(function(Property)
			local NewHealth = Humanoid.Health
			if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth then
				if NewHealth < CurrentHealth then
					local DamageDealt = (CurrentHealth - NewHealth)
					IgnoreHealthChange = true
					Humanoid.Health = (Humanoid.Health + (DamageDealt * ((MouseDown and 0.7) or 0.2)))
					IgnoreHealthChange = false
				end
			end
			CurrentHealth = NewHealth
		end)
	end)
	ToolEquipped = true
end

function Unequipped()
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	if ReduceDamage then
		ReduceDamage:disconnect()
	end
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent then
		if FakeShield and FakeShield.Parent then
			FakeShield:Destroy()
		end
		if Backpack and Backpack.Parent and Tool.Parent == Backpack then
			FakeShield = Handle:Clone()
			FakeShield.Name = "FakeShield"
			FakeShield.CanCollide = false
			local ShieldWeld = Instance.new("Weld")
			ShieldWeld.Part0 = Torso
			ShieldWeld.Part1 = FakeShield
			ShieldWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			ShieldWeld.C1 = Grips.Unequipped
			ShieldWeld.Parent = FakeShield
			FakeShield.Parent = Character
			Backpack = nil
		else
			if FakeShield and FakeShield.Parent then
				FakeShield:Destroy()
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

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		if not Down and MouseDown then
			Tool.Enabled = false
			MouseDown = false
			Spawn(function()
				InvokeClient("StopAnimation", {Animation = Animations.Hold.Animation, FadeTime = 0.25})
			end)
			if CheckIfAlive() then
				Humanoid.WalkSpeed = 16
			end
			wait(ReloadTime)
			Tool.Enabled = true
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)