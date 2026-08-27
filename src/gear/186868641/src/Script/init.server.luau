--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Remover = script:WaitForChild("Remover")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.2, 0.2, 3)
ArrowMesh = Instance.new("SpecialMesh")
ArrowMesh.MeshType = Enum.MeshType.FileMesh
ArrowMesh.MeshId = "http://www.roblox.com/asset/?id=186758016"
ArrowMesh.TextureId = "http://www.roblox.com/asset/?id=186758038"
ArrowMesh.Offset = Vector3.new(0, 0, 0)
ArrowMesh.Scale = Vector3.new(1, 1, 1)
ArrowMesh.VertexColor = Vector3.new(1, 1, 1)
ArrowMesh.Parent = BaseArrow

BaseQuiver = BasePart:Clone()
BaseQuiver.Name = "Quiver"
BaseQuiver.Size = Vector3.new(1.25, 2.5, 1.25)
QuiverMesh = Instance.new("SpecialMesh")
QuiverMesh.MeshType = Enum.MeshType.FileMesh
QuiverMesh.MeshId = "http://www.roblox.com/asset/?id=186758000"
QuiverMesh.TextureId = "http://www.roblox.com/asset/?id=186758038"
QuiverMesh.Offset = Vector3.new(0, 0, 0)
QuiverMesh.Scale = Vector3.new(1.5, 0.75, 1.5)
QuiverMesh.VertexColor = Vector3.new(1, 1, 1)
QuiverMesh.Parent = BaseQuiver

Animations = {
	Reload = {Animation = Tool:WaitForChild("Reload"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = nil},
	Aim = {Animation = Tool:WaitForChild("Aim"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	HoldAim = {Animation = Tool:WaitForChild("HoldAim"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Reload = {Animation = Tool:WaitForChild("R15Reload"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = nil},
	R15Aim = {Animation = Tool:WaitForChild("R15Aim"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15HoldAim = {Animation = Tool:WaitForChild("R15HoldAim"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},	
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Hit = Handle:WaitForChild("Hit")
}

Range = 250
Power = 100
Rate = (1 / 30)
WindVec = Vector3.new(2, -1, 1).unit

ToolEquipped = false
MouseDown = false
ArrowExists = true

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and ToolEquipped and CheckIfAlive() then
		if Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "q" and Down then
			end
		elseif Mode == "MouseClick" then
			if Value.Down then
				Activated()
			elseif ToolEquipped and MouseDown and Arrow and Arrow.Parent and ArrowWeld and ArrowWeld.Parent then
				MouseDown = false
				
				Sounds.Fire:Play()
				
				local BaseDamage = 5
				local FireDamage = Round((GetPercentage(0.5, -0.85, ArrowWeld.C0.Z) / 1.5), 0.5)
				FireDamage = ((FireDamage < BaseDamage and BaseDamage) or FireDamage)
				
				local CurrentArrow = Arrow
				
				Arrow = nil
				
				local MousePosition = InvokeClient("MousePosition")
				local StartPos = Handle.Position
				local Vec = (MousePosition - StartPos).unit
				
				local Hit, EndPos = CastRay(StartPos, Vec, Range, Character, false)
				local FakeVec = (EndPos - StartPos).unit

				if ArrowWeld and ArrowWeld.Parent then
					ArrowWeld:Destroy()
				end
				
				local HitSound = Sounds.Hit:Clone()
				HitSound.Parent = CurrentArrow
				
				Debris:AddItem(CurrentArrow, 20)
				CurrentArrow.Parent = game:GetService("Workspace")			
				
				if Hit and Hit.Parent then
					HitSound:Play()
					local NewCF = CFrame.new(EndPos, (EndPos + FakeVec)) * CFrame.new(0, 0, 0.5)
					CurrentArrow.CFrame = NewCF
					local Weld = Instance.new("Weld")
					Weld.Part0 = Hit
					Weld.Part1 = CurrentArrow
					Weld.C0 = Hit.CFrame:inverse() * NewCF
					Weld.C1 = NewCF:inverse() * NewCF
					Weld.Parent = CurrentArrow
					local character = Hit.Parent
					if character:IsA("Tool") or character:IsA("Hat") then
						character = character.Parent
					end
					if character and character ~= Character then
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid and humanoid.Health > 0 then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							local NewHealth = (humanoid.Health - FireDamage)
							humanoid:TakeDamage(FireDamage)
							if NewHealth > 0 and CurrentArrow:FindFirstChild("Fire") then
								local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
								if torso then
									local CharacterSize = character:GetModelSize()
									local IceCube = BasePart:Clone()
									IceCube.Name = "IceCube"
									IceCube.BrickColor = BrickColor.new("Bright blue")
									IceCube.Transparency = 0.25
									IceCube.Material = Enum.Material.Ice
									IceCube.Size = (Vector3.new(CharacterSize.Y, CharacterSize.Y, CharacterSize.Y) + Vector3.new(1.5, 1.5, 1.5))
									IceCube.Anchored = true
									IceCube.CFrame = torso.CFrame
									local Weld = Instance.new("Weld")
									Weld.Part0 = IceCube
									Weld.Part1 = torso
									Weld.Parent = IceCube
									Debris:AddItem(IceCube, 20)
									IceCube.Parent = game:GetService("Workspace")
								end
							end
						end
					end
				else
					CurrentArrow.CFrame = CFrame.new(EndPos, (EndPos + FakeVec))
					CurrentArrow.CFrame = CurrentArrow.CFrame + CurrentArrow.CFrame.lookVector * 1.25
					CurrentArrow.Velocity = (FakeVec * Power)
				end

				spawn(function()
					DrawBeam(StartPos, EndPos, BrickColor.new("Institutional white"), 0.25)
				end)
				
				for i, v in pairs(Animations) do
					InvokeClient("StopAnimation", v)
				end
				
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
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

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit)
		local LowercaseName = string.lower(Hit.Name)
		if character == Character or Hit.Transparency > 0.8 or string.sub(LowercaseName, 1, string.len("effect")) == "effect" or Hit.Name == "Bullet" or LowercaseName == "laser" or LowercaseName == "water" or LowercaseName == "rail" or LowercaseName == "arrow" then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, IgnoreList, DelayIfHit)
	local Hit, EndPos = game:GetService("Workspace"):FindPartOnRay(Ray.new(StartPos, Vec * Length), IgnoreList)
	if Hit and CheckIntangible(Hit) then
		if DelayIfHit then
			wait()
		end
		Hit, EndPos = CastRay((EndPos + (Vec * 0.01)), Vec, (Length - ((StartPos-EndPos).magnitude)), IgnoreList, DelayIfHit)
	end
	return Hit, EndPos
end

function DrawBeam(BeamStart, BeamEnd, Color, FadeDelay)
	local Distance = (BeamStart - BeamEnd).magnitude
	local Laser = Instance.new("Part")
	Laser.Name = "Laser"
	Laser.Anchored = true
	Laser.CanCollide = false
	Laser.Shape = Enum.PartType.Block
	Laser.FormFactor = Enum.FormFactor.Custom
	Laser.Size = Vector3.new( 0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.Material = Enum.Material.Plastic
	Laser.Locked = true
	Laser.TopSurface = Enum.SurfaceType.Smooth
	Laser.BottomSurface = Enum.SurfaceType.Smooth
	Laser.BrickColor = Color
	Laser.CFrame = CFrame.new(BeamEnd, BeamStart) * CFrame.new(0, 0, (-Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	local LaserMesh = Instance.new("SpecialMesh")
	LaserMesh.Scale = Vector3.new(1, (Distance * 5), 1)
	LaserMesh.Parent = Laser
	Debris:AddItem(Laser, (FadeDelay * 3))
	Laser.Parent = game:GetService("Workspace")

	local Frames = math.floor(FadeDelay / Rate)
	for Frame = 1, Frames do
		wait(Rate)
		local Percent = (Frame / Frames)
		Laser.CFrame = (Laser.CFrame + (WindVec * Rate))
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	delay(1, function()
		Laser:Destroy()
	end)
end

function CreateQuiver()
	if Quiver and Quiver.Parent then
		Quiver:Destroy()
	end
	Quiver = BaseQuiver:Clone()
	local QuiverWeld = Instance.new("Weld")
	QuiverWeld.Part0 = Quiver
	QuiverWeld.Part1 = Torso
	QuiverWeld.C0 = CFrame.new(0, 0, 0.95) * CFrame.Angles(0, math.pi, 0)
	QuiverWeld.Parent = Quiver
	Quiver.Parent = Tool
end

function CreateArrow()
	if Arrow and Arrow.Parent then
		Arrow:Destroy()
	end
	Arrow = BaseArrow:Clone()
	ArrowWeld = Instance.new("Weld")
	ArrowWeld.Part0 = Arrow
	ArrowWeld.Part1 = Handle
	ArrowWeld.C0 = CFrame.new(0, 0, 0.5)
	ArrowWeld.Parent = Arrow
	Arrow.Parent = Tool
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if not Arrow or not Arrow.Parent then
		local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand") 
		if not LeftArm then
			return
		end
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
		local Animation = Animations.Reload
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Reload
		end
		InvokeClient("PlayAnimation", Animation)
		wait(0.5)
		if CurrentlyEquipped and CheckIfAlive() and LeftArm.Parent then
			EquipArrow = BaseArrow:Clone()
			local TemporaryArrowWeld = Instance.new("Weld")
			TemporaryArrowWeld.Part0 = EquipArrow
			TemporaryArrowWeld.Part1 = LeftArm
			TemporaryArrowWeld.C0 = CFrame.new(0, 1, 0.5)
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				TemporaryArrowWeld.C0 = CFrame.new(0, 0.2, 0.5)
			end	
			TemporaryArrowWeld.Parent = EquipArrow
			Debris:AddItem(EquipArrow, 5)
			EquipArrow.Parent = Tool
			wait(1.25)
			if CurrentlyEquipped and CheckIfAlive() then
				if EquipArrow and EquipArrow.Parent then
					EquipArrow:Destroy()
				end
				CreateArrow()
			end
		end
	else
		local Animation = Animations.Aim
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Aim
		end
		InvokeClient("PlayAnimation", Animation)
		MouseDown = true
		delay(1.5, function()
			if CurrentlyEquipped and CheckIfAlive() and Arrow and Arrow.Parent then
				local Animation = Animations.HoldAim
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15HoldAim
				end
				InvokeClient("PlayAnimation", Animation)
			end
		end)
		local PullingBack = true
		if CurrentlyEquipped and CheckIfAlive() and Arrow and Arrow.Parent then
			while ToolEquipped and MouseDown and PullingBack and CheckIfAlive() and Arrow and Arrow.Parent and ArrowWeld and ArrowWeld.Parent do
				if ArrowWeld.C0.Z > -0.85 then
					ArrowWeld.C0 = ArrowWeld.C0 - Vector3.new(0, 0, 0.025)
					if ArrowWeld.C0.Z <= -0.85 then
						ArrowWeld.C0 = CFrame.new(0, 0, -0.85)
						local Fire = Instance.new("Fire")
						Fire.Name = "Fire"
						Fire.Color = Color3.new((0 / 255), (255 / 255), (255 / 255))
						Fire.SecondaryColor = Color3.new((0 / 255), (0 / 255), (255 / 255))
						Fire.Heat = 0
						Fire.Size = 2.5
						Fire.Enabled = true
						Fire.Parent = Arrow
					end
				end
				spawn(function()
					local FieldOfView = InvokeClient("GetCamera", {Property = "FieldOfView"})
					local NewValue = ((PullingBack and (((FieldOfView - 0.25) < 55 and 55) or (FieldOfView - 0.25))) or 70)
					if FieldOfView then
						InvokeClient("SetCamera", {Property = "FieldOfView", Value = NewValue})
					end
				end)
				wait(0.001)
			end
			PullingBack = false
			spawn(function()
				InvokeClient("SetCamera", {Property = "FieldOfView", Value = 70})
			end)
		end
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped(Mouse)
	ToolEquipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	spawn(function()
		for i, v in pairs({Quiver, Arrow, EquipArrow}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		CreateQuiver()
		if ArrowExists then
			CreateArrow()
		end
		local RemoverClone = Remover:Clone()
		RemoverClone.Name = (Player.Name .. Remover.Name)
		local CreatorValue = Instance.new("ObjectValue")
		CreatorValue.Name = "Creator"
		CreatorValue.Value = Player
		CreatorValue.Parent = RemoverClone
		local ToolValue = Instance.new("ObjectValue")
		ToolValue.Name = "Tool"
		ToolValue.Value = Tool
		ToolValue.Parent = RemoverClone
		RemoverClone.Disabled = false
		RemoverClone.Parent = game:GetService("Workspace")
	end)
end

function Unequipped()
	ToolEquipped = false
	MouseDown = false
	ArrowExists = (((Arrow and Arrow.Parent) and true) or false)
	spawn(function()
		for i, v in pairs({ToolUnequipped}) do
			if v then
				v:disconnect()
			end
		end
		for i, v in pairs({Quiver, Arrow, EquipArrow}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		if ArrowExists then
			CreateArrow()
		end
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
		for i, v in pairs(Sounds) do
			v:Stop()
			InvokeClient("StopSound", v)
		end
	end)
end

CreateArrow()
Tool.Enabled = true

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)