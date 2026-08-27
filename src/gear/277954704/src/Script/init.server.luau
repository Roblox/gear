--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
InsertService = game:GetService("InsertService")

BaseUrl = "http://www.roblox.com/asset/?id="

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


ProjectileModel = InsertService:LoadAsset(273756798)
BaseProjectile = ProjectileModel:GetChildren()[1]:Clone()
Debris:AddItem(ProjectileModel, 0.5)

Functions = require(script:WaitForChild("Functions"))

NoteGui = script:WaitForChild("NoteGui")
ProjectileScript = script:WaitForChild("ProjectileScript")
Remover = script:WaitForChild("Remover")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Tank = nil

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

Directions = {
	Forward = {
		Keys = {Key = "w", ByteKey = 17},
		Direction = Vector3.new(0, 1, 0),
		State = false,
		LastDown = 0
	},
	Backward = {
		Keys = {Key = "s", ByteKey = 18},
		Direction = Vector3.new(0, -1, 0),
		State = false,
		LastDown = 0
	},
	Left = {
		Keys = {Key = "a", ByteKey = 20},
		Direction = Vector3.new(-1, 0, 0),
		State = false,
		LastDown = 0
	},
	Right = {
		Keys = {Key = "d", ByteKey = 19},
		Direction = Vector3.new(1, 0, 0),
		State = false,
		LastDown = 0
	}
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

Gravity = 196.20

ReloadTime = 1
LastShotTime = 0
FireFrame = 0

Firing = false
IsPlayingDrive = false
ToolEquipped = false

for i, v in pairs(CastInfo) do
	v.LocalAxis = v.Stand.p:Cross(Vector3.new(0, 0, 1)).unit
	v.AheadLength = v.Ahead.p.magnitude
	v.StandLength = v.Stand.p.magnitude
end

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool
})

Handle.Transparency = 0
Tool.Enabled = true

