--Rescripted by Luckymaxer
--Made by Stickmasterluke

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Debris = game:GetService("Debris")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Anchored = false
BasePart.Locked = true
BasePart.CanCollide = true

Animations = {
	Fly = {Animation = Tool:WaitForChild("Fly"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Fire = Handle:WaitForChild("FireSound"),
	Wings = Handle:WaitForChild("WingSound"),
	BoltThunk = Handle:WaitForChild("BoltThunk")
}

BaseScale = Vector3.new(1, 1, 0.7)
Mesh.Scale = BaseScale

RapidFireDamage = 14

Range = 350

Rate = (1 / 60)

BarrelOffset = Vector3.new(-0.05, 0.5, -1.5)
WindVec = Vector3.new(2, -1, 1).unit

ChargeMode = 1
RapidFireMode = 2

LastFlap = 0

Charge = 0
FireMode = 1

Flying = false
Check = true

MouseDown = false
ToolEquipped = false

Wing = BasePart:Clone()
Wing.Name = "Wing"
Wing.CanCollide = false
Wing.Size = Vector3.new(4, 4, 0.6)
WingMesh = Instance.new("SpecialMesh")
WingMesh.MeshType = Enum.MeshType.FileMesh
WingMesh.TextureId = "http://www.roblox.com/asset/?id=111825642"
WingMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
WingMesh.Parent = Wing

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrow"
BaseArrow.Size = Vector3.new(0.3, 0.3, 2.7)
BaseArrow.CanCollide = true
ArrowMesh = Instance.new("SpecialMesh")
ArrowMesh.MeshType = Enum.MeshType.FileMesh
ArrowMesh.MeshId = "http://www.roblox.com/asset/?id=92189547"
ArrowMesh.TextureId = "http://www.roblox.com/asset/?id=92189351"
ArrowMesh.Scale = Vector3.new(1, 1, 2)
ArrowMesh.VertexColor = Vector3.new(0.1, 0.1, 0.2)
ArrowMesh.Parent = BaseArrow

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Mesh.Scale = BaseScale
Handle.Transparency = 0
Tool.Enabled = true

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit:IsDescendantOf(Character) or Hit.Transparency > 0.8 or Hit.Name == "Handle" or Hit.Name == "Effect" or Hit.Name == "Bullet" or Hit.Name == "Laser" or string.lower(Hit.Name) == "water" or Hit.Name == "Rail" or Hit.Name == "Arrow" then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, (Vec * Length)), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos
end

function DrawBeam(StartPos, EndPos, Color, FadeDelay)
	local Distance = (StartPos - EndPos).magnitude
	local Laser = BasePart:Clone()
	Laser.Name = "Effect"
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.BrickColor = Color
	Laser.Anchored = true
	Laser.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.Head
	Mesh.Scale = Vector3.new(BaseScale.X, (Distance * 5), BaseScale.Z)
	Mesh.Parent = Laser
	Laser.CFrame = CFrame.new(StartPos, EndPos) * CFrame.new(0, 0, (-Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	Debris:AddItem(Laser, (FadeDelay * 3))
	Laser.Parent = game:GetService("Workspace")
	
	local Frames = math.floor(FadeDelay / Rate)
	for Frame = 1, Frames do
		wait(Rate)
		local Percent = (Frame / Frames)
		Laser.CFrame = Laser.CFrame + WindVec * Rate
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	Debris:AddItem(Laser, 1)
end

function HandleDamage(Hit, Damage)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = Hit.Parent
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 and CheckIfAlive() then
		humanoid:TakeDamage(Damage)
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
	end
end

function Fire(TargetPos, StartPos, Damage, FadeDelay)
	local FakeStartPos = (Handle.CFrame * CFrame.new(BarrelOffset)).p
	local Vec = (TargetPos - StartPos).unit

	local Arrow = BaseArrow:Clone()	
	
	local Sound = Sounds.BoltThunk:Clone()
	Sound.Parent = Arrow
	Sound:Play()
	
	local RayHit, RayPos = CastRay(StartPos, Vec, Range, Character, false)
	local FakeVec = (RayPos - FakeStartPos).unit
	if RayHit then
		local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, (0.9 + (math.random(0, 1) * 0.4)))
		local StickWeld = Instance.new("Weld")
		StickWeld.Part0 = RayHit
		StickWeld.Part1 = Arrow
		StickWeld.C0 = (RayHit.CFrame:inverse() * NewCF)
		StickWeld.C1 = (NewCF:inverse() * NewCF)
		StickWeld.Parent = Arrow
		Arrow.CFrame = NewCF
		HandleDamage(RayHit, Damage)
	else
		Arrow.CFrame = CFrame.new(RayPos, (RayPos + FakeVec))
		Arrow.Velocity = (FakeVec * 300)
	end
	
	Debris:AddItem(Arrow, (10 + (math.random() * 10)))
	Arrow.Parent = game:GetService("Workspace")

	Spawn(function()
		DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), FadeDelay)
	end)

	Sounds.Fire:Play()
	
	if DisplayArrow and DisplayArrow.Parent then
		DisplayArrow:Destroy()
	end
	
end

function RemoveFlyStuff()
	InvokeClient("StopAnimation", Animations.Fly)
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") and v.Name == "LeftWing" or v.Name == "RightWing" then
			v:Destroy()
		end
	end
end

function CreateDisplayArrow()
	DisplayArrow = Tool:FindFirstChild("DisplayArrow")
	if DisplayArrow then
		DisplayArrow:Destroy()
	end
	DisplayArrow = BaseArrow:Clone()
	DisplayArrow.Name = "DisplayArrow"
	DisplayArrow.CanCollide = false
	DisplayArrow.Mesh.Scale = Vector3.new(1, 1, 1.5)
	DisplayWeld = Instance.new("Weld")
	DisplayWeld.Part0 = Handle
	DisplayWeld.Part1 = DisplayArrow
	DisplayWeld.C0 = CFrame.new(-0.05, 0, -0.5, -4.37113883e-008, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-008)
	DisplayWeld.C1 = CFrame.new(0, 0, 0, 1.91068547e-015, -4.37113883e-008, 1, 0, 1, 4.37113883e-008, -1, 0, 1.91068547e-015)
	DisplayWeld.Parent = DisplayArrow
	DisplayArrow.Parent = Tool
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		for i, v in pairs(Animations) do
			if v and v.Animation then
				InvokeClient("Preload", v.Animation.AnimationId)
			end
		end
	end)
	Spawn(CreateDisplayArrow)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	RemoveFlyStuff()
	MouseDown = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not value or not CheckIfAlive() then
		return
	end
	if mode == "MouseClick" then
		local Down = value.Down
		if Down and not MouseDown and Check then
			MouseDown = true
			Spawn(function()
				while MouseDown and CheckIfAlive() do
					local Waited = false
					if Check then
						if FireMode == RapidFireMode then
							Check = false
							Mesh.Scale = Vector3.new(BaseScale.X, BaseScale.Y, (BaseScale.Z + 0.2))
							DisplayWeld.C0 = CFrame.new(-0.05, 0, 0) * CFrame.Angles(0, (math.pi / 2),0)
							wait(0.1)
							Mesh.Scale = BaseScale
							Fire(InvokeClient("MousePosition").Position, Handle.Position, RapidFireDamage, 0.25)
							wait(0.15)
							DisplayWeld.C0 = CFrame.new(-0.05, 0, -0.5) * CFrame.Angles(0, (math.pi / 2), 0)
							CreateDisplayArrow()
							wait(0.15)
							Waited = true
							Check = true
						elseif FireMode == ChargeMode then
							if Charge < 100 then
								Charge = (Charge + 1.25)
								local Percent = (Charge / 100)
								Mesh.Scale = Vector3.new(BaseScale.X, BaseScale.Y, (BaseScale.Z + (BaseScale.Z * (Percent * 0.6))))
								DisplayWeld.C0 = CFrame.new(-0.05, 0, (-0.5 + Percent)) * CFrame.Angles(0, (math.pi / 2), 0)
								wait(0.05)
								Waited = true
							end
						end
					end
					wait(Rate)
				end
			end)
		elseif not Down and MouseDown then
			MouseDown = false
			if FireMode == ChargeMode and CheckIfAlive() then
				Check = false
				Fire(InvokeClient("MousePosition").Position, Handle.Position, (Charge + 10), (0.25 + (Charge / 50)))
				Charge = 0
				Mesh.Scale = BaseScale
				DisplayWeld.C0 = CFrame.new(-0.05, 0, -0.5) * CFrame.Angles(0, (math.pi / 2), 0)
				wait(0.75)
				CreateDisplayArrow()
				wait(0.25)
				Check = true
			end
		end
	elseif mode == "KeyPress" then
		local Key = value.Key
		local ByteKey = string.byte(Key)
		local Down = value.Down
	elseif mode == "Flying" then
		local Mode = value.Mode
		RemoveFlyStuff()
		
		if Mode then
			
			LeftWing = Wing:Clone()
			LeftWing.Name = "LeftWing"
			LeftWing.Mesh.MeshId = "http://www.roblox.com/asset/?id=111896510"
			
			LeftWeld = Instance.new("Motor")
			LeftWeld.Name = "LeftWeld"
			LeftWeld.Part0 = Torso
			LeftWeld.Part1 = LeftWing
			LeftWeld.MaxVelocity = 0.2
			LeftWeld.C0 = CFrame.new(-0.25, 1, 0.25) * CFrame.Angles((math.pi / 2), 0, 0)
			LeftWeld.C1 = CFrame.new(2, -1, -0.25) * CFrame.Angles((math.pi / 2), 0, 0)
			LeftWeld.Parent = LeftWing
			
			RightWing = Wing:Clone()
			RightWing.Name = "RightWing"
			RightWing.Mesh.MeshId = "http://www.roblox.com/asset/?id=111893941"
			
			RightWeld = Instance.new("Motor")
			RightWeld.Name = "RightWeld"
			RightWeld.Part0 = Torso
			RightWeld.Part1 = RightWing
			RightWeld.MaxVelocity = 0.2
			RightWeld.C0 = CFrame.new(0.25, 1, 0.25) * CFrame.Angles((math.pi / 2), 0, 0)
			RightWeld.C1 = CFrame.new(-2, -1, -0.25) * CFrame.Angles((math.pi / 2), 0, 0)
			RightWeld.Parent = RightWing
	
			LeftWing.Parent = Character
			RightWing.Parent = Character
			
			Spawn(function()
				InvokeClient("PlayAnimation", Animations.Fly)
			end)
			
		else
			InvokeClient("StopAnimation", Animations.Fly)
		end
	elseif mode == "SetMode" then
		Charge = 0
		FireMode = value
	elseif mode == "SetWingSpan" then
		local Value = value.Value
		for i, v in pairs({LeftWeld, RightWeld}) do
			if v and v.Parent then
				v.DesiredAngle = (Value * ((v == LeftWeld and 1) or -1))
			end
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
