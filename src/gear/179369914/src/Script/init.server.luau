--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


			--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


			--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
							got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


			--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
							got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
Create.E = function(eventName)
	return {__eventname = eventName}
end


Remover = script:WaitForChild("Remover")

Tank = nil

Directions = {
	Forward = {
		Keys = {
			Key = "w",
			ByteKey = 17,
		},
		Direction = Vector3.new(0, 1, 0),
		State = false,
		LastDown = 0
	},
	Backward = {
		Keys = {
			Key = "s",
			ByteKey = 18,
		},
		Direction = Vector3.new(0, -1, 0),
		State = false,
		LastDown = 0
	},
	Left = {
		Keys = {
			Key = "a",
			ByteKey = 20,
		},
		Direction = Vector3.new(-1, 0, 0),
		State = false,
		LastDown = 0
	},
	Right = {
		Keys = {
			Key = "d",
			ByteKey = 19,
		},
		Direction = Vector3.new(1, 0, 0),
		State = false,
		LastDown = 0
	}
}

ShotDamage = 90

IsPlayingDrive = false
LastDrivingTime = 0

ReloadTime = 1
LastShotTime = 0

ToolCurrentlyEquipped = false

NoteGui = Create("ScreenGui"){
	Create("ImageLabel"){
		Name = "DriveNote",
		Position = UDim2.new(0.5, (-128 + 8), 1, -200),
		Size = UDim2.new(0, 128, 0, 64),
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=82229919",
		Visible = false,
	},
	Create("ImageLabel"){
		Name = "FireNote",
		Position = UDim2.new(0.5, 0-8, 1, -200),
		Size = UDim2.new(0, 128, 0, 64),
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=82071115",
		Visible = false,
	},
	Create("ImageLabel"){
		Name = "CreateNote",
		Position = UDim2.new(0.5, -64, 1, -200),
		Size = UDim2.new(0, 128, 0, 64),
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=82071122",
		Visible = true,
	},
}

CastInfo = {
	{
		Name = "FrontRight",
		Ahead = CFrame.new(1.2, 2.3, 0.3),
		AheadDesired = 1.24,
		Stand = CFrame.new(1.2, 1.1, 0),
		StandDesired = 0.94,
	},
	{
		Name = "FrontLeft",
		Ahead = CFrame.new(-1.2, 2.3, 0.3),
		AheadDesired = 1.24,
		Stand = CFrame.new(-1.2, 1.1, 0),
		StandDesired = 0.94,
	},
	{
		Name = "BackRight",
		Ahead = CFrame.new(1.2, -2.3, 0.3),
		AheadDesired = 1.24,
		Stand = CFrame.new(1.2, -1.6, 0),
		StandDesired = 0.94,
	}, 
	{
		Name = "BackLeft",
		Ahead = CFrame.new(-1.2, -2.3, 0.3),
		AheadDesired = 1.24,
		Stand = CFrame.new(-1.2, -1.6, 0),
		StandDesired = 0.94,
	},
}

for _, dat in pairs(CastInfo) do
	dat.LocalAxis = dat.Stand.p:Cross(Vector3.new(0, 0, 1)).unit
	dat.AheadLength = dat.Ahead.p.magnitude
	dat.StandLength = dat.Stand.p.magnitude
end

