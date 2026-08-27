--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animations = {
	{Animation = Tool:WaitForChild("ChopPunch"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1.5, PunchTime = 1, Force = {Min = 25, Max = 75}},
	{Animation = Tool:WaitForChild("ForwardPunch"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1, PunchTime = 0.25, Force = {Min = 75, Max = 100}},
	{Animation = Tool:WaitForChild("PunchBlock"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1, PunchTime = 0.125, Force = {Min = 65, Max = 85}},
	{Animation = Tool:WaitForChild("SidePunch"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1, PunchTime = 0.25, Force = {Min = 50, Max = 80}},
	{Animation = Tool:WaitForChild("UpperPunch"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1, PunchTime = 0.125, Force = {Min = 50, Max = 75}},
}

Sounds = {
	PunchSounds = {
		Handle:WaitForChild("Punch1"),
		Handle:WaitForChild("Punch2"),
		Handle:WaitForChild("Punch3"),
		Handle:WaitForChild("Punch4"),
		Handle:WaitForChild("Punch5"),
		Handle:WaitForChild("Punch6")
	},
	PunchHit = Handle:WaitForChild("PunchHit")
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

CurrentAnimation = nil
Active = false

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end

function Blow(Part)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not Character or not Character.Parent or not Active then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
			return
		end
		if CurrentAnimation and CurrentAnimation.Animation  and CurrentAnimation.Animation.Parent then
			local currentanimation = CurrentAnimation
			local character = Hit.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso")
			if character ~= Character and humanoid and humanoid.Health > 0 and torso then
				InvokeClient("PlaySound", Sounds.PunchHit)
				torso.Velocity = CFrame.new(Torso.Position, torso.Position).lookVector * math.random(currentanimation.Force.Min, currentanimation.Force.Max)
				local Sit = math.random(1, 10)
				if Sit == 1 then
					humanoid.Sit = true
				end
			end
		end
	end)
end

function Activated()
	if not Tool.Enabled or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 then
		return
	end
	Tool.Enabled = false
	Active = true
	local AnimationChosen = Animations[math.random(1, #Animations)]
	local PunchSoundChosen = Sounds.PunchSounds[math.random(1, #Sounds.PunchSounds)]
	InvokeClient("PlayAnimation", AnimationChosen)
	InvokeClient("PlaySound", PunchSoundChosen)
	CurrentAnimation = AnimationChosen
	local Duration = (AnimationChosen.Duration - AnimationChosen.PunchTime)
	wait(AnimationChosen.PunchTime)
	CurrentAnimation = nil
	Active = false
	wait(Duration)
	InvokeClient("StopAnimation", AnimationChosen)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Active = false
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	for i, v in pairs(Animations) do
		InvokeClient("Preload", v.Animation.AnimationId)
	end
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.Parent then
			InvokeClient("StopAnimation", v)
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			InvokeClient("StopSound", v)
		end
	end
end

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)