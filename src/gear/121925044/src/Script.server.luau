--Rescripted by Luckymaxer
--Made by Stickmasterluke

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

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

BaseArrow = BasePart:Clone()
BaseArrow.Name = "Arrrow"
BaseArrow.CanCollide = true
BaseArrow.Size = Vector3.new(0.2, 0.2, 2)
ArrowMesh = Instance.new("SpecialMesh")
ArrowMesh.MeshType = Enum.MeshType.FileMesh
ArrowMesh.MeshId = "http://www.roblox.com/asset/?id=95920149"
ArrowMesh.TextureId = "http://www.roblox.com/asset/?id=95920067"
ArrowMesh.Scale = Vector3.new(1, 1, 1)
ArrowMesh.VertexColor = Vector3.new(0.5, 0.5, 1)
ArrowMesh.Parent = BaseArrow

Animations = {
}

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	BoltThunk = Handle:WaitForChild("BoltThunk")
}

FireRate = 1.25
Range = 600
Power = 300
Rate = (1 / 30)
BarrelOffset = Vector3.new(0, 0, -1.5)
WindVec = Vector3.new(2, -1, 1).unit
Damage = 36

ToolEquipped = false

MouseDown = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" then
			MouseDown = Value.Down
			if MouseDown then
				Activated()
			end
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
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

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit:IsDescendantOf(Character) or Hit.Transparency > 0.8 or Hit.Name == "Handle" or string.lower(string.sub(Hit.Name, 1, string.len("effect"))) == "effect" or Hit.Name == "Laser" or string.lower(Hit.Name) == "water" or Hit.Name == "Rail" or Hit.Name == "Arrow" then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local RayHit, EndPos = game:GetService("Workspace"):FindPartOnRay(Ray.new(StartPos, (Vec * Length)), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, EndPos = CastRay((EndPos + (Vec * 0.01)), Vec, (Length - ((StartPos - EndPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, EndPos
end

function DrawBeam(BeamStart, BeamEnd, Color, FadeDelay)
	local Distance = (BeamStart - BeamEnd).magnitude
	local Laser = BasePart:Clone()
	Laser.Name = "Effect"
	Laser.Size = Vector3.new(0.2, 0.2, 0.2)
	Laser.Transparency = 5
	Laser.BrickColor = Color
	Laser.Anchored = true
	Laser.CanCollide = false
	Laser.Locked = true
	Laser.CFrame = CFrame.new(BeamEnd, BeamStart) * CFrame.new(0, 0, -(Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
	local Mesh = Instance.new("CylinderMesh")
	Mesh.Scale = Vector3.new(1, (Distance * 5), 1)
	Mesh.Parent = Laser
	Debris:AddItem(Laser, (FadeDelay * 3))
	Laser.Parent = game:GetService("Workspace")
	
	local Frames = math.floor(FadeDelay / Rate)
	for Frame = 1, Frames do
		wait(Rate)
		local Percent = (Frame / Frames)
		Laser.CFrame = Laser.CFrame + WindVec * Rate
		Laser.Transparency = (0.5 + (Percent * 0.5))
	end
	wait(1)
	if Laser and Laser.Parent then
		Laser:Destroy()
	end
end

function CreateDisplayArrow()
	local DisplayArrow = Tool:FindFirstChild("DisplayArrow")
	if DisplayArrow then
		DisplayArrow:Destroy()
	end
	local Arrow = BaseArrow:Clone()
	Arrow.Name = "DisplayArrow"
	local ArrowWeld = Instance.new("ManualWeld")
	ArrowWeld.Name = "BoltWeld"
	ArrowWeld.Part0 = Handle
	ArrowWeld.Part1 = Arrow
	ArrowWeld.C0 = CFrame.new(-0.55730772, 3.90196061, 1.36524463, -0.0906230509, 8.74039685e-008, 0.995885134, 0.020665383, -0.999784708, 0.00188058591, 0.995670736, 0.0207507778, 0.0906035379)
	ArrowWeld.C1 = CFrame.new(-0.595792472, 4.06199789, 1.68520331, -0.0906147435, -0.000366874214, 0.995877445, 0.0206984486, -0.999780536, 0.00151505659, 0.995665669, 0.0207505878, 0.0906030536)
	ArrowWeld.Parent = Arrow
	Arrow.Parent = Tool
end

function Activated()
	if ToolEquipped and Tool.Enabled and CheckIfAlive() then
		
		Tool.Enabled = false
		local StartPos = Head.Position
		local FakeStartPos = (Handle.CFrame * CFrame.new(BarrelOffset)).p
		local MousePosition = InvokeClient("MousePosition")
		local Vec = (MousePosition - StartPos).unit
		
		local Arrow = BaseArrow:Clone()		
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "creator"
		Creator.Value = Player
		Creator.Parent = Arrow
		local Sound = Sounds.BoltThunk:Clone()
		Sound.Parent = Arrow
		local RayHit, RayPos = CastRay(StartPos, Vec, Range, Character, false)
		local FakeVec = (RayPos - FakeStartPos).unit
		if RayHit then
			local NewCF = CFrame.new(RayPos, (RayPos + FakeVec)) * CFrame.new(0, 0, 0.5)
			Arrow.CFrame = NewCF
			local Weld = Instance.new("Weld")
			Weld.Part0 = RayHit
			Weld.Part1 = Arrow
			Weld.C0 = RayHit.CFrame:inverse() * NewCF
			Weld.C1 = NewCF:inverse() * NewCF
			Weld.Parent = Arrow
			Sound:Play()
			local character = RayHit.Parent
			if character ~= Character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
				end
			end
		else
			Arrow.CFrame = CFrame.new(RayPos, (RayPos + FakeVec))
			Arrow.Velocity = (FakeVec * Power)
		end
		Debris:AddItem(Arrow, 20)
		Arrow.Parent = game:GetService("Workspace")
		Spawn(function()
			DrawBeam(FakeStartPos, RayPos, BrickColor.new("Institutional white"), 0.25)
		end)
		Sounds.Fire:Play()
		DisplayArrow = Tool:FindFirstChild("DisplayArrow")
		if DisplayArrow then
			DisplayArrow.Transparency = 1
		end
		wait(FireRate)
		DisplayArrow.Transparency = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	Spawn(function()
		CreateDisplayArrow()
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

CreateDisplayArrow()

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)