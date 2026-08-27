--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

Animations = {
	Aim = {Animation = Tool:WaitForChild("Aim"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Release = {Animation = Tool:WaitForChild("Release"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.5},
	Reload = {Animation = Tool:WaitForChild("Reload"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 2},
}

Sounds = {
}

Grips = {
	Unequipped = CFrame.new(0, 0, 1.25, 1, 0, -0, 0, 1, 0, 0, -0, 1),
	Aiming = CFrame.new(0.25, 0, 1, 0.865768731, -0, 0.500444353, 0, 1, 0, -0.500444353, 0, 0.865768731)
}

MeshData = {
	BowAndArrow = "http://www.roblox.com/asset/?id=193469621",
	Bow = "http://www.roblox.com/asset/?id=193469716",
	Arrow = "http://www.roblox.com/asset/?id=193469673",
	TextureId = "http://www.roblox.com/asset/?id=193469813"
}

Sounds = {
	Hit = Handle:WaitForChild("HitSound"),
	Fire = Handle:WaitForChild("FireSound"),
	Amaj = Handle:WaitForChild("Amaj"),
	Bbmin = Handle:WaitForChild("Bbmin"),
	Bbmaj = Handle:WaitForChild("Bbmaj"),
	Cmin = Handle:WaitForChild("Cmin"),
	Dmin = Handle:WaitForChild("Dmin"),
	Dmin2 = Handle:WaitForChild("Dmin2"),
	Dmaj = Handle:WaitForChild("Dmaj"),
	Emaj = Handle:WaitForChild("Emaj"),
	Gmin = Handle:WaitForChild("Gmin"),
	Gmaj = Handle:WaitForChild("Gmaj")
}

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.375, 2.625)
ArrowMesh = Instance.new("SpecialMesh")
ArrowMesh.MeshType = Enum.MeshType.FileMesh
ArrowMesh.MeshId = MeshData.Arrow
ArrowMesh.TextureId = MeshData.TextureId
ArrowMesh.Scale = Vector3.new(0.75, 0.75, 0.75)
ArrowMesh.VertexColor = Vector3.new(1, 1, 1)
ArrowMesh.Parent = BaseArrow

Gravity = 196.20

Damage = {Min = 20, Max = 30}

ToolEquipped = false
MouseDown = false
Loaded = true

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Mesh.MeshId = MeshData.BowAndArrow
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" then
			if Value.Down and not MouseDown and Tool.Enabled then
				if Loaded then
					MouseDown = true
					InvokeClient("PlayAnimation", Animations.Aim)
					Tool.Grip = Grips.Aiming
					while MouseDown do
						wait()
					end
					if ToolEquipped then
						Loaded = false
						Mesh.MeshId = MeshData.Bow
						local Animation = Animations.Release
						InvokeClient("PlayAnimation", Animation)
						FireArrow()
						wait(Animation.Duration)
						InvokeClient("StopAnimation", Animations.Aim)
						Tool.Grip = Grips.Unequipped
					end
					Tool.Enabled = true
				else
					Tool.Enabled = false
					InvokeClient("StopAnimation", Animations.Release)
					InvokeClient("StopAnimation", Animations.Aim)
					local Animation = Animations.Reload
					InvokeClient("PlayAnimation", Animation)
					wait(Animation.Duration)
					Loaded = true
					Mesh.MeshId = MeshData.BowAndArrow
					Tool.Enabled = true
				end
			elseif not Value.Down then
				MouseDown = false
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

function Billboard(Pos, Text, Time, Color)
	local Rate = (1 / 30)
	local Pos = (Pos or Vector3.new(0, 0, 0))
	local Text = (Text or "")
	local Time = (Time or 2)
	local Color = (Color or Color3.new(1, 0, 0))
	local EffectPart = BasePart:Clone()
	EffectPart.Name = "Effect"
	EffectPart.Size = Vector3.new(0, 0, 0)
	EffectPart.CFrame = CFrame.new(Pos)
	EffectPart.Anchored = true
	EffectPart.CanCollide = false
	EffectPart.Transparency = 1
	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Size = UDim2.new(3, 0, 3, 0)
	BillboardGui.Adornee = EffectPart
	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Text = Text
	TextLabel.TextColor3 = Color
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.ArialBold
	TextLabel.Parent = BillboardGui
	BillboardGui.Parent = EffectPart
	Debris:AddItem(EffectPart, (Time + 0.1))
	EffectPart.Parent = game:GetService("Workspace")
	Delay(0, function()
		local Frames = (Time / Rate)
		for Frame = 1, Frames do
			wait(Rate)
			local Percent = (Frame / Frames)
			EffectPart.CFrame = CFrame.new(Pos) + Vector3.new(0, Percent, 0)
			TextLabel.TextTransparency = Percent
		end
		if EffectPart and EffectPart.Parent then
			EffectPart:Destroy()
		end
	end)
end

function FireArrow()
	Sounds.Fire:Play()
	local Speed = 250
	local Arrow = BaseArrow:Clone()
	local MousePosition = InvokeClient("MousePosition")
	local Direction = CFrame.new(Handle.Position, MousePosition)
	local Mass = (Arrow:GetMass() * Gravity)
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = Direction
	BodyGyro.Parent = Arrow
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyVelocity.velocity = Direction.lookVector * Speed
	BodyVelocity.Parent = Arrow
	Arrow.Velocity = BodyVelocity.velocity
	local Notes = {Sounds.Amaj, Sounds.Bbmin, Sounds.Bbmaj, Sounds.Cmin, Sounds.Dmin, Sounds.Dmin2, Sounds.Dmaj, Sounds.Emaj, Sounds.Gmin, Sounds.Gmaj}
	local RandomNote = Notes[math.random(1, #Notes)]
	local NoteSound = RandomNote:Clone()
	NoteSound.Parent = Arrow
	local HitSound = Sounds.Hit:Clone()
	HitSound.Parent = Arrow
	local HitDebounce = false
	Arrow.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or HitDebounce or Hit.Name == "Arrow" then
			return
		end
		local character = Hit.Parent
		if Hit.Parent:IsA("Hat") or Hit.Parent:IsA("Tool") then
			character = character.Parent
		end
		if character == Character then
			return
		end
		HitDebounce = true
		local Weld = Instance.new("Weld")
		Weld.Part0 = Hit
		Weld.Part1 = Arrow
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 and humanoid ~= Humanoid then
			local DamageAmount = math.random(Damage.Min, Damage.Max)
			local Radius = Vector3.new(1.25, 0.25, 1.25)
			Radius = (Radius * 100)
			local Offset = Vector3.new(math.random(-Radius.X, Radius.X), math.random(-Radius.Y, Radius.Y), math.random(-Radius.Z, Radius.Z))
			Offset = Offset * Vector3.new(0.01, 0.01, 0.01)
			Billboard((Arrow.Position + Offset + Vector3.new(0, 2.5, 0)), DamageAmount, 2, BrickColor.new("Teal").Color)
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(DamageAmount)
			local StickCFrame = CFrame.new(Hit.CFrame.p, Arrow.Position) * CFrame.new(0, 0, -1) * CFrame.Angles((math.pi / 2), (math.random() * math.pi * 2), 0)
			Weld.C1 = StickCFrame:inverse() * Hit.CFrame
		else
			Weld.C1 = Arrow.CFrame:inverse() * Hit.CFrame
		end
		for i, v in pairs({BodyVelocity, BodyGyro}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		--HitSound:Play()
		Weld.Parent = Arrow
		Arrow.CanCollide = false
	end)
	Debris:AddItem(Arrow, 5)
	Arrow.Parent = game:GetService("Workspace")
	NoteSound:Play()
	Arrow.CFrame = Handle.CFrame + Handle.CFrame.lookVector * ((Handle.Size.Z / 2) + (Arrow.Size.Z / 2))
	Arrow.CFrame = CFrame.new(Arrow.Position, MousePosition)
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Sounds) do
		InvokeClient("StopSound", v)
		v:Stop()
	end
	Tool.Grip = Grips.Unequipped
	MouseDown = false
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)