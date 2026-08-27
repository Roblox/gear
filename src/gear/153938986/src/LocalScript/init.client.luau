--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")
ArrowScript = script:WaitForChild("ArrowScript")
FaceChangeScript = script:WaitForChild("FaceChange")

ReloadArrow = Tool:WaitForChild("ReloadArrow")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
ContentProvider = game:GetService("ContentProvider")

PlaySound = Tool:WaitForChild("PlaySound")

FireSound = Handle:WaitForChild("FireSound")
HitSound = Handle:WaitForChild("HitSound")

QuackSounds = {Handle:FindFirstChild("Quack1"), Handle:FindFirstChild("Quack2"), Handle:FindFirstChild("Quack3"), Handle:FindFirstChild("Quack4")}

MouseDown = false
Firing = false
Animating = false

FireRate = 1.25
Range = 250
Power = 100
Rate = (1 / 30)
WindVec = Vector3.new(2, -1, 1).unit

Grips = {NormalGrip = CFrame.new(0.125, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1), FiringGrip = CFrame.new(0.125, 0, -0.30625--[[-0.300000012]], 1, 0, 0, 0, 1, 0, 0, 0, 1)}

Content = {BowAndArrow = 153674406, Bow = 153674416, Arrow = 153674424, Texture = 153674394}

for i, v in pairs(Content) do
	local NewContent = "http://www.roblox.com/asset?id=" .. tostring(v)
	Content[i] = NewContent
	ContentProvider:Preload(NewContent)
end

function Round(Number, Round_Decimal)
	local Whole_Number, Decimal = math.modf(Number)
	return ((Decimal >= Round_Decimal and math.ceil(Number)) or (Decimal < Round_Decimal and math.floor(Number)))
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

function CreateArrow()
	Arrow = Instance.new("Part")
	Arrow.Name = "Arrow"
	Arrow.TopSurface = Enum.SurfaceType.Smooth
	Arrow.BottomSurface = Enum.SurfaceType.Smooth
	Arrow.Material = Enum.Material.Plastic
	Arrow.Shape = Enum.PartType.Block
	Arrow.FormFactor = Enum.FormFactor.Custom
	Arrow.Size = Vector3.new(0.5, 0.5, 3.5)
	local ArrowMesh = Instance.new("SpecialMesh")
	ArrowMesh.MeshType = Enum.MeshType.FileMesh
	ArrowMesh.Scale = Vector3.new(1, 1, 1)
	ArrowMesh.MeshId = Content.Arrow
	ArrowMesh.TextureId = Content.Texture
	ArrowMesh.Parent = Arrow
	ArrowWeld = Instance.new("Weld")
	ArrowWeld.Name = "ArrowWeld"
	ArrowWeld.Part0 = Arrow
	ArrowWeld.Part1 = Handle
	ArrowWeld.C0 = CFrame.new(0.065, 0.075, 1.39)
	ArrowWeld.Parent = Arrow
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
	Delay(1, function()
		Laser:Destroy()
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid then
		return
	end
	if not Tool.Enabled then
		wait(FireRate)
		Tool.Enabled = true
	end
	if Mesh.MeshId == Content.BowAndArrow then
		CreateArrow()
	end
	Mouse.Button1Down:connect(function()
		if not MouseDown and Tool.Enabled and not Animating then
			if not Arrow then
				Animating = true
				CreateArrow()
				local LeftArm = Character:FindFirstChild("Left Arm")
				if LeftArm then
					FakeArrow = Arrow:Clone()
					FakeArrow.Name = "FakeArrow"
					FakeArrowWeld = Instance.new("Weld")
					FakeArrowWeld.Name = "FakeArrowWeld"
					FakeArrowWeld.Part0 = FakeArrow
					FakeArrowWeld.Part1 = LeftArm
					FakeArrowWeld.C0 = CFrame.new(0, 1, 0)
					FakeArrowWeld.Parent = FakeArrow
					Debris:AddItem(FakeArrow, 5)
					FakeArrow.Parent = Handle
				end
				ReloadArrowAnim = Humanoid:LoadAnimation(ReloadArrow)
				if ReloadArrowAnim then
					ReloadArrowAnim:Play()
				end
				wait(0.5)
				ReloadArrowAnim:Stop()
				if AnimDelay then
					AnimDelay:disconnect()
				end
				if FakeArrow then
					FakeArrow:Destroy()
				end
				Tool.Grip = Grips.NormalGrip
				Mesh.MeshId = Content.BowAndArrow
				Animating = false
			else
				MouseDown = true
				Firing = true
				Tool.Grip = Grips.FiringGrip
				Mesh.MeshId = Content.Bow
				Arrow.Parent = Handle
				Mesh.MeshId = Content.Bow
				DamageIncrease = 0
				while MouseDown and Arrow and Arrow.Parent and ArrowWeld and ArrowWeld.Parent and ArrowWeld.C0.Z >= -0.95 do
					wait()
					ArrowWeld.C0 = ArrowWeld.C0 - Vector3.new(0, 0, 0.01)
					DamageIncrease = DamageIncrease + 0.1
				end
				if ArrowWeld.C0.Z <= -0.95 then
					local Fire = Instance.new("Fire")
					Fire.Parent = Arrow
				end
			end
		end
	end)
	Mouse.Button1Up:connect(function()
		if MouseDown then
			MouseDown = false
			Firing = false
			if Arrow and Arrow.Parent then
				
				Tool.Enabled = false
				
				PlaySound.Value = FireSound.Name				
				
				local StartPos = Handle.Position
				local Vec = (Mouse.Hit.p - StartPos).unit
				
				local Hit, EndPos = CastRay(StartPos, Vec, Range, Character, false)
				local FakeVec = (EndPos - StartPos).unit

				if ArrowWeld and ArrowWeld.Parent then
					ArrowWeld:Destroy()
				end
				
				Debris:AddItem(Arrow, 20)
				Arrow.Parent = game:GetService("Workspace")				
				
				HitSoundClone = nil				
				
				if Hit then
					local NewCF = CFrame.new(EndPos, (EndPos + FakeVec)) * CFrame.new(0, 0, 0.5)
					Arrow.CFrame = NewCF
					local Weld = Instance.new("Weld")
					Weld.Part0 = Hit
					Weld.Part1 = Arrow
					Weld.C0 = Hit.CFrame:inverse() * NewCF
					Weld.C1 = NewCF:inverse() * NewCF
					Weld.Parent = Arrow
					if Hit and Hit.Parent then
						local character, humanoid = FindCharacterAncestor(Hit)
						if character and character ~= Character and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
							HitSoundClone = QuackSounds[math.random(1, #QuackSounds)]:Clone()
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage((Round(DamageIncrease, 0.05) + 1) * 4)
							if not humanoid:FindFirstChild(FaceChangeScript.Name) then
								local FaceChangeScriptClone = FaceChangeScript:Clone()
								FaceChangeScriptClone.Disabled = false
								FaceChangeScriptClone.Parent = humanoid
							end
						end
						if not HitSoundClone then
							HitSoundClone = HitSound:Clone()
						end
						HitSoundClone.Name = "HitSound"
						HitSoundClone.Parent = Arrow
						local ArrowScriptClone = ArrowScript:Clone()
						ArrowScriptClone.Disabled = false
						ArrowScriptClone.Parent = Arrow
					end
				else
					Arrow.CFrame = CFrame.new(EndPos, (EndPos + FakeVec))
					Arrow.CFrame = Arrow.CFrame + Arrow.CFrame.lookVector * 1.25
					Arrow.Velocity = (FakeVec * Power)
				end

				Spawn(function()
					DrawBeam(StartPos, EndPos, BrickColor.new("Institutional white"), 0.25)
				end)
				
				Arrow = nil
				
				wait(FireRate)
				
				Tool.Enabled = true
				
			end
		end
	end)
end

function Unequipped()
	if Firing then
		if Arrow and Arrow.Parent then
			Arrow:Destroy()
		end
		Arrow = nil
	end
	if FakeArrow and FakeArrow.Parent then
		FakeArrow:Destroy()
	end
	if ReloadArrowAnim then
		ReloadArrowAnim:Stop()
	end
	if AnimDelay then
		AnimDelay:disconnect()
	end
	MouseDown = false
	Firing = false
	Animating = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)