Tool.Grip = CFrame.new(-0.191770241, 0.0683477223, -0.607085466, -0.87758249, 0, -0.479425609, -0.420735568, 0.47942549, 0.770151138, 0.229848862, 0.87758261, -0.420735419)
Mesh.MeshId = "http://www.roblox.com/asset/?id=81616133"

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and CheckIfAlive() then
		if Mode == "MouseClick" and Value.Down then
			--Activated()
		elseif Mode == "MouseMove" and not CheckIfTankAlive() then
			local MousePosition = InvokeClient("MousePosition")
			if (Torso.Position - MousePosition).magnitude < 20 then
				InvokeClient("SetMouseIcon", "http://www.roblox.com/asset/?id=82230945")
			else
				InvokeClient("SetMouseIcon", "http://www.roblox.com/asset/?id=82071072")
			end
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
			if Down then
				local DirectionKeyPressed = false
				for i, v in pairs(Directions) do
					for ii, vv in pairs(v.Keys) do
						if ((ii == "Key" and vv == Key) or (ii == "ByteKey" and vv == ByteKey)) then
							Directions[i].State = true
							Directions[i].LastDown = 0
							DirectionKeyPressed = true
						end
					end
				end
				if ToolCurrentlyEquipped and CheckIfAlive() and CheckIfTankAlive() then
					if DirectionKeyPressed and not IsPlayingDrive then
						IsPlayingDrive = true
						StartSound:Play()
						DriveSound:Play()
						IdleSound:Stop()
					else
					end
				end
			else
				for i, v in pairs(Directions) do
					for ii, vv in pairs(v.Keys) do
						if ((ii == "Key" and vv == Key) or (ii == "ByteKey" and vv == ByteKey)) then
							Directions[i].State = false
							Directions[i].LastDown = tick()
						end
					end
				end
				if Tank and IsPlayingDrive then
					local IsDriving = false
					for i, v in pairs(Directions) do
						if v.State then
							IsDriving = true
						end
					end
					if not IsDriving then
						IsPlayingDrive = false
						LastDrivingTime = tick()
						DriveSound:Stop()
						IdleSound:Play()
					end
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

function TopVector(cframe)
	local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:components()
	return Vector3.new(R01, R11, R21)
end

function BackVector(cframe)
	local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:components()
	return Vector3.new(R02, R12, R22)
end

function RightVector(cframe)
	local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:components()
	return Vector3.new(R00, R10, R20)
end

function CFrameFromTopBack(at, top, back)
	local Right = top:Cross(back)
	return CFrame.new(
		at.x, at.y, at.z,
		Right.x, top.x, back.x,
		Right.y, top.y, back.y,
		Right.z, top.z, back.z
	)
end

function CreateTank()
	local Body = Create("Part"){
		Name = "Torso",
		FormFactor = "Custom",
		Size = Vector3.new(2.8, 4.25, 1.75),
		Create("SpecialMesh"){
			Scale = Vector3.new(2.5, 2, 2.5),
			MeshId = "http://www.roblox.com/asset/?id=81616058",
			TextureId = "http://www.roblox.com/asset/?id=177480340",
		},
		Create("BodyGyro"){
			maxTorque = Vector3.new(math.huge, math.huge, math.huge),
			cframe = CFrame.new(0, 0, 0),
		},
		Create("Sound"){
			Name = "FireSound",
			SoundId = "http://www.roblox.com/asset/?id=81116734",
		},
		Create("Sound"){
			Name = "ExplodeSound",
			SoundId = "http://www.roblox.com/asset/?id=81116747",
		},
		Create("Sound"){
			Name = "IdleSound",
			SoundId = "http://www.roblox.com/asset/?id=82229695",
			Looped = true,
			Pitch = 0.6,
			Volume = 0.2,
		},
		Create("Sound"){
			Name = "StartSound",
			SoundId = "http://www.roblox.com/asset/?id=82229695",
			Pitch = 0.8,
			Volume = 1.0,
		},
		Create("Sound"){
			Name = "DriveSound",
			SoundId = "http://www.roblox.com/asset/?id=82229584",
			Pitch = 1.5,
			Volume = 1.0,
			Looped = true,
		},
	}
	
	BodyGyro = Body:FindFirstChild("BodyGyro")
	FireSound = Body:FindFirstChild("FireSound")
	ExplodeSound = Body:FindFirstChild("ExplodeSound")
	IdleSound = Body:FindFirstChild("IdleSound")
	StartSound = Body:FindFirstChild("StartSound")
	DriveSound = Body:FindFirstChild("DriveSound")
	
	local Turret = Create("Part"){
		Name = "Head",
		FormFactor = "Custom",
		Size = Vector3.new(2.4, 1.6, 0.7),
		CanCollide = false,
		Create("SpecialMesh"){
			Scale = Vector3.new(2.5, 2, 3.5),
			MeshId = "http://www.roblox.com/asset/?id=81616087",
			TextureId = "http://www.roblox.com/asset/?id=177480340",
		},
	}
	
	local Cannon = Create("Part"){
		Name = "Cannon",
		FormFactor = "Custom",
		Size = Vector3.new(0.4, 0.4, 0.4),
		Create("SpecialMesh"){
			Scale = Vector3.new(5, 2, 5),
			MeshId = "http://www.roblox.com/asset/?id=81616091",
			TextureId = "http://www.roblox.com/asset/?id=177480340",
		},
	}
	
	local Humanoid = Create("Humanoid"){
		PlatformStand = true,
	}
	
	local TurretAttach = Create("Weld"){
		Name = "Neck",
		Parent = Body,
		Part0 = Body,
		Part1 = Turret,
		C0 = CFrame.new(0, 0, 0.5),
		C1 = CFrame.new(0, 0, -0.4),
	}
	
	local CannonAttach = Create("Weld"){
		Name = "CannonAttach",
		Parent = Turret,
		Part0 = Turret,
		Part1 = Cannon,
		C0 = CFrame.new(0, 0.875, -0.2),
		C1 = CFrame.new(0, 0.1, 0),
	}
	
	local Model = Create("Model"){
		Name = "Tank",
	}
	
	Body.Parent = Model
	Turret.Parent = Model
	Cannon.Parent = Model
	Humanoid.Parent = Model
	Humanoid.MaxHealth = 500
	Humanoid.Health = Humanoid.MaxHealth

	return {
		Model = Model,
		Body = Body,
		BodyGyro = BodyGyro,
		Turret = Turret,
		Cannon = Cannon,
		TurretAttach = TurretAttach,
		CannonAttach = CannonAttach,
		Humanoid = Humanoid,
	}
	
end

function DoCastDown(Offset, Dir)
	Dir = (Dir or Vector3.new(0, -1, 0))
	local CastFrom = ((Tank.Body.CFrame * Offset).p - Dir * 2.5)
	
	local ray = Ray.new(CastFrom, Dir * 999)
	local Part, at = game:GetService("Workspace"):FindPartOnRay(ray, Tank.Model)
	if Part and (not Part.CanCollide or Part.Transparency == 1) then
		local Parts = {Tank.Body, Tank.Turret, Tank.Cannon}
		while Part and (not Part.CanCollide or Part.Transparency == 1) do
			Parts[#Parts + 1] = Part
			Part, at = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, Parts)
		end
	end
	
	return Part, at, ((CastFrom - at).magnitude - 2.5)
end

function Clamp(n, min, max)
	return math.max(math.min(max, n), min)
end

function Sign(n)
	return (((n >= 0) and 1) or -1)
end

function CheckIfTankAlive()
	return (Tank and Tank.Model and Tank.Model.Parent and Tank.Body and Tank.Body.Parent and Tank.Turret and Tank.Turret.Parent and Tank.Cannon and Tank.Cannon.Parent and Tank.Humanoid and Tank.Humanoid.Parent and Tank.Humanoid.Health > 0)
end

function EnableSteering()
	local LastTime = tick()
	local LastTimeInAir = 0
	local LastVelocity = 0
	local DesiredHeading = Vector3.new()
	local IsOnGround = false
	local TurnSpeed = 1.8 -- rad / sec
	local MoveSpeed = 11.0 -- stud / sec

	local CurrentlyEquipped = true
	local Connected = true

	for i, v in pairs({TankControl, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	
	TankControl = RunService.Heartbeat:connect(function()

		if not CurrentlyEquipped or not CheckIfAlive() or not CheckIfTankAlive() then
			Connected = false
			for i, v in pairs({TankControl, ToolUnequipped}) do
				if v then
					v:disconnect()
				end
			end
		end

		if Connected then
			local t = tick()
			local dt = (t - LastTime)
			LastTime = t
			
			local MousePosition = InvokeClient("MousePosition")
			
			if (Tank.Turret.Position - MousePosition).magnitude < 140 then
				InvokeClient("SetMouseIcon", "http://www.roblox.com/asset/?id=82071097")
			else
				InvokeClient("SetMouseIcon", "http://www.roblox.com/asset/?id=82071109")
			end
			
			local _, _, DistOffGround = DoCastDown(CFrame.new())
			DistOffGround = (DistOffGround - 0.94)
			if DistOffGround > 3 then
				if IsOnGround then
					IsOnGround = false
					BodyGyro.maxTorque = Vector3.new(0, 0, 0)
				end
				LastTimeInAir = t
				
				DriveSound.Pitch = 1.8
				
			elseif (t - LastTimeInAir) > 2 then
				
				DriveSound.Pitch = (1.2 + 0.6 * LastVelocity)
				
				if not IsOnGround then
					IsOnGround = true
					BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
				end
				
				local BodyLook = TopVector(Tank.Body.CFrame)
				DesiredHeading = Vector3.new(BodyLook.x, 0, BodyLook.z).unit
				
				local TankSavedPositionHack = Tank.Body.CFrame
				local TurretToHitVec = (MousePosition - Tank.Turret.Position)
				local DistToHit = TurretToHitVec.magnitude
				local RotAxis = TurretToHitVec:Cross(TurretToHitVec - Vector3.new(0, TurretToHitVec.y, 0)).unit
				if TurretToHitVec.y > 0 then
					RotAxis = -RotAxis
				end
				local TurretToHit = (CFrame.fromAxisAngle(RotAxis, math.min(1, DistToHit / 140) * math.pi / 3.5) * TurretToHitVec.unit)
				local SwivelPlaneNormal = Tank.Body.CFrame.lookVector
				local TurretDir = (TurretToHit - SwivelPlaneNormal * TurretToHit:Dot(SwivelPlaneNormal)).unit
				local DesiredTurretCF = CFrameFromTopBack(Tank.Turret.Position, TurretDir, -SwivelPlaneNormal) * CFrame.Angles(0, 0.01, 0)
				Tank.Body.CFrame = TankSavedPositionHack
				Tank.TurretAttach.C1 = DesiredTurretCF:inverse() * Tank.Body.CFrame * CFrame.new(0, 0, 0.5)
				
				local DesiredCannonCF = CFrameFromTopBack((Tank.Turret.CFrame * CFrame.new(0, 1.125, -0.2)).p, TurretToHit, TurretToHit:Cross(RightVector(DesiredTurretCF)))
				--[[if (t - LastShotTime) < 1 then
					local Elapsed = (t - LastShotTime)
					if Elapsed < 0.1 then
						DesiredCannonCF = DesiredCannonCF * CFrame.new(0, -((Elapsed / 0.1) * 0.8), 0)
					else
						DesiredCannonCF = DesiredCannonCF * CFrame.new(0, -((1 - ((Elapsed - 0.1) / 0.9)) * 0.8),0)
					end
				end]]
				Tank.CannonAttach.C1 = DesiredCannonCF:inverse() * Tank.Turret.CFrame * CFrame.new(0, 1.125, -0.2)
				Tank.Body.CFrame = TankSavedPositionHack
				
				local CoordinateFrame = InvokeClient("GetCamera", {Property = "CoordinateFrame"})
				local CamLook = CoordinateFrame.lookVector
				local CamDir = Vector3.new(CamLook.x, 0, CamLook.z).unit
				local CamPerpDir = CamDir:Cross(Vector3.new(0, 1, 0))
				
				local MoveDirs = Vector3.new()
				local function Decay(v)
					return (1 - math.sqrt(1 - v))
				end
				
				for i, v in pairs(Directions) do
					if Directions[i].State then
						MoveDirs = (MoveDirs + v.Direction)
					end
					local Delay = 0.8
					if v.Direction.X ~= 0 then
						Delay = 0.4
					end
					if (t - Directions[i].LastDown) < Delay then
						MoveDirs = (MoveDirs + v.Direction * Decay(Delay - (t - Directions[i].LastDown)))
					end
				end
				local KeyHeading = (CamDir * MoveDirs.y + CamPerpDir * MoveDirs.x)
				
				local SpeedFactor = KeyHeading:Dot(DesiredHeading)
				local TurnFactor
				if KeyHeading.magnitude > 0 then
					TurnFactor = -KeyHeading.unit:Cross(DesiredHeading).y
				else
					TurnFactor = 0
				end
				
				LastVelocity = math.abs(SpeedFactor)
				
				local TankLevelCF = CFrameFromTopBack(Tank.Body.Position, DesiredHeading, Vector3.new(0, 1, 0))
				if TurnFactor ~= 0 or SpeedFactor ~= 0 then
					local TankCFrame = TankLevelCF * CFrame.Angles(0, 0, (TurnFactor * TurnSpeed * dt)) * CFrame.new(0, (SpeedFactor * MoveSpeed * dt), 0)
					local PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = TankCFrame:components()
					if tostring(PX) ~= "-1.#IND" and tostring(PY) ~= "-1.#IND" and tostring(PZ) ~= "-1.#IND" then
						Tank.Body.CFrame = CFrame.new(PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
					end
				else
					local PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = TankLevelCF:components()
					if tostring(PX) ~= "-1.#IND" and tostring(PY) ~= "-1.#IND" and tostring(PZ) ~= "-1.#IND" then
						Tank.Body.CFrame = CFrame.new(PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
					end
				end
				
				local AvrDisp = 0
				local NumDisps = 0
				for _, Cast in pairs(CastInfo) do
					local _, _, aheadH = DoCastDown(Cast.Ahead)
					local _, _, standH = DoCastDown(Cast.Stand)
					Cast.AheadH = (aheadH - Cast.AheadDesired)
					Cast.StandH = (standH - Cast.StandDesired)
					if Cast.AheadH < 3 then
						AvrDisp = (AvrDisp + Cast.AheadH)
						NumDisps = (NumDisps + 1)
					end
				end
				AvrDisp = ((NumDisps > 0) and (AvrDisp / NumDisps) or 0)
				local tankRot = Tank.Body.CFrame - Tank.Body.CFrame.p
				local RotAmountX = 0
				local RotAmountY = 0
				local NumRots = 0
				for _, Cast in pairs(CastInfo) do
					local Which = nil
					if Cast.AheadH > 3 and Cast.StandH > 3 then
					elseif Cast.AheadH > 3 then
						Which = true
					elseif Cast.StandH > 3 then
						Which = false
					else
						Which = (Cast.StandH < Cast.AheadH)
					end
					if Which ~= nil then
						local h, distOut
						if Which then
							h = Cast.StandH
							distOut = Cast.StandLength
						else
							h = Cast.AheadH
							distOut = Cast.AheadLength
						end
						h = (h - AvrDisp)
						local theta = -math.atan(h / distOut)
						RotAmountX = (RotAmountX + theta * Cast.LocalAxis.x)
						RotAmountY = (RotAmountY + theta * Cast.LocalAxis.y)
						NumRots = (NumRots + 1)
					end
				end
				
				Tank.BodyGyro.cframe = CFrame.new(0, -AvrDisp, 0) * Tank.Body.CFrame * CFrame.Angles((RotAmountX / NumRots * 2), 0, 0) * CFrame.Angles(0, (RotAmountY / NumRots * 2), 0)
				
				local _, _, RightFudge = DoCastDown(CFrame.new(1.2, 0, 0))
				local _, _, LeftFudge = DoCastDown(CFrame.new(-1.2, 0, 0))
				RightFudge = ((RightFudge - 0.94) / math.cos(RotAmountX / NumRots * 2))
				LeftFudge = ((LeftFudge - 0.94) / math.cos(RotAmountX / NumRots * 2))
				if RightFudge < 1 and LeftFudge < 1 then
					Tank.BodyGyro.cframe = CFrame.new(0, -0.5 * (RightFudge + LeftFudge), 0) * Tank.Body.CFrame
				elseif RightFudge < 1 then
					Tank.BodyGyro.cframe = CFrame.new(0, -RightFudge, 0) * Tank.Body.CFrame
				elseif LeftFudge < 1 then
					Tank.BodyGyro.cframe = CFrame.new(0, -LeftFudge, 0) * Tank.Body.CFrame
				end
				
				local DesiredLen = 0.6
				local CastDir = TopVector(Tank.Body.CFrame)
				local Parta, ata, dista = DoCastDown(CFrame.new(1.2, 1.5, 0.5), CastDir)
				local Partb, atb, distb = DoCastDown(CFrame.new(-1.2, 1.5, 0.5), CastDir)
				local smallerGap = (math.min(dista, distb) - DesiredLen)
				if smallerGap < 0 then
					Tank.Body.CFrame = Tank.Body.CFrame * CFrame.new(0, smallerGap, 0)
				end
				
			else
				--falling
			end
		end
	end)
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

function Fire(Origin, TargetPosition, Direction)
	local Projectile = Instance.new("Part")
	Projectile.Name = "Projectile"
	Projectile.Material = Enum.Material.Plastic
	Projectile.Shape = Enum.PartType.Block
	Projectile.TopSurface = Enum.SurfaceType.Smooth
	Projectile.BottomSurface = Enum.SurfaceType.Smooth
	Projectile.FormFactor = Enum.FormFactor.Custom
	Projectile.CFrame = CFrame.new(Origin)
	Projectile.Shape = Enum.PartType.Ball
	Projectile.Size = Vector3.new(1, 1, 1)
	local ProjectileMesh = Create("SpecialMesh"){
		MeshId = "http://www.roblox.com/asset/?id=1158007",
		TextureId = "http://www.roblox.com/asset/?id=1158033",
		Scale = Vector3.new(0.25, 0.25, 0.25),
		Parent = Projectile,
	}
	local BodyPosition = Create("BodyPosition"){
		maxForce = Vector3.new(10000, 10000, 10000),
		P = 30000,
		Parent = Projectile,
	}
	local ExplodeSound = Create("Sound"){
		SoundId = "http://www.roblox.com/asset/?id=81116747",
		Parent = Projectile,
	}	
	local TotalDist = (TargetPosition - Origin).magnitude
	local Speed = 80 --studs/sec
	local FlightTime = (TotalDist / Speed)
	local Exploded = false
	local function Explode()
		if Exploded then
			return
		end
		Exploded = true
		Projectile.Transparency = 1
		Projectile.Anchored = true
		local Explosion = Create("Explosion"){
			BlastPressure = 0,
			BlastRadius = 12,
			Position = Projectile.Position,
		}
		local HitHumanoids = {}
		Explosion.Hit:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local character = Hit.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and not HitHumanoids[humanoid] and humanoid ~= Tank.Humanoid and humanoid ~= Humanoid then
				HitHumanoids[humanoid] = true
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(ShotDamage)
			end
		end)
		Explosion.Parent = game:GetService("Workspace")
		ExplodeSound:Play()
		Debris:AddItem(Projectile, 2)
		Debris:AddItem(Explosion, 2)
	end

	Projectile.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent then
			return
		end
		local character = Hit.Parent
		if character == Tank.Model then
			return
		end
		Explode()
	end)
	
	Debris:AddItem(Projectile, 5)
	Projectile.Parent = game:GetService("Workspace")	
	
	local AheadVector = (Direction.unit * TotalDist)
	local FlightVector = (TargetPosition - Origin)
	
	--keep flying
	Projectile.Anchored = false
	for t = 0, FlightTime, 0.033 do
		if Exploded then
			break
		end
		local f = (t / FlightTime)
		--
		BodyPosition.position = (Origin + ((AheadVector * f) * ( 1 - f) + (FlightVector * f) * f))
		--
		wait(0.03)
	end
	BodyPosition.position = TargetPosition
	Spawn(function()
		while Projectile and Projectile.Parent and (Projectile.Position - TargetPosition).magnitude > 1 do
			wait()
		end
		Explode()
	end)

end

function Activated()
	if not CheckIfAlive() then
		return
	end
	local MousePosition = InvokeClient("MousePosition")
	if Tank and Tank.Model and Tank.Model.Parent then
		if (tick() - LastShotTime) > ReloadTime then
			local Origin = (Tank.Cannon.CFrame * CFrame.new(0, 3, 0)).p
			local Direction = TopVector(Tank.Cannon.CFrame)
			if (MousePosition - Origin).magnitude < 140 then
				LastShotTime = tick()
				FireSound:Play()
				Fire(Origin, MousePosition, Direction)
			end
		end
	elseif (Torso.Position - MousePosition).magnitude < 20 then
		Tank = CreateTank()
		
		local ScriptName = (Player.Name .. Remover.Name)
		local RemoverClone = game:GetService("Workspace"):FindFirstChild(ScriptName)
		if RemoverClone then
			RemoverClone:Destroy()
		end
		RemoverClone = Remover:Clone()
		RemoverClone.Name = ScriptName
		local CreatorValue = Instance.new("ObjectValue")
		CreatorValue.Name = "Creator"
		CreatorValue.Value = Player
		CreatorValue.Parent = RemoverClone
		local ToolValue = Instance.new("ObjectValue")
		ToolValue.Name = "Tool"
		ToolValue.Value = Tool
		ToolValue.Parent = RemoverClone
		local ModelValue = Instance.new("ObjectValue")
		ModelValue.Name = "Model"
		ModelValue.Value = Tank.Model
		ModelValue.Parent = RemoverClone
		RemoverClone.Disabled = false
		RemoverClone.Parent = game:GetService("Workspace")
		
		Tank.Model.Parent = game:GetService("Workspace")
		
		local TankCFrame = CFrameFromTopBack((MousePosition + Vector3.new(0, 1.8, 0)), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0))
		Tank.Body.CFrame = TankCFrame
		Tank.BodyGyro.cframe = TankCFrame 
			
		InvokeClient("SetCamera", {Property = "CameraSubject", Value = Tank.Model})
		InvokeClient("SetCamera", {Property = "CameraType", Value = Enum.CameraType.Track})
		
		IdleSound:Play()
		
		Humanoid.WalkSpeed = 0

		if NoteGuiClone and NoteGuiClone.Parent then
			NoteGuiClone.CreateNote.Visible = false
			NoteGuiClone.DriveNote.Visible = true
			NoteGuiClone.FireNote.Visible = true
		end
		
		Tank.Humanoid.Died:connect(function()
			game.Debris:AddItem(Tank.Model, 2)
			Tank.Model:BreakJoints()
			Tank = nil
			InvokeClient("SetCamera", {Property = "CameraSubject", Value = Character})
			InvokeClient("SetCamera", {Property = "CameraType", Value = Enum.CameraType.Custom})
			if NoteGuiClone and NoteGuiClone.Parent then
				NoteGuiClone.CreateNote.Visible = true
				NoteGuiClone.DriveNote.Visible = false
				NoteGuiClone.FireNote.Visible = false
			end
			InvokeClient("DisableJump", false)
			Humanoid.WalkSpeed = 16
		end)
		
		Spawn(function()
			EnableSteering()
		end)
				
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	
	ToolCurrentlyEquipped = true
	
	if PlayerGui then
		NoteGuiClone = NoteGui:Clone()
		NoteGuiClone.CreateNote.Visible = true
		NoteGuiClone.DriveNote.Visible = false
		NoteGuiClone.FireNote.Visible = false
		NoteGuiClone.Parent = PlayerGui
	end
		
end

function Unequipped()
	if NoteGuiClone and NoteGuiClone.Parent then
		NoteGuiClone:Destroy()
	end
	if Tank and Tank.Model and Tank.Model.Parent then
		Tank.Model:Destroy()
	end
	for i, v in pairs({TankControl, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	IsPlayingDrive = false
	LastDrivingTime = 0
	InvokeClient("SetCamera", {Property = "CameraType", Value = Enum.CameraType.Custom})
	InvokeClient("SetCamera", {Property = "CameraSubject", Value = Character})
	InvokeClient("PreventJump", false)
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	ToolCurrentlyEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)