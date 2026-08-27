--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
ContentProvider = game:GetService("ContentProvider")

Animations = {
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 0.9, Duration = nil}
}

Sounds = {
	Hop = Handle:WaitForChild("Hop"),
}

AnimationTracks = {}

ToolEquipped = false

Spawn(function()
	for i, v in pairs(Animations) do
		ContentProvider:Preload(v.Animation.AnimationId)
	end
end)

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(AnimationTracks, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(AnimationTracks, i)
			end
		end
	end
end

function EnableDoubleJump()
	if not CheckIfAlive() then
		return
	end
	
	local State = Humanoid:GetState().Name
	local CanJump = (((State == "Landed" or State == "Running" or State == "RunningNoPhysics") and true) or false)
	local FirstJump = false
	
	for i, v in pairs({HumanoidStateChanged, JumpRequest}) do
		if v then
			v:disconnect()
		end
	end
	
	HumanoidStateChanged = Humanoid.StateChanged:connect(function(Old, New)
		State = New.Name
		if State == "Landed" or State == "Running" or State == "RunningNoPhysics" then
			CanJump = true
		elseif State == "Jumping" and (Old ~= "Jumping" and Old ~= "Freefall") then
			if FirstJump then
				return
			end
			Sounds.Hop.Pitch = (math.random(2000, 2100) * 0.001)
			Sounds.Hop:Play()
			Torso.Velocity = Vector3.new(0, 100, 0)
			FirstJump = true
			wait(0.25)
			FirstJump = false
		end
	end)
	
	JumpRequest = UserInputService.JumpRequest:connect(function()
		if State == "Freefall" or State == "Jumping" then
			if not CanJump or FirstJump then
				return
			end
			CanJump = false
			Sounds.Hop.Pitch = (math.random(2250, 2500) * 0.001)
			Sounds.Hop:Play()
			SetAnimation("PlayAnimation", Animations.Spin)
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			Torso.Velocity = Vector3.new(0, 80, 0)
		end
	end)
	
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	EnableDoubleJump()
end

function Unequipped()
	for i, v in pairs({HumanoidStateChanged, JumpRequest}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	AnimationTracks = {}
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)