function CheckIfTankAlive()
	return (Tank and Tank.Model and Tank.Model.Parent and Tank.Body and Tank.Body.Parent and Tank.Turret and Tank.Turret.Parent and Tank.Humanoid and Tank.Humanoid.Parent and Tank.Humanoid.Health > 0)
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
			if not MousePosition then
				return
			end
			
			Spawn(function()
				if (Tank.Turret.Position - MousePosition).magnitude < 140 then
					InvokeClient("SetMouseIcon", (BaseUrl .. "82071097"))
				else
					InvokeClient("SetMouseIcon", (BaseUrl .. "82071109"))
				end
			end)
			
			local _, _, DistOffGround = Functions.DoCastDown(Tank, CFrame.new())
			DistOffGround = (DistOffGround - 0.94)
			if DistOffGround > 3 then
				if IsOnGround then
					IsOnGround = false
					Tank.BodyGyro.maxTorque = Vector3.new(0, 0, 0)
				end
				LastTimeInAir = t
				
				Tank.Sounds.Drive.Pitch = 1.8
				
			elseif (t - LastTimeInAir) > 2 then
				
				Tank.Sounds.Drive.Pitch = (1.2 + 0.6 * LastVelocity)
				
				local CoordinateFrame = InvokeClient("GetCamera", {Property = "CoordinateFrame"})
				if not CoordinateFrame then
					return
				end
				
				if not IsOnGround then
					IsOnGround = true
					Tank.BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
				end
				
				local BodyLook = Functions.GetVector(Tank.Body.CFrame, Enum.NormalId.Top)
				DesiredHeading = Vector3.new(BodyLook.x, 0, BodyLook.z).unit
				
				local TankSavedPositionHack = Tank.Body.CFrame
				local TurretToHitVec = (MousePosition - Tank.Turret.Position)
				local DistToHit = TurretToHitVec.magnitude
				local RotAxis = TurretToHitVec:Cross(TurretToHitVec - Vector3.new(0, TurretToHitVec.y, 0)).unit
				if TurretToHitVec.y > 0 then
					RotAxis = -RotAxis
				end
				local TurretToHit = (CFrame.fromAxisAngle(RotAxis, (math.min(1, DistToHit / 140) * math.pi / 3.5)) * TurretToHitVec.unit)
				local SwivelPlaneNormal = Tank.Body.CFrame.lookVector
				local TurretDir = (TurretToHit - SwivelPlaneNormal * TurretToHit:Dot(SwivelPlaneNormal)).unit
				local DesiredTurretCF = Functions.CFrameFromTopBack(Tank.Turret.Position, TurretDir, -SwivelPlaneNormal) * CFrame.Angles(0, 0.01, 0)
				Tank.Body.CFrame = TankSavedPositionHack
				Tank.TurretAttach.C1 = DesiredTurretCF:inverse() * Tank.Body.CFrame * CFrame.new(0, 0.65, -0.25)
								
				Tank.Body.CFrame = TankSavedPositionHack
				
				local CamLook = CoordinateFrame.lookVector
				local CamDir = Vector3.new(CamLook.x, 0, CamLook.z).unit
				local CamPerpDir = CamDir:Cross(Vector3.new(0, 1, 0))
				
				local MoveDirs = Vector3.new()
				
				for i, v in pairs(Directions) do
					if Directions[i].State then
						MoveDirs = (MoveDirs + v.Direction)
					end
					local Delay = ((v.Direction.X ~= 0 and 0.4) or 0.8)
					if (t - Directions[i].LastDown) < Delay then
						MoveDirs = (MoveDirs + v.Direction * Functions.Decay(Delay - (t - Directions[i].LastDown)))
					end
				end
				local KeyHeading = (CamDir * MoveDirs.y + CamPerpDir * MoveDirs.x)
				
				local SpeedFactor = KeyHeading:Dot(DesiredHeading)
				local TurnFactor = ((KeyHeading.magnitude > 0 and -KeyHeading.unit:Cross(DesiredHeading).y) or 0)
				
				LastVelocity = math.abs(SpeedFactor)
				
				local TankLevelCF = Functions.CFrameFromTopBack(Tank.Body.Position, DesiredHeading, Vector3.new(0, 1, 0))
				local TankCFrame = TankLevelCF * CFrame.Angles(0, 0, (TurnFactor * TurnSpeed * dt)) * CFrame.new(0, (SpeedFactor * MoveSpeed * dt), 0)
				local TankMoving = (((TurnFactor ~= 0 or SpeedFactor ~= 0) and true) or false)
				local PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = ((TankMoving and TankCFrame) or TankLevelCF):components()
				if tostring(PX) ~= "-1.#IND" and tostring(PY) ~= "-1.#IND" and tostring(PZ) ~= "-1.#IND" then
					Tank.Body.CFrame = CFrame.new(PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
					Tank.BodyGyro.cframe = Tank.Body.CFrame
				end
				
				local AvrDisp = 0
				local NumDisps = 0
				for _, Cast in pairs(CastInfo) do
					local _, _, aheadH = Functions.DoCastDown(Tank, Cast.Ahead)
					local _, _, standH = Functions.DoCastDown(Tank, Cast.Stand)
					Cast.AheadH = (aheadH - Cast.AheadDesired)
					Cast.StandH = (standH - Cast.StandDesired)
					if Cast.AheadH < 3 then
						AvrDisp = (AvrDisp + Cast.AheadH)
						NumDisps = (NumDisps + 1)
					end
				end
				AvrDisp = ((NumDisps > 0) and (AvrDisp / NumDisps) or 0)
				local tankRot = Tank.Body.CFrame - Tank.Body.CFrame.p
				local RotAmount = {X = 0, Y = 0}
				local NumRots = 0
				for _, Cast in pairs(CastInfo) do
					local Which = ((Cast.AheadH > 3 and Cast.StandH > 3 and nil) or (Cast.AheadH > 3 and true) or (Cast.StandH > 3 and false) or (Cast.StandH < Cast.AheadH))
					if Which ~= nil then
						local h = ((Which and Cast.StandH) or Cast.AheadH)
						local distOut = ((Which and Cast.StandLength) or Cast.AheadLength)
						h = (h - AvrDisp)
						local theta = -math.atan(h / distOut)
						RotAmount.X = (RotAmount.X + theta * Cast.LocalAxis.x)
						RotAmount.Y = (RotAmount.Y + theta * Cast.LocalAxis.y)
						NumRots = (NumRots + 1)
					end
				end
				
				Tank.BodyGyro.cframe = CFrame.new(0, -AvrDisp, 0) * Tank.Body.CFrame * CFrame.Angles((RotAmount.X / NumRots * 2), 0, 0) * CFrame.Angles(0, (RotAmount.Y / NumRots * 2), 0)
				
				local _, _, RightFudge = Functions.DoCastDown(Tank, CFrame.new(1.2, 0, 0))
				local _, _, LeftFudge = Functions.DoCastDown(Tank, CFrame.new(-1.2, 0, 0))
				RightFudge = ((RightFudge - 0.94) / math.cos(RotAmount.X / NumRots * 2))
				LeftFudge = ((LeftFudge - 0.94) / math.cos(RotAmount.X / NumRots * 2))
				if RightFudge < 1 and LeftFudge < 1 then
					Tank.BodyGyro.cframe = (CFrame.new(0, -0.5 * (RightFudge + LeftFudge), 0) * Tank.Body.CFrame)
				elseif RightFudge < 1 then
					Tank.BodyGyro.cframe = (CFrame.new(0, -RightFudge, 0) * Tank.Body.CFrame)
				elseif LeftFudge < 1 then
					Tank.BodyGyro.cframe = (CFrame.new(0, -LeftFudge, 0) * Tank.Body.CFrame)
				end
				
				local DesiredLen = 0.6
				local CastDir = Functions.GetVector(Tank.Body.CFrame, Enum.NormalId.Top)
				local Parta, ata, dista = Functions.DoCastDown(Tank, CFrame.new(1.2, 1.5, 0.5), CastDir)
				local Partb, atb, distb = Functions.DoCastDown(Tank, CFrame.new(-1.2, 1.5, 0.5), CastDir)
				local SmallerGap = (math.min(dista, distb) - DesiredLen)
				if SmallerGap < 0 then
					Tank.Body.CFrame = Tank.Body.CFrame * CFrame.new(0, SmallerGap, 0)
				end
				
				local DesiredAngle = (999999999 * (-SpeedFactor / math.abs(SpeedFactor)))
				local MaxVelocity = (MoveSpeed / 250)
				for i, v in pairs(Tank.Wheels) do
					if TankMoving then
						v.Motor.DesiredAngle = DesiredAngle
						v.Motor.MaxVelocity = MaxVelocity
					else
						v.Motor.MaxVelocity = 0
					end
				end
			else
				--falling
			end
		end
	end)
end

function Fire(Origin, TargetPosition, Direction)
	local Projectile = BaseProjectile:Clone()
	Projectile.Size = (BaseProjectile.Size * 0.5)
	Projectile.Fire.Enabled = true
	Projectile.Name = "Projectile"
	local ExplodeSound = Create("Sound"){
		Name = "Explode",
		SoundId = (BaseUrl .. "81116747"),
		Pitch = 1,
		Volume = 0.5,
		Looped = false,
		Parent = Projectile,
	}
	local Data = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Origin", Class = "Vector3Value", Value = Origin},
		{Name = "TargetPosition", Class = "Vector3Value", Value = TargetPosition},
		{Name = "Direction", Class = "Vector3Value", Value = Direction},
		{Name = "Speed", Class = "NumberValue", Value = 80},
		{Name = "Damage", Class = "NumberValue", Value = 25},
	}
	for i, v in pairs(Data) do
		local Object = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Projectile
		}
	end
	local Mass = (Projectile:GetMass() * Gravity)
	local Force = 50
	local Direction = CFrame.new(Origin, (Origin + Direction * 2))
	local Velocity = (Direction.lookVector * Force)
	local BodyVelocity = Create("BodyVelocity"){
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Projectile
	}
	local FaceDirection = (Direction * CFrame.Angles(0, (math.pi / 2), 0))
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		cframe = FaceDirection,
		Parent = Projectile,
	}
	Projectile.Velocity = Velocity
	Projectile.CFrame = FaceDirection
	local ProjectileScriptClone = ProjectileScript:Clone()
	ProjectileScriptClone.Disabled = false
	ProjectileScriptClone.Parent = Projectile
	Debris:AddItem(Projectile, 5)
	Projectile.Parent = game:GetService("Workspace")
	
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		return
	end
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if CheckIfTankAlive() then
		if (tick() - LastShotTime) > ReloadTime then
			local Origin = (Tank.Turret.CFrame * CFrame.new(0, 3, 0)).p
			local Direction = Functions.GetVector(Tank.Turret.CFrame, Enum.NormalId.Top)
			if (MousePosition - Origin).magnitude < 140 then
				LastShotTime = tick()
				Tank.Sounds.Fire:Play()
				Firing = true
				Fire(Origin, MousePosition, Direction)
			end
		end
	elseif (Torso.Position - MousePosition).magnitude < 20 then
		Tank = Functions.CreateTank(Player)
		
		local ScriptName = (Player.Name .. Remover.Name)
		local RemoverClone = Remover:Clone()
		RemoverClone.Name = ScriptName
		local Data = {
			{Name = "Creator", Class = "ObjectValue", Value = Player},
			{Name = "Tool", Class = "ObjectValue", Value = Tool},
			{Name = "Model", Class = "ObjectValue", Value = Tank.Model},
		}
		for i, v in pairs(Data) do
			local Object = Create(v.Class){
				Name = v.Name,
				Value = v.Value,
				Parent = RemoverClone
			}
		end
		RemoverClone.Disabled = false
		RemoverClone.Parent = Tank.Model
		
		Tank.Model.Parent = game:GetService("Workspace")
		
		local TankCFrame = Functions.CFrameFromTopBack((MousePosition + Vector3.new(0, 1.8, 0)), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0))
		Tank.Body.CFrame = TankCFrame
		Tank.BodyGyro.cframe = TankCFrame 
		
		Spawn(function()
			InvokeClient("SetCamera", {{Property = "CameraSubject", Value = Tank.Model}, {Property = "CameraType", Value = Enum.CameraType.Track}})
		end)
		
		Tank.Sounds.Idle:Play()
		
		Humanoid.WalkSpeed = 0
		
		if NoteGuiClone and NoteGuiClone.Parent then
			NoteGuiClone.Frame.CreateNote.Visible = false
			NoteGuiClone.Frame.DriveNote.Visible = true
			NoteGuiClone.Frame.FireNote.Visible = true
		end
		
		Tank.Humanoid.Died:connect(function()
			game.Debris:AddItem(Tank.Model, 2)
			Tank.Model:BreakJoints()
			Tank = nil
			Spawn(function()
				InvokeClient("SetCamera", {{Property = "CameraSubject", Value = Character}, {Property = "CameraType", Value = Enum.CameraType.Custom}})
			end)
			if NoteGuiClone and NoteGuiClone.Parent then
				NoteGuiClone.Frame.CreateNote.Visible = true
				NoteGuiClone.Frame.DriveNote.Visible = false
				NoteGuiClone.Frame.FireNote.Visible = false
			end
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
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	
	ToolEquipped = true
	
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		NoteGuiClone = NoteGui:Clone()
		NoteGuiClone.Frame.CreateNote.Visible = true
		NoteGuiClone.Frame.DriveNote.Visible = false
		NoteGuiClone.Frame.FireNote.Visible = false
		NoteGuiClone.Frame.Visible = true
		NoteGuiClone.Parent = PlayerGui
	end
		
end

function Unequipped()
	for i, v in pairs({NoteGuiClone, (((Tank and Tank.Model and Tank.Model) and Tank.Model) or nil), TankControl, ToolUnequipped}) do
		if v and tostring(v) == "Connection" then
			v:disconnect()
		elseif type(v) == "userdata" and v and v.Parent then
			v:Destroy()
		end
	end
	IsPlayingDrive = false
	Spawn(function()
		InvokeClient("SetCamera", {{Property = "CameraType", Value = Enum.CameraType.Custom}, {Property = "CameraSubject", Value = Character}})
	end)
	if CheckIfAlive() then
		Humanoid.WalkSpeed = 16
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Mode == "MouseMove" and not CheckIfTankAlive() then
		Spawn(function()
			local MousePosition = InvokeClient("MousePosition")
			if not MousePosition then
				return
			end
			Spawn(function()
				InvokeClient("SetMouseIcon", ((Torso.Position - MousePosition).magnitude < 20 and (BaseUrl .. "82230945")) or (BaseUrl .. "82071072"))
			end)
		end)
	elseif Mode == "KeyPress" then
		local Key = Value.Key
		local ByteKey = string.byte(Key)
		local Down = Value.Down
		local DirectionKeyPressed = false
		for i, v in pairs(Directions) do
			for ii, vv in pairs(v.Keys) do
				if ((ii == "Key" and vv == Key) or (ii == "ByteKey" and vv == ByteKey)) then
					Directions[i].State = Down
					Directions[i].LastDown = ((Down and 0) or tick())
					DirectionKeyPressed = ((Down and true) or false)
				end
			end
		end
		if not CheckIfTankAlive() then
			return
		end
		if Down then
			if DirectionKeyPressed and not IsPlayingDrive then
				IsPlayingDrive = true
				Tank.Sounds.Start:Play()
				Tank.Sounds.Drive:Play()
				Tank.Sounds.Idle:Stop()
			end
		else
			if Tank and IsPlayingDrive then
				local IsDriving = false
				for i, v in pairs(Directions) do
					if v.State then
						IsDriving = true
					end
				end
				if not IsDriving then
					IsPlayingDrive = false
					Tank.Sounds.Drive:Stop()
					Tank.Sounds.Idle:Play()
				end
			end
		end
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)