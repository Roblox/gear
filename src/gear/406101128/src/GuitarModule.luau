--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Name = "Part"
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = false

GuitarModule = {
	BaseDuration = 5,
	MakeNote = (function(Color)
		if not Color then
			return
		end
		local Note = BasePart:Clone()
		Note.Name = "Note"
		Note.BrickColor = BrickColor.new(Color)
		Note.Size = Vector3.new(1, 1.2, 1)
		Note.CanCollide = false
		local NoteMesh = Instance.new("SpecialMesh")
		NoteMesh.MeshType = Enum.MeshType.FileMesh
		NoteMesh.MeshId = (BaseUrl .. "1088207")
		NoteMesh.TextureId = ""
		NoteMesh.Scale = Vector3.new(0.1, 0.1, 0.1)
		NoteMesh.Parent = Note
		return Note
	end),
	PlayNote = (function(Note, SpawnPosition, Duration)
		if not Note or not SpawnPosition then
			return
		end
		Duration = ((not Duration and GuitarModule.BaseDuration) or Duration)
		local Direction = Vector3.new((math.random() - 0.5), 1, (math.random() - 0.5)).unit
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.velocity = Direction * 30
		BodyVelocity.Parent = Note
		Debris:AddItem(Note, Duration)
		Note.Parent = game:GetService("Workspace")
		local Position = SpawnPosition + Vector3.new(0, 5, 0)
		Note.CFrame = CFrame.new(Position, (Position + Direction))
	end),
	PlaySound = (function(Note, Sound, Pitch, Duration)
		if not Note or not Sound then
			return
		end
		local SoundType = type(Sound)
		local SoundObject = nil
		local SoundParent = nil
		if SoundType == "table" then
			local SoundTable = Sound
			local SoundId = SoundTable.SoundId
			SoundId = ((type(SoundId) == "number" and (BaseUrl .. SoundId)) or SoundId)
			SoundObject = Sound.Sound
			if Sound.MakeNew then
				SoundObject = Sound.Sound:Clone()
				SoundParent = Note
			else
				SoundParent = SoundObject.Parent
			end
			SoundObject.SoundId = SoundId
		else
			SoundObject = Sound:Clone()
			Debris:AddItem(SoundObject, Duration)
			SoundParent = Note
		end
		Duration = ((not Duration and (Sound.Sound.TimeLength + 1)) or Duration)
		SoundObject.Pitch = ((Pitch and Pitch) or SoundObject.Pitch)
		if Duration and SoundObject.Looped then
			Delay(Duration, function()
				SoundObject:Stop()
			end)
		end
		if SoundParent then
			if not SoundObject.Parent then
				SoundObject.Parent = SoundParent
			end
			SoundObject:Play()
		end
	end),
	DisplayTune = (function(Player, Text)
		if not Player or not Text then
			return
		end
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if not PlayerGui then
			return
		end
		for i, v in pairs(PlayerGui:GetChildren()) do
			if v.Name == "ChordDisplayGui" then
				v:Destroy()
			end
		end
		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "ChordDisplayGui"
		local Frame = Instance.new("Frame")
		Frame.BackgroundColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
		Frame.BackgroundTransparency = 0.5
		Frame.BorderSizePixel = 0
		Frame.Position = UDim2.new(0, 25, 0, 25)
		Frame.Size = UDim2.new(0, 200, 0, 150)
		Frame.ZIndex = 1
		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.FontSize = Enum.FontSize.Size24
		TextLabel.TextColor3 = Color3.new((255 / 255), (255 / 255), (255 / 255))
		TextLabel.Position = UDim2.new(0, 0, 0, 0)
		TextLabel.Size = UDim2.new(1, 0, 1, 0)
		TextLabel.TextWrapped = true
		TextLabel.Text = Text
		TextLabel.Parent = Frame
		Frame.Parent = ScreenGui
		Debris:AddItem(ScreenGui, 2)
		ScreenGui.Parent = PlayerGui
		return ScreenGui
	end),
	DisplayControls = (function(Player, Text, TextColor, FrameProperties)
		if not Player or not Text then
			return
		end
		local PlayerGui = Player:FindFirstChild("PlayerGui")
		if not PlayerGui then
			return
		end
		for i, v in pairs(PlayerGui:GetChildren()) do
			if v.Name == "ControlDisplayGui" then
				v:Destroy()
			end
		end
		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "ControlDisplayGui"
		local Frame = Instance.new("Frame")
		Frame.BackgroundColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
		Frame.BorderSizePixel = 0
		Frame.Position = UDim2.new(0, 0, 1, -150)
		Frame.Size = UDim2.new(0, 260, 0, 55)
		Frame.ZIndex = 1
		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.Font = Enum.Font.ArialBold
		TextLabel.FontSize = Enum.FontSize.Size18
		TextLabel.TextColor3 = ((TextColor and Color3.new((TextColor.r / 255), (TextColor.g / 255), (TextColor.b / 255))) or Color3.new((190 / 255), (1 / 255), (4 / 255)))
		TextLabel.Position = UDim2.new(0, 5, 0, 0)
		TextLabel.Size = UDim2.new(1, -5, 1, 0)
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.TextYAlignment = Enum.TextYAlignment.Top
		TextLabel.TextWrapped = true
		TextLabel.Text = Text
		TextLabel.Parent = Frame
		pcall(function()
			for i, v in pairs(FrameProperties) do
				TextLabel[i] = v
			end
		end)
		Frame.Parent = ScreenGui
		ScreenGui.Parent = PlayerGui
		return ScreenGui
	end)
}

return GuitarModule