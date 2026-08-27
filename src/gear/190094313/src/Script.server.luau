--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

NormalSurfaceModule = require(Tool:WaitForChild("NormalSurfaceModule"))

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

SpeedBoostGui = Instance.new("ScreenGui")
SpeedBoostGui.Name = "SpeedBoostGui"
SpeedBoostFrame = Instance.new("Frame")
SpeedBoostFrame.Name = "Frame"
SpeedBoostFrame.BackgroundColor3 = Color3.new((255 / 255), (255 / 255), (255 / 255))
SpeedBoostFrame.BorderColor3 = Color3.new((0 / 255), (222 / 255), (222 / 255))
SpeedBoostFrame.BorderSizePixel = 2
SpeedBoostFrame.Position = UDim2.new(0.75, 0, 0.9, 0)
SpeedBoostFrame.Size = UDim2.new(0.2, 0, 0.075, 0)
SpeedBoostFrame.ZIndex = 1
SpeedBoostFrame.Parent = SpeedBoostGui
FuelDisplay = Instance.new("Frame")
FuelDisplay.Name = "FuelDisplay"
FuelDisplay.BackgroundColor3 = Color3.new((0 / 255), (255 / 255), (255 / 255))
FuelDisplay.BorderColor3 = Color3.new((0 / 255), (222 / 255), (222 / 255))
FuelDisplay.BorderSizePixel = 0
FuelDisplay.Position = UDim2.new(0, 0, 0)
FuelDisplay.Size = UDim2.new(1, 0, 1, 0)
FuelDisplay.ZIndex = 2
FuelDisplay.Parent = SpeedBoostFrame
HelpText = Instance.new("TextLabel")
HelpText.Name = "HelpText"
HelpText.BackgroundColor3 = Color3.new((255 / 255), (255 / 255), (255 / 255))
HelpText.BackgroundTransparency = 1
HelpText.BorderSizePixel = 0
HelpText.Position = UDim2.new(0, 0, 0, 0)
HelpText.Size = UDim2.new(1, 0, 0.35, 0)
HelpText.Font = Enum.Font.Legacy
HelpText.FontSize = Enum.FontSize.Size14
HelpText.Text = "(Hold Shift for boost)"
HelpText.TextColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
HelpText.TextStrokeColor3 = Color3.new((0 / 255), (0 / 255), (0 / 255))
HelpText.TextStrokeTransparency = 0.95
HelpText.TextTransparency = 0.5
HelpText.TextScaled = true
HelpText.TextWrapped = true
HelpText.TextXAlignment = Enum.TextXAlignment.Center
HelpText.TextYAlignment = Enum.TextYAlignment.Center
HelpText.ZIndex = 3
HelpText.Parent = SpeedBoostFrame
TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.BackgroundColor3 = Color3.new((255 / 255), (255 / 255), (255 / 255))
TitleText.BackgroundTransparency = 1
TitleText.BorderSizePixel = 0
TitleText.Position = UDim2.new(0, 0, 0.2, 0)
TitleText.Size = UDim2.new(1, 0, 0.8, 0)
TitleText.Font = Enum.Font.Arial
TitleText.FontSize = Enum.FontSize.Size14
TitleText.Text = "Rocket Boost"
TitleText.TextColor3 = Color3.new((0 / 255), (85 / 255), (255 / 255))
TitleText.TextStrokeColor3 = Color3.new((0 / 255), (0 / 255), (255 / 255))
TitleText.TextStrokeTransparency = 0.95
TitleText.TextTransparency = 0.5
TitleText.TextScaled = true
TitleText.TextWrapped = true
TitleText.TextXAlignment = Enum.TextXAlignment.Center
TitleText.TextYAlignment = Enum.TextYAlignment.Center
TitleText.ZIndex = 3
TitleText.Parent = SpeedBoostFrame

Animations = {
	IdleLegs = {Animation = Tool:WaitForChild("IdleLegs"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Tuck = {Animation = Tool:WaitForChild("Tuck"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil} --http://www.roblox.com/asset/?id=190071033
}

Sounds = {
}

SpeedBoost = {
	MaxFuel = 100,
	CurrentFuel = 100,
	IncreaseRate = 0.25,
	DecreaseRate = 0.5,
	UsageRate = (1 / 30),
	Regenerating = false,
	Active = false
}

LastUpdate = nil
State = "Stopped"
LastStateTime = 0

ToolEquipped = false
SkiActive = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

for i, v in pairs(Tool:GetChildren()) do
	if (v:IsA("BasePart") and v ~= Handle) then
		v:Destroy()
	end
end

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
			if ByteKey == 48 and SkiActive and ToolEquipped then
				if Down and not SpeedBoost.Active and SpeedBoost.CurrentFuel > (SpeedBoost.MaxFuel / 2) then
					SpeedBoost.Active = true
					SetSpeedBoost(true)
					while ToolEquipped and SpeedBoost.Active and SpeedBoost.CurrentFuel > 0 do
						SpeedBoost.CurrentFuel = (SpeedBoost.CurrentFuel - SpeedBoost.DecreaseRate)
						FuelDisplay.Size = UDim2.new((1 / (SpeedBoost.MaxFuel / SpeedBoost.CurrentFuel)), 0, 1, 0)
						wait(SpeedBoost.Rate)
					end
					SpeedBoost.Active = false
					SpeedBoost.CurrentFuel = ((SpeedBoost.CurrentFuel < 0 and 0) or SpeedBoost.CurrentFuel)
					SetSpeedBoost(false)
					RegenerateFuel()
				else
					SpeedBoost.Active = false
					SetSpeedBoost(false)
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

function RayCast1(Position, Direction, MaxDistance, IgnoreList)
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

function SetSpeedBoost(Boolean)
	for i, v in pairs({LeftSki, RightSki}) do
		local RocketPart = v:FindFirstChild("RocketPart")
		if RocketPart then
			local Weld = RocketPart:FindFirstChild("Weld")
			if Weld and Weld.Part0 == v and Weld.Part1 == RocketPart then
				for ii, vv in pairs(RocketPart:GetChildren()) do
					if vv:IsA("Fire") then
						vv.Enabled = Boolean
					end
				end
			end
		end
	end
end

function RegenerateFuel()
	Spawn(function()
		if SpeedBoost.Regenerating then
			return
		end
		while --[[ToolEquipped and]] not SpeedBoost.Active and SpeedBoost.CurrentFuel < SpeedBoost.MaxFuel do
			SpeedBoost.Regenerating = true
			SpeedBoost.CurrentFuel = (SpeedBoost.CurrentFuel + SpeedBoost.IncreaseRate)
			FuelDisplay.Size = UDim2.new((1 / (SpeedBoost.MaxFuel / SpeedBoost.CurrentFuel)), 0, 1, 0)
			wait(SpeedBoost.UsageRate)
		end
		SpeedBoost.Regenerating = false
		SpeedBoost.CurrentFuel = ((SpeedBoost.CurrentFuel > SpeedBoost.MaxFuel and SpeedBoost.MaxFuel) or SpeedBoost.CurrentFuel)
	end)
end

function StopSkis()
	if FunctionSkis then
		FunctionSkis:disconnect()
	end
	LastUpdate = nil
	LastStateTime = 0
	State = "Stopped"
	if BodyVelocity and BodyVelocity.Parent then
		BodyVelocity.velocity = Vector3.new(0, 0, 0)
		BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	if SkiActive then
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
		StopSkis()
	else
		InvokeClient("PlayAnimation",Animations.IdleLegs)
		FunctionSkis = RunService.Heartbeat:connect(function()
			BodyVelocity.maxForce = Vector3.new(math.huge, 0, math.huge)
			UpdateSkiVelocity()
		end)
	end
	SkiActive = not SkiActive
end

function GetNormal(part, point)
	local Normal = NormalSurfaceModule(part, point)
	return ((part.CFrame-part.CFrame.p) * Normal)
end

function AngleFromFlat(Vec1)
	local Vec1 = Vec1.unit
	local FlatVec = (Vec1 * Vector3.new(1, 0, 1)).unit
	local Angle = math.acos(Vec1:Dot(FlatVec))
	if Angle ~= Angle then --If the angle is nan then assume flat surface
		return math.rad(90)
	end
	return (math.rad(90) - Angle)
end

function RayIgnoreCheck(Hit, Pos)
	return false
end

function RayIgnoreCamera(Hit, Pos)
	if Hit then
		if not Hit.CanCollide then
			return true
		end
	end
	return false
end

function RayCast2(StartPos, Vec, RayLength, IgnoreFunc, IgnoreList) -- @preconditions: Vec should be a unit Vector, and 0 < RayLength <= 1000
	IgnoreFunc = (IgnoreFunc or RayIgnoreCheck)
	IgnoreList = (IgnoreList or {Character})
	Vec = Vec.unit
	local Ray = Ray.new(StartPos, (Vec * RayLength))
	local HitObject, HitPos = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray, IgnoreList)
	if HitObject and HitPos then
		if IgnoreFunc(HitObject, HitPos) then
			table.insert(IgnoreList, HitObject)
			return RayCast2(StartPos, Vec, RayLength, IgnoreFunc, IgnoreList)
		end
	end
	return HitObject, HitPos
end

function GetGroundBelowCharacter()
	if Torso then
		local TorsoCFrame = Torso.CFrame
		local HitData = {}
		for z = -1, 1, 2 do
			for x = -1, 1, 2 do
				local RayPos = (TorsoCFrame.p + TorsoCFrame:vectorToWorldSpace(Vector3.new(((Torso.Size.X / 2) * x), 0, ((Torso.Size.Z / 2) * z))))
				local Hit, Pos = RayCast2(RayPos, Vector3.new(0, -1, 0), ((Torso.Size.Y / 2) + Torso.Size.Y + 6), RayIgnoreCamera)
				if Hit and Pos then
					table.insert(HitData, {["Pos"] = CFrame.new(Vector3.new(TorsoCFrame.p.X, (Pos.Y + 3), TorsoCFrame.p.Z)), ["Part"] = Hit})
				end
			end
		end
		table.sort(HitData, (function(a, b)
			return a["Pos"].p.Y > b["Pos"].p.Y
		end))
		if #HitData > 0 then
			return HitData[1]["Pos"], HitData[1]["Part"]
		end
		return TorsoCFrame, nil
	end
end

function StudsPerSToMetersPerS(studs)
	return (studs / 2)
end

function MetersPerSToStudsPerS(meters)
	return (meters * 2.5)
end

function UpdateSkiVelocity()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local Now = tick()
	if not LastUpdate then
		LastUpdate = Now
		return
	end
	local GroundHit, GroundPart = GetGroundBelowCharacter(Character)
	if GroundHit and GroundPart then
		local Normal = GetNormal(GroundPart, GroundHit.p)
		local Theta = AngleFromFlat(Normal) --[[ Angle of slope --]]
		local DeltaTime = (Now - LastUpdate)
		if BodyVelocity.velocity.magnitude < 22 then
			if State ~= "Poles" and (tick() - LastStateTime) > 0.5 then
				InvokeClient("StopAnimation", Animations.Tuck)
				InvokeClient("PlayAnimation", Animations.Swing)
				State = "Poles"
				LastStateTime = Now
			end
			local SkiOrientation = (Torso.CFrame.lookVector * Vector3.new(1,0,1)).unit
			if math.abs(math.acos(SkiOrientation:Dot(BodyVelocity.velocity.unit))) > (math.pi / 3) then
				BodyVelocity.velocity = (BodyVelocity.velocity * (1 - 0.55 * DeltaTime))
			end
			BodyVelocity.velocity = (BodyVelocity.velocity + (SkiOrientation * 19 * DeltaTime))
		else
			if State ~= "Tuck" and (tick() - LastStateTime) > 0.5 and (State ~= "Poles" or BodyVelocity.velocity.magnitude > 24) then
				InvokeClient("StopAnimation", Animations.Swing)
				InvokeClient("PlayAnimation", Animations.Tuck)
				State = "Tuck"
				LastStateTime = Now
			end
			
			local KineticSkiSnow = 0.05 --dynamic coeff of snow
			local CdAp = 0.65 --Drag coeff with frontal area
			local rho = 1.3413 --kg*m^3
			local Velocity = StudsPerSToMetersPerS(Torso.Velocity).magnitude
			local Mass = 65
			local Gravity = 9.81
			Gravity = ((SpeedBoost.Active and (Gravity * 2.5)) or Gravity)
			
			local DownhillVec = Vector3.new(0,1,0):Cross(Normal):Cross(Normal)
					
			local SkiOrientation = (Torso.CFrame.lookVector * Vector3.new(1, 0, 1)).unit
			local AngleBetweenLookAndHill = math.acos((DownhillVec * Vector3.new(1, 0, 1)).unit:Dot(SkiOrientation))
			if math.abs(AngleBetweenLookAndHill) > math.rad(90) then -- if we are pointed uphill, flip direction
				SkiOrientation = (SkiOrientation * -1)
				AngleBetweenLookAndHill = math.acos((DownhillVec * Vector3.new(1, 0, 1)).unit:Dot(SkiOrientation))
			end
			local Acceleration = (Gravity * math.sin(Theta) - KineticSkiSnow * Gravity * math.cos(Theta) - (CdAp * rho * (Velocity ^ 2)) / (2 * Mass))
			if math.abs(math.acos(SkiOrientation:Dot(BodyVelocity.velocity.unit))) > (math.pi / 3) then
				BodyVelocity.velocity = (BodyVelocity.velocity * (1 - 0.55 * DeltaTime))
			end
			BodyVelocity.velocity = (BodyVelocity.velocity + ((SkiOrientation + Vector3.new(0, 0.0001, 0)).unit * Acceleration) * DeltaTime) 
			
			LastUpdate = Now
			
		end

	end
end

function EquipSkis()
	if not CheckIfAlive() then
		return
	end
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.cframe = Torso.CFrame
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.Parent = Torso
	BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	BodyVelocity.velocity = Vector3.new(0, 0, 0)
	BodyVelocity.Parent = Torso
	local Ski = BasePart:Clone()
	Ski.Name = "Ski"
	Ski.Transparency = 0
	Ski.Size = Vector3.new(0.5, 1.15, 5.75)
	Ski.CanCollide = false
	Ski.Velocity = Vector3.new(0, 0, 0)
	Ski.RotVelocity = Vector3.new(0, 0, 0)
	RocketPart = BasePart:Clone()
	RocketPart.Name = "RocketPart"
	RocketPart.Transparency = 1
	RocketPart.Size = Vector3.new(0.5, 1, 0.85)
	RocketPart.CanCollide = false
	local Fire = Instance.new("Fire")
	Fire.Color = Color3.new((236 / 255), (139 / 255), (70 / 255))
	Fire.SecondaryColor = Color3.new((139 / 255), (80 / 255), (55 / 255))
	Fire.Heat = 10
	Fire.Size = 5
	Fire.Enabled = false
	Fire.Parent = RocketPart
	local RocketWeld = Instance.new("Weld")
	RocketWeld.Part0 = Ski
	RocketWeld.Part1 = RocketPart
	RocketWeld.C0 = CFrame.new(0, 0, 0)
	RocketWeld.C1 = CFrame.new(0, -3, 0) * CFrame.Angles(-(math.pi / 2), 0, 0)
	RocketWeld.Parent = RocketPart
	RocketPart.Parent = Ski
	local Mesh = Instance.new("SpecialMesh")
	Mesh.TextureId = "http://www.roblox.com/asset?id=189884063"
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.Offset = Vector3.new(0, 0.35, 0)
	Mesh.Scale = Vector3.new(1.25, 1.5, 0.75)
	Mesh.Parent = Ski
	local LeftLeg = Character:FindFirstChild("Left Leg")
	local RightLeg = Character:FindFirstChild("Right Leg")
	if LeftLeg then
		LeftSki = Ski:Clone()
		LeftSki.Name = "LeftSki"
		LeftSki.Mesh.MeshId = "http://www.roblox.com/asset?id=189884041"
		LeftWeld = Instance.new("Weld")
		LeftWeld.Part0 = LeftLeg
		LeftWeld.Part1 = LeftSki
		LeftWeld.C0 = CFrame.new(0, 0, 0)
		LeftWeld.C1 = CFrame.new(0, 0.55, 0.675)
		LeftWeld.Parent = LeftSki
		LeftSki.Parent = Tool
		InvokeClient("SetLocalTransparencyModifier", {Object = LeftLeg, Transparency = 0})
	end
	if RightLeg then
		RightSki = Ski:Clone()
		RightSki.Name = "RightSki"
		RightSki.Mesh.MeshId = "http://www.roblox.com/asset?id=189884023"
		RightWeld = Instance.new("Weld")
		RightWeld.Part0 = RightLeg
		RightWeld.Part1 = RightSki
		RightWeld.C0 = CFrame.new(0, 0, 0)
		RightWeld.C1 = CFrame.new(0, 0.55, 0.675)
		RightWeld.Parent = RightSki
		RightSki.Parent = Tool
		InvokeClient("SetLocalTransparencyModifier", {Object = RightLeg, Transparency = 0})
	end
	if SkiAlign then
		SkiAlign:disconnect()
	end
	SkiAlign = RunService.Heartbeat:connect(function()
		if (not (LeftLeg and LeftLeg.Parent and LeftSki and LeftSki.Parent and LeftWeld and LeftWeld.Parent) or not (RightLeg and RightLeg.Parent and RightSki and RightSki.Parent and RightWeld and RightWeld.Parent)) then
			SkiAlign:disconnect()
			return
		end
		local RayHit, RayPos = RayCast1(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size * 2), {Character})
		if RayHit then
			local Normal = NormalSurfaceModule(RayHit, RayPos)
			local StickCFrame = CFrame.new(RayPos, (RayPos + Normal)) * CFrame.Angles((math.pi / 2), 0, 0)
			BodyGyro.maxTorque = Vector3.new(math.huge, 0, math.huge)
			BodyGyro.cframe = StickCFrame * CFrame.Angles(math.pi, 0, 0)
		else
--			BodyGyro.maxTorque = Vector3.new(0, 0, 0)
		end
	end)
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	if PlayerGui then
		SpeedBoostGuiClone = SpeedBoostGui:Clone()
		FuelDisplay = SpeedBoostGuiClone.Frame.FuelDisplay
		FuelDisplay.Size = UDim2.new((1 / (SpeedBoost.MaxFuel / SpeedBoost.CurrentFuel)), 0, 1, 0)
		SpeedBoostGuiClone.Parent = PlayerGui
	end
	RegenerateFuel()
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("BasePart") and v ~= Handle) then
			v:Destroy()
		end
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	Handle.Transparency = 1
	Spawn(function()
		EquipSkis()
	end)
	ToolEquipped = true
end

function Unequipped()
	StopSkis()
	SkiActive = false
	for i, v in pairs({LeftSki, RightSki, BodyGyro, BodyVelocity, SpeedBoostGuiClone}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	for i, v in pairs({SkiAlign, FunctionSkis}) do
		if v then
			v:disconnect()
		end
	end
	if CheckIfAlive() then
		local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Torso.CFrame:components()
		Torso.CFrame = CFrame.new(X, Y, Z, R00, 0, R02, 0, R11, R12, R20, 0, R22)
	end
	Handle.Transparency = 0
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)