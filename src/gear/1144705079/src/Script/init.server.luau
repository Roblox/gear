Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Module = require(185791213)
GuitarParts = require(script:WaitForChild("GuitarParts"))

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

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

Grips = {
	Hold = CFrame.new(0, 0.3, -0.05, 1, 0, -0, 0, 1, 1.97913341e-005, 0, -1.97913341e-005, 1),
	Play = CFrame.new(0, 1.25, -0.1, 0.90927124, 0.381022066, 0.167475626, -0.138348684, 0.6562047, -0.741791666, -0.392537355, 0.651319802, 0.649381936),
	Unequipped = CFrame.new(-0.8, -1.25, 0.7, -0.699250817, 8.10044512e-005, 0.714876533, 0.714876533, 1.1920929e-007, 0.699250817, 5.65572336e-005, 1, -5.79915431e-005),
	Smash = CFrame.new(0, 1.25, -0.1, 0.862269044, 0.497923523, 0.092543155, -0.505507767, 0.85731715, 0.0973098949, -0.030885946, -0.130688593, 0.990942299)
}

Animations = {
	Hold = {Animation = Tool.Animations.R6:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Pluck = {Animation = Tool.Animations.R6:WaitForChild("Pluck"), FadeTime = nil, Weight = nil, Speed = 6, Duration = nil},
	Throw = {Animation = Tool.Animations.R6:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75}
}

Sounds = {
	ChordSound = Handle:WaitForChild("ChordSound"),
	GuitarSmash = Handle:WaitForChild("GuitarSmash")
}

ChordDuration = 0.25

ShiftDown = false
IsPlayingMusic = false
CurrentNote = 1
CurrentPitch = NoteData.Pitches[3] --((NoteData.Pitches[1] and NoteData.Pitches[1]) or nil)

Broken = false

Clicks = 0
FirstClick = false

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "KeyPress" and Value and not Broken then
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

Handle.Transparency = 0
Tool.Grip = Grips.Hold
Tool.Enabled = true

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function WeldTo(PrimaryPart, SecondaryPart)
	if not PrimaryPart or not SecondaryPart then
		return
	end
	local Weld = Instance.new("Weld")
	Weld.Name = "Weld"
	Weld.Part0 = PrimaryPart
	Weld.Part1 = SecondaryPart
	Weld.C0 = PrimaryPart.CFrame:inverse()
	Weld.C1 = SecondaryPart.CFrame:inverse()
	Weld.Parent = PrimaryPart
	return Weld
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or Broken then
		return
	end
	
	Clicks = (Clicks + 1)

	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		if IsPlayingMusic and Clicks > 1 then
			Broken = true
			local humanoid = Humanoid
			humanoid.WalkSpeed = 0
			Tool.Grip = Grips.Smash
			local Animation = Animations.Throw
			InvokeClient("PlayAnimation", Animation)
			wait(Animation.Duration)
			if CurrentlyEquipped then		
				local Duration = 10
				local Direction = (Humanoid.RootPart.CFrame.lookVector + Vector3.new(0, 1, 0)).Unit

				Handle.Transparency = 1
				Handle.CanCollide = false
				Sounds.GuitarSmash:Play()
				local GuitarModel = Instance.new("Model")
				GuitarModel.Name = GuitarParts.Name
				local HandleClone = Handle:Clone()
				HandleClone.Velocity = Direction * 20 * HandleClone:GetMass()
				HandleClone.Name = "Center"
				HandleClone.Transparency = 0
				HandleClone.CanCollide = true
				HandleClone.CFrame = CFrame.new(Handle.Position)
				HandleClone.CFrame = Handle.CFrame
				HandleClone.Parent = GuitarModel
				Debris:AddItem(GuitarModel, (Duration + 5))
				GuitarModel.Parent = game:GetService("Workspace")
			else
				Broken = false
			end
			if humanoid and humanoid.Parent then
				humanoid.WalkSpeed = 16
			end
			if Broken then
				Unequipped()
				Tool:Destroy()
			else
				Tool.Grip = Grips.Play
			end
			Clicks = 0
		else
			IsPlayingMusic = not IsPlayingMusic
			if IsPlayingMusic then
				Tool.Grip = Grips.Play
				InvokeClient("PlayAnimation", Animations.Hold)
			else
				Tool.Grip = Grips.Hold
				for i, v in pairs(Animations) do
					InvokeClient("StopAnimation", v)
				end
			end
		end
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		FirstClick = false
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Backpack = Player:FindFirstChild("Backpack")
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations = {
			Hold = {Animation = Tool.Animations.R15:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
			Pluck = {Animation = Tool.Animations.R15:WaitForChild("Pluck"), FadeTime = nil, Weight = nil, Speed = 6, Duration = nil},
			Throw = {Animation = Tool.Animations.R15:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75}
		}		
	else
		Animations = {
			Hold = {Animation = Tool.Animations.R6:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
			Pluck = {Animation = Tool.Animations.R6:WaitForChild("Pluck"), FadeTime = nil, Weight = nil, Speed = 6, Duration = nil},
			Throw = {Animation = Tool.Animations.R6:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 0.75}			
		}
	end
	Tool.Grip = Grips.Hold
	ControlGui = Module.DisplayControls(
		Player,
		"Keys H, J, K, and L change pitch Keys Z, X, C, V, B, N, M play notes",
		nil,
		{
			TextColor3 = Color3.new((255 / 255), (0 / 255), (0 / 255)),
		}
	)
end

function Unequipped()
	Equipped = false
	ShiftDown = false
	IsPlayingMusic = false
	FirstClick = false
	Clicks = 0
	for i, v in pairs({ControlGui}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
end

Tool:GetPropertyChangedSignal("Parent"):Connect(function()
	if FakeGuitar and FakeGuitar.Parent then
		FakeGuitar:Destroy()
	end
	if Tool.Grip == Grips.Play then
		if Backpack and Backpack.Parent and Tool.Parent == Backpack then
			FakeGuitar = Handle:Clone()
			FakeGuitar.Name = "FakeGuitar"
			FakeGuitar.CanCollide = false
			local GuitarWeld = Instance.new("Motor6D")
			GuitarWeld.Part0 = Torso
			GuitarWeld.Part1 = FakeGuitar
			GuitarWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			GuitarWeld.C1 = Grips.Unequipped
			GuitarWeld.Parent = FakeGuitar
			FakeGuitar.Parent = Character
			Backpack = nil
		else
			if FakeGuitar and FakeGuitar.Parent then
				FakeGuitar:Destroy()
			end
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)