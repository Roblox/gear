--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Meshes = {
	GrappleWithHook = 33393806,
	Grapple = 30308256,
	Hook = 30307623,
}

Animations = {
	Crouch = {Animation = Tool:WaitForChild("Crouch"), FadeTime = 0.25, Weight = nil, Speed = nil},
	R15Crouch = {Animation = Tool:WaitForChild("R15Crouch"), FadeTime = 0.25, Weight = nil, Speed = nil},
}

Sparks = script:WaitForChild("Sparks")

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Connect = Handle:WaitForChild("Connect"),
	Hit = Handle:WaitForChild("Hit"),
}

for i, v in pairs(Meshes) do
	Meshes[i] = (BaseUrl .. v)
end

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

BaseRope = BasePart:Clone()
BaseRope.Name = "Effect"
BaseRope.BrickColor = BrickColor.new("Really black")
BaseRope.Anchored = true
BaseRope.CanCollide = false
Create("CylinderMesh"){
	Scale = Vector3.new(1, 1, 1),
	Parent = BaseRope,
}

BaseGrappleHook = BasePart:Clone()
BaseGrappleHook.Name = "Projectile"
BaseGrappleHook.Transparency = 0
BaseGrappleHook.Size = Vector3.new(1, 0.4, 1)
BaseGrappleHook.Anchored = false
BaseGrappleHook.CanCollide = true
Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "30307623"),
	TextureId = (BaseUrl .. "285550035"),
	Scale = Mesh.Scale,
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseGrappleHook,
}
Create("BodyGyro"){
	Parent = BaseGrappleHook,
}
HookSparks = Sparks:Clone()
Create("NumberValue"){
	Name = "Duration",
	Value = 0.25,
	Parent = HookSparks
}
HookSparks.Parent = BaseGrappleHook
for i, v in pairs({Sounds.Connect, Sounds.Hit}) do
	local Sound = v:Clone()
	Sound.Parent = BaseGrappleHook
end

Gravity = 196.20
Rate = (1 / 60)

MaxDistance = 200
CanFireWhileGrappling = true

Crouching = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Mesh.MeshId = Meshes.GrappleWithHook
Handle.Transparency = 0
Tool.Enabled = true

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet", "GrappleHook"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function AdjustRope()
	if not Rope or not Rope.Parent or not CheckIfGrappleHookAlive() then
		return
	end
	local StartPosition = Handle.Position
	local EndPosition = GrappleHook.Position
	local RopeLength = (StartPosition - EndPosition).Magnitude
	Rope.Size = Vector3.new(1, 1, 1)
	Rope.Mesh.Scale = Vector3.new(0.1, RopeLength, 0.1)
	Rope.CFrame = (CFrame.new(((StartPosition + EndPosition) / 2), EndPosition) * CFrame.Angles(-(math.pi / 2), 0, 0))
end

function DisconnectGrappleHook(KeepBodyObjects)
	for i, v in pairs({Rope, GrappleHook, GrappleHookChanged}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif type(v) == "userdata" and v.Parent then
				v:Destroy()
			end
		end
	end
	if CheckIfAlive() and not KeepBodyObjects then
		for i, v in pairs(Torso:GetChildren()) do
			if string.find(string.lower(v.ClassName), string.lower("Body")) then
				v:Destroy()
			end
		end	
	end
	Connected = false
	Mesh.MeshId = Meshes.GrappleWithHook
end

function TryToConnect()
	if not ToolEquipped or not CheckIfAlive() or not CheckIfGrappleHookAlive() or Connected then
		DisconnectGrappleHook()
		return
	end
	local DistanceApart = (Torso.Position - GrappleHook.Position).Magnitude
	if DistanceApart > MaxDistance then
		DisconnectGrappleHook()
		return
	end
	local Directions = {Vector3.new(0, 1, 0), Vector3.new(0, -1, 0), Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1)}
	local ClosestRay = {DistanceApart = math.huge}
	for i, v in pairs(Directions) do
		local Direction = CFrame.new(GrappleHook.Position, (GrappleHook.CFrame + v * 2).p).lookVector
		local RayHit, RayPos, RayNormal = CastRay((GrappleHook.Position + Vector3.new(0, 0, 0)), Direction, 2, {Character, GrappleHook, Rope}, false)
		if RayHit then
			local DistanceApart = (GrappleHook.Position - RayPos).Magnitude
			if DistanceApart < ClosestRay.DistanceApart then
				ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
			end
		end
	end
	if ClosestRay.Hit then
		Connected = true
		local GrappleCFrame = CFrame.new(ClosestRay.Pos, (CFrame.new(ClosestRay.Pos) + ClosestRay.Normal * 2).p) * CFrame.Angles((math.pi / 2), 0, 0)
		GrappleCFrame = (GrappleCFrame * CFrame.new(0, -(GrappleHook.Size.Y / 1.5), 0))
		GrappleCFrame = (CFrame.new(GrappleCFrame.p, Handle.Position) * CFrame.Angles(0, math.pi, 0))
		local Weld = Create("Motor6D"){
			Part0 = GrappleHook,
			Part1 = ClosestRay.Hit,
			C0 = GrappleCFrame:inverse(),
			C1 = ClosestRay.Hit.CFrame:inverse(),
			Parent = GrappleHook,
		}
		for i, v in pairs(GrappleHook:GetChildren()) do
			if string.find(string.lower(v.ClassName), string.lower("Body")) then
				v:Destroy()
			end
		end	
		local HitSound = GrappleHook:FindFirstChild("Hit")
		if HitSound then
			HitSound:Play()
		end
		local BackUpGrappleHook = GrappleHook
		local HookSparks = GrappleHook:FindFirstChild("Sparks")
		if HookSparks then
			HookSparks.Enabled = true
			local ParticleScript = HookSparks:FindFirstChild("ParticleScript")
			if ParticleScript then
				ParticleScript.Disabled = false
			end
		end
		wait(0.4)
		if not CheckIfGrappleHookAlive() or GrappleHook ~= BackUpGrappleHook then
			return
		end
		Sounds.Connect:Play()
		local ConnectSound = GrappleHook:FindFirstChild("Connect")
		if ConnectSound then
			ConnectSound:Play()
		end
		
		for i, v in pairs(Torso:GetChildren()) do
			if string.find(string.lower(v.ClassName), string.lower("Body")) then
				v:Destroy()
			end
		end	
		
		local TargetPosition = GrappleHook.Position
		local BackUpPosition = TargetPosition
		
		local BodyPos = Create("BodyPosition"){
			D = 1000,
			P = 3000,
			maxForce = Vector3.new(1000000, 1000000, 1000000),
			position = TargetPosition,
			Parent = Torso,
		}
		
		local BodyGyro = Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, math.huge, math.huge),
			cframe = CFrame.new(Torso.Position, Vector3.new(GrappleCFrame.p.X, Torso.Position.Y, GrappleCFrame.p.Z)),
			Parent = Torso,
		}
	
		Spawn(function()
			while TargetPosition == BackUpPosition and CheckIfGrappleHookAlive() and Connected and ToolEquipped and CheckIfAlive() do
				BodyPos.position = GrappleHook.Position
				wait()
			end
		end)
		
	end
end

function CheckIfGrappleHookAlive()
	return (((GrappleHook and GrappleHook.Parent --[[and Rope and Rope.Parent]]) and true) or false)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		return
	end
	MousePosition = MousePosition.Position
	if CheckIfGrappleHookAlive() then
		if not CanFireWhileGrappling then
			return
		end
		if GrappleHookChanged then
			GrappleHookChanged:disconnect()
		end
		DisconnectGrappleHook(true)
	end
	if GrappleHookChanged then
		GrappleHookChanged:disconnect()
	end
	Tool.Enabled = false
	Sounds.Fire:Play()
	Mesh.MeshId = Meshes.Grapple
	GrappleHook = BaseGrappleHook:Clone()
	GrappleHook.CFrame = (CFrame.new((Handle.Position + (MousePosition - Handle.Position).Unit * 5), MousePosition) * CFrame.Angles(0, 0, 0))
	local Weight = 70
	GrappleHook.Velocity = (GrappleHook.CFrame.lookVector * Weight)
	local Force = Create("BodyForce"){
		force = Vector3.new(0, Weight, 0),
		Parent = GrappleHook,
	}
	GrappleHook.Parent = Tool
	GrappleHookChanged = GrappleHook.Changed:connect(function(Property)
		if Property == "Parent" then
			DisconnectGrappleHook()
		end
	end)
	Rope = BaseRope:Clone()
	Rope.Parent = Tool
	Spawn(function()
		while CheckIfGrappleHookAlive() and ToolEquipped and CheckIfAlive() do
			AdjustRope()
			Spawn(function()
				if not Connected then
					TryToConnect()
				end
			end)
			wait()
		end
	end)
	wait(2)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		DisconnectGrappleHook()
		if HumanoidJumping then
			HumanoidJumping:disconnect()
		end
		HumanoidJumping = Humanoid.Jumping:connect(function()
			DisconnectGrappleHook()
		end)
	end)
	Crouching = false
	ToolEquipped = true
end

function Unequipped()
	if HumanoidJumping then
		HumanoidJumping:disconnect()
	end
	DisconnectGrappleHook()
	Crouching = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
		if Key == "q" and Down then
			DisconnectGrappleHook()
		elseif Key == "c" and Down then
			Crouching = not Crouching
			Spawn(function()
				local Animation = Animations.Crouch
				if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Animation = Animations.R15Crouch
				end
				InvokeClient(((Crouching and "PlayAnimation") or "StopAnimation"), Animation)
			end)
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

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)