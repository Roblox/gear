--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Remover = script:WaitForChild("Remover")

Objects = require(Tool:WaitForChild("Objects"))
R15 = false

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

KillerWhale = BasePart:Clone()
KillerWhale.Name = "KillerWhale"
KillerWhale.Size = Vector3.new(1, 1, 2.25)
KillerWhaleMesh = Instance.new("SpecialMesh")
KillerWhaleMesh.MeshType = Enum.MeshType.FileMesh
KillerWhaleMesh.MeshId = "http://www.roblox.com/asset?id=187011088"
KillerWhaleMesh.TextureId = "http://www.roblox.com/asset?id=187011121"
KillerWhaleMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
KillerWhaleMesh.VertexColor = Vector3.new(1, 1, 1)
KillerWhaleMesh.Parent = KillerWhale

MouseIcon = "http://www.roblox.com/asset?id=187746799"

Grips = {
	Equipped = CFrame.new(0, -0.899999976, 0.25, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Zoom = CFrame.new(0, -0.899999976, 0.25, 0.73201704, 0.0497210845, 0.679469526, -0.208041042, 0.966009676, 0.153441057, -0.648744941, -0.253679007, 0.717479587),
	R15Zoom = CFrame.new(0, -0.899999976, 0.25),
}

Animations = {
	Zoom = {Animation = Tool:WaitForChild("Zoom"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	ZoomFire = {Animation = Tool:WaitForChild("ZoomFire"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1},
	Fire = {Animation = Tool:WaitForChild("Fire"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1},
	R15Zoom = {Animation = Tool:WaitForChild("R15Zoom"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15ZoomFire = {Animation = Tool:WaitForChild("R15ZoomFire"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1},
	R15Fire = {Animation = Tool:WaitForChild("R15Fire"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1},	
}

Sounds = {
	Zoom = Handle:WaitForChild("Zoom"),
	Reload = Handle:WaitForChild("Reload"),
	Fire = Handle:WaitForChild("Fire")
}

ToolEquipped = false

ReloadTime = 10

SpreadCoolDownTime = 0.125
ZoomSpread = 0

Gravity = 196.20

Zoomed = false

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

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if (Key == "q" or Key == "z") and Down then
				Zoomed = not Zoomed
				for i, v in pairs(Animations) do
					InvokeClient("StopAnimation", v)
				end
				if Zoomed then
					Player.CameraMode = Enum.CameraMode.LockFirstPerson
					InvokeClient("SetLocalTransparencyModifier", {Object = Handle, Transparency = 1})
					InvokeClient("SetMouseSensitivity", {Sensitivity = 0.1})
					for i, v in pairs({ZoomGui, CrosshairGui}) do
						if v and v.Parent then
							v:Destroy()
						end
					end
					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
						InvokeClient("PlayAnimation", Animations.R15Zoom)
					else
						InvokeClient("PlayAnimation", Animations.Zoom)
					end
					Tool.Grip = R15 and Grips.R15Zoom or Grips.Zoom
					Zoomed = true
					ZoomGui = Objects.CreateZoomGui()
					ZoomGui.Parent = PlayerGui
					local CrosshairGuiTable = Objects.CreateCrosshairGui()
					CrosshairGui = CrosshairGuiTable.Gui
					Spread = CrosshairGuiTable.Spread
					CrosshairGui.Parent = PlayerGui
					Spread:InvokeServer("SetSpread", ((Tool.Enabled and {Spread = ZoomSpread, Speed = 0.5}) or (Tool.Enabled and {Spread = SpreadCoolDownTime, Speed = 0})))
					CrosshairGui.ReloadingLabel.Visible = ((not Tool.Enabled and true) or false)
					InvokeClient("SetMouseIcon", MouseIcon)
				else
					Player.CameraMode = Enum.CameraMode.Classic
					InvokeClient("SetCamera", {Property = "FieldOfView", Value = 70})
					InvokeClient("SetLocalTransparencyModifier", {Object = Handle, Transparency = 0})
					InvokeClient("SetMouseSensitivity", {Sensitivity = 1})
					for i, v in pairs({ZoomGui, CrosshairGui}) do
						if v and v.Parent then
							v:Destroy()
						end
					end
					InvokeClient("SetMouseIcon", "")
					InvokeClient("StopAnimation", Animations.Zoom)
					Tool.Grip = Grips.Equipped
					Zoomed = false
				end
			end
		elseif Mode == "WheelMoved" and Zoomed then
			InvokeClient("PlaySound", Sounds.Zoom)
			local FieldOfView = InvokeClient("GetCamera", {Property = "FieldOfView"})
			local MinimumZoom = 70
			local MaximumZoom = 1
			local ChangeInterval = 2.5
			if Value.Forward then
				if FieldOfView and FieldOfView > MaximumZoom then
					local NewFieldOfView = (((FieldOfView - ChangeInterval) < MaximumZoom and MaximumZoom) or (FieldOfView - ChangeInterval))
					InvokeClient("SetCamera", {Property = "FieldOfView", Value = NewFieldOfView})
					InvokeClient("SetMouseSensitivity", {Sensitivity = ((GetPercentage(MaximumZoom, MinimumZoom, NewFieldOfView) + 1) / 1000)})
				end
			else
				if FieldOfView and FieldOfView < MinimumZoom then
					local NewFieldOfView = (((FieldOfView + ChangeInterval) > MinimumZoom and MinimumZoom) or (FieldOfView + ChangeInterval))
					InvokeClient("SetCamera", {Property = "FieldOfView", Value = NewFieldOfView})
					InvokeClient("SetMouseSensitivity", {Sensitivity = ((GetPercentage(MaximumZoom, MinimumZoom, NewFieldOfView) + 1) / 1000)})
				end
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

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
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

function CreateKillerWhale()
	
	local MaxDistance = 500
	local HandleCFrame = Handle.CFrame	
	
	local KillerWhaleClone = KillerWhale:Clone()
	KillerWhaleClone.CanCollide = false
		
	local Destination = InvokeClient("MousePosition")	
	local SpawnPosition = HandleCFrame + HandleCFrame.lookVector * ((Handle.Size.Z / 2) + (KillerWhale.Size.Z / 2))	
	local Distance = (HandleCFrame.p - Destination).magnitude
	
	if Distance >= MaxDistance then
		Destination = (SpawnPosition + CFrame.new(SpawnPosition.p, Destination).lookVector * MaxDistance).p
	end
	
	Distance = (HandleCFrame.p - Destination).magnitude
	
	local MidPoint = HandleCFrame + CFrame.new(SpawnPosition.p, Destination).lookVector * (Distance / 2)
	MidPoint = MidPoint.p + Vector3.new(0, (Distance / 2), 0)

	local Direction = CFrame.new(SpawnPosition.p, MidPoint)
	
	local Mass = (KillerWhaleClone:GetMass() * Gravity * 10000)
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyPosition.Parent = KillerWhaleClone
	BodyPosition.position = SpawnPosition.p
	
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.Parent = KillerWhaleClone
	BodyGyro.cframe = Direction
	
	local MaximumSize = Vector3.new(10, 10, 20)
	
	Debris:AddItem(KillerWhaleClone, 10)
	KillerWhaleClone.Parent = game:GetService("Workspace")
	KillerWhaleClone.CFrame = SpawnPosition
	KillerWhaleClone.CFrame = Direction
	
	Delay(0.25, function()
		if KillerWhaleClone and KillerWhaleClone.Parent then
			KillerWhaleClone.CanCollide = true
		end
	end)
	
	local Touched = false

	local CurrentPlayer = Player
	local CurrentCharacter = Character
	
	local KillerWhaleHit = KillerWhaleClone.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or KillerWhaleClone.Velocity.Y >= 10 then
			return
		end
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if character == CurrentCharacter then
			return
		end
		if humanoid and humanoid.Health > 0 then
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("BasePart") then
					v.Velocity = Vector3.new(0, 0, 0)
					v.RotVelocity = Vector3.new(0, 0, 0)
				end
			end
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, CurrentPlayer)
			humanoid:TakeDamage(10)
		end
	end)
	
	Spawn(function()
		for i = 1, 10 do
			local WhaleCFrame = KillerWhaleClone.CFrame
			KillerWhaleClone.Size = ((MaximumSize / 10) * i)
			KillerWhaleClone.Mesh.Scale = Vector3.new((KillerWhaleClone.Size.X / 2), (KillerWhaleClone.Size.Y / 2), (KillerWhaleClone.Size.Z / 4))
			KillerWhaleClone.CFrame = WhaleCFrame
			wait(0.01)
		end
	end)
	
	Spawn(function()
		local AttemptTick = tick()
		while KillerWhaleClone and KillerWhaleClone.Parent and BodyPosition and BodyPosition.Parent and BodyGyro and BodyGyro.Parent and (KillerWhaleClone.Position - MidPoint).magnitude > 10 and (tick() - AttemptTick) < 5 do
			Direction = CFrame.new(KillerWhaleClone.Position, MidPoint)
			BodyGyro.cframe = Direction
			BodyPosition.position = BodyPosition.position + Direction.lookVector * 5
			wait()
		end
		if KillerWhaleClone and KillerWhaleClone.Parent and BodyPosition and BodyPosition.Parent and BodyGyro and BodyGyro.Parent then
			local AttemptTick = tick()
			while KillerWhaleClone and KillerWhaleClone.Parent and BodyPosition and BodyPosition.Parent and BodyGyro and BodyGyro.Parent and (KillerWhaleClone.Position - Destination).magnitude > 10 and (tick() - AttemptTick) < 5 do
				Direction = CFrame.new(KillerWhaleClone.Position, Destination)
				BodyGyro.cframe = Direction * CFrame.Angles((math.pi / 4), 0, 0)
				BodyPosition.position = BodyPosition.position + Direction.lookVector * 5
				wait()
			end
			local RayHit, RayPos = RayCast(KillerWhaleClone.Position, Vector3.new(0, -1, 0), KillerWhaleClone.Size.Y, {CurrentCharacter, KillerWhaleClone})
			if not RayHit then
				if BodyPosition and BodyPosition.Parent then
					BodyPosition.maxForce = Vector3.new(BodyPosition.maxForce.X, 0, BodyPosition.maxForce.Y)
				end
			end
			Delay(2, function()
				if KillerWhaleHit then
					KillerWhaleHit:disconnect()
				end
			end)
		end
	end)
end

function Activated()
	
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	
	Tool.Enabled = false
	
	local CurrentlyEquipped = true
	local ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Sounds.Fire:Play()
	
	local Animation = ((Zoomed and Animations.ZoomFire) or Animations.Fire)
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = ((Zoomed and Animations.R15ZoomFire) or Animations.R15Fire)
	end
	InvokeClient("PlayAnimation", Animation)
	
	if Zoomed and CrosshairGui and Spread then
		CrosshairGui.ReloadingLabel.Visible = true
		Spread:InvokeServer("SetSpread", {Spread = SpreadCoolDownTime, Speed = 0.5})
	end
	
	Spawn(function()
		CreateKillerWhale()
	end)
	
	Spawn(function()
		wait(Animation.Duration)
		if CurrentlyEquipped then
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			InvokeClient("StopAnimation", Animation)
		end
	end)
	
	wait(ReloadTime)
	
	if ToolEquipped then
		Sounds.Reload:Play()
	end
	
	wait(0.25)
	
	if Zoomed and CrosshairGui and Spread then
		CrosshairGui.ReloadingLabel.Visible = false
		Spread:InvokeServer("SetSpread", {Spread = ZoomSpread, Speed = 0.25})
	end
	
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and PlayerGui and PlayerGui.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	R15 = Humanoid.RigType == Enum.HumanoidRigType.R15
	Tool.Grip = Grips.Equipped
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	local RemoverScript = game:GetService("Workspace"):FindFirstChild(Player.Name .. Remover.Name)
	if RemoverScript then
		RemoverScript:Destroy()
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
	ToolEquipped = true
end

function Unequipped()
	Zoomed = false
	InvokeClient("SetCamera", {Property = "FieldOfView", Value = 70})
	InvokeClient("SetMouseSensitivity", {Sensitivity = 1})
	if Player and Player.Parent then
		Player.CameraMode = Enum.CameraMode.Classic
	end
	for i, v in pairs({ZoomGui, CrosshairGui}) do
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
	InvokeClient("SetLocalTransparencyModifier", {Object = Handle, Transparency = 0})
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)