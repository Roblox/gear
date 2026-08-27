--Made by Luckymaxer
	-- Fix by Stickmasterluke 7/10/2018

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Logo = script:WaitForChild("Logo")

Module = require(script.Parent:WaitForChild('GuitarModule'))

NoteData = {
	Chords = {
		{Key = "z", Sound = {Normal = 99170172, Sharp = 99189531}},
		{Key = "x", Sound = {Normal = 99170311, Sharp = 99189711}},
		{Key = "c", Sound = {Normal = 99170354, Sharp = 99189785}},
		{Key = "v", Sound = {Normal = 99170403, Sharp = 99190216}},
		{Key = "b", Sound = {Normal = 99170481, Sharp = 99189905}},
		{Key = "n", Sound = {Normal = 99170537, Sharp = 99190021}},
		{Key = "m", Sound = {Normal = 99170583, Sharp = 99190550}}
	},
	Pitches = {
		{Key = "g", Pitch = 0.5},
		{Key = "h", Pitch = 0.75},
		{Key = "j", Pitch = 1},
		{Key = "k", Pitch = 1.25},
		{Key = "l", Pitch = 1.5},
	}
}

local pi = math.pi
local tau = math.pi*2
Grips = {
	Hold = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Play = CFrame.new(0.01923877, 1.19116962, 0.313162446, 0.49999997, 0.707106769, 0.49999997, 0.0564237535, 0.549525201, -0.833569586, -0.864185274, 0.444996685, 0.23486498),
	PlayR15 = CFrame.new(.5,-1,0) * CFrame.Angles(0,0,-tau*.15),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Pluck = {Animation = Tool:WaitForChild("Pluck"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	ChordSound = Handle:WaitForChild("ChordSound"),
	Applause = Handle:WaitForChild("Applause")
}

ChordDuration = 0.25

ShiftDown = false
IsPlayingMusic = false
CurrentNote = 1
CurrentPitch = NoteData.Pitches[3] --((NoteData.Pitches[1] and NoteData.Pitches[1]) or nil)

MashMeter = 0
MeltDistance = 30

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "KeyPress" and Value then
		local Key = string.lower(Value.Key)
		local ByteKey = string.byte(Key)
		local Down = Value.Down
		if Key == "0" or ByteKey == 48 then
			ShiftDown = Down
		else
			if Value.Down then
				if IsPlayingMusic then
					for i, v in pairs(NoteData.Chords) do
						if v.Key == Key then
							local Duration = 1
							local Chord = v
							local SoundId = ((not ShiftDown and v.Sound.Normal) or v.Sound.Sharp)
							local Pitch = CurrentPitch.Pitch
							Module.PlaySound(Handle, {Sound = Sounds.ChordSound, SoundId = SoundId}, ((Chord.Pitch and Chord.Pitch) or (CurrentPitch and CurrentPitch.Pitch) or nil), ChordDuration)
							InvokeClient("PlayAnimation", Animations.Pluck)
							MashMeter = (MashMeter + 1)
							return
						end
					end
				end
				for i, v in pairs(NoteData.Pitches) do
					if v.Key == Key then
						CurrentPitch = v
						return
					end
				end
			end
		end
	end
end)

Tool.Grip = Grips.Hold
Tool.Enabled = true

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	IsPlayingMusic = not IsPlayingMusic
	if IsPlayingMusic then
		local desiredGrip = Grips.Play
		if Character then
			local humanoid = Character:FindFirstChild("Humanoid")
			if humanoid and humanoid.RigType ~= Enum.HumanoidRigType.R6 then
				desiredGrip = Grips.PlayR15
			end
		end
		Tool.Grip = desiredGrip
		InvokeClient("PlayAnimation", Animations.Hold)
	else
		Tool.Grip = Grips.Hold
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("BillboardGui") and v.Name == "Logo" then
				v:Destroy()
			end
		end
		LogoCopy = Logo:Clone()
		LogoCopy.Adornee = Head
		LogoCopy.Enabled = true
		Debris:AddItem(LogoCopy, 5)
		LogoCopy.Parent = Tool
		ControlGui = Module.DisplayControls(Player, "Keys H, J, K, and L change pitch Keys Z, X, C, V, B, N, M play notes Click to equip")
	end)
end

function Unequipped()
	Equipped = false
	ShiftDown = false
	IsPlayingMusic = false
	if ControlGui and ControlGui.Parent then
		ControlGui:Destroy()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	if LogoCopy and LogoCopy.Parent then
		LogoCopy:Destroy()
	end
	Tool.Grip = Grips.Hold
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

function MeltFace(player)
	if not player then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local head = character:FindFirstChild("Head")
	if not humanoid or humanoid.Health == 0 or not head then
		return
	end
	humanoid.WalkSpeed = 0
	head.Anchored = true
	local FakeHead = head:Clone()
	FakeHead.Name = "FakeHead"
	FakeHead.Transparency = 1
	FakeHead.Anchored = false
	FakeHead.CanCollide = false
	
	for i, v in pairs(FakeHead:GetChildren()) do
		if not (v:IsA("Decal") or v:IsA("DataModelMesh")) then
			v:Destroy()
		end
	end
	
	for i, v in pairs(head:GetChildren()) do
		if v:IsA("Decal") then
			v:Destroy()
		end
	end
	
	local BV = Instance.new('BodyVelocity')
	FakeHead.CFrame = head.CFrame + head.CFrame.lookVector * 0.25
	BV.velocity = Vector3.new(0, -1, 0)
	BV.maxForce = Vector3.new(50000, 50000, 50000)
	BV.Parent = FakeHead
	Debris:AddItem(FakeHead, 5)
	FakeHead.Parent = game:GetService("Workspace")
	
	local ApplauseSound = Sounds.Applause:Clone()
	ApplauseSound.Parent = head
	ApplauseSound:Play()
	Debris:AddItem(ApplauseSound, 5)

	wait(3)

	if humanoid and humanoid.Parent and head and head.Parent then	
		humanoid.WalkSpeed = 16
		head.Anchored = false
	end
	
end

function MeltNearFaces()
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player then
			local character = v.Character
			if not character then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			local head = character:FindFirstChild("Head")
			if not humanoid or humanoid.Health == 0 or not head or (Handle.Position - head.Position).magnitude > MeltDistance then
				return
			end
			Spawn(function()
				MeltFace(v)
			end)
		end
	end
end

while true do
	if MashMeter > 0 then
		MashMeter = (MashMeter - 0.1)
	end
	if MashMeter > 9 then
		MeltNearFaces()
		wait(5)
		MashMeter = 0
	end
	wait(1 / 30)
end