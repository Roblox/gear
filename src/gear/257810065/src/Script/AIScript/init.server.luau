--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Figure = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Functions = require(script:WaitForChild("Functions"))
DogeModule = require(191816425)

LastMove = 0

Rate = (1 / 60)

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

Figures = {}

function IncludeFigure(Child)
	if not Child or not Child.Parent then
		return
	end
	local Player = Players:GetPlayerFromCharacter(Child)
	if Player then
		return
	end
	for i, v in pairs(Figures) do
		if v.Figure == Child then
			return
		end
	end
	local Figure = {Figure = Child, TouchDebounce = false, Connections = {}}
	local Humanoid = Child:FindFirstChild("Humanoid")
	local Head = Child:FindFirstChild("Head")
	local Torso = Child:FindFirstChild("Torso")
	if not Humanoid or not Humanoid:IsA("Humanoid") or Humanoid.Health == 0 or not Head or not Torso then
		return
	end
	local Neck = Torso:FindFirstChild("Neck")
	if not Neck then
		return
	end
	for i, v in pairs({Humanoid, Head, Torso, Neck}) do
		Figure[v.Name] = v
	end
	local Values = {"Creator", "Mode", "Follow", "Target", "TargetPos", "Offset", "Damage", "MaxDistance"}
	for i, v in pairs(Values) do
		local Value = Child:FindFirstChild(v)
		if not Value then
			return
		end
		Figure[v] = Value
	end
	local Sounds = {}
	for i, v in pairs(Head:GetChildren()) do
		if v:IsA("Sound") then
			Sounds[v.Name] = v
		end
	end
	local ModuleData = DogeModule.GetTable({Key = "Doge", Player = ((Figure.Creator and Figure.Creator.Value) or nil)})
	local DogeData = ModuleData.GetData({Character = Child})
	Spawn(function()
		DogeData.StartText()
	end)
	local Variables = {
		Bark = {LastBark = 0, Paused = false, TimeOut = 0.75},
		DogeData = DogeData,
	}
	for i, v in pairs(Variables) do
		Figure[i] = v
	end
	Figure.Sounds = Sounds
	local HumanoidChanged = Humanoid.Changed:connect(function(Property)
		if Property == "Sit" and Humanoid.Sit then
			Humanoid.Sit = false
			Humanoid.Jump = true
		end
	end)
	local FigureRemoved = Child.Changed:connect(function(Property)
		if Property == "Parent" and not Child.Parent then
			for i, v in pairs(Figures) do
				if v == Figure then
					for ii, vv in pairs(v.Connections) do
						if vv then
							vv:disconnect()
						end
					end
					table.remove(Figures, i)
				end
			end
		end
	end)
	for i ,v in pairs({HumanoidChanged, FigureRemoved}) do
		table.insert(Figure.Connections, v)
	end
	for i, v in pairs(Child:GetChildren()) do
		if v:IsA("BasePart") then
			local TouchedConnection
			TouchedConnection = v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent or Figure.TouchDebounce then
					return
				end
				local Connected = false
				local ConnectedParts = v:GetConnectedParts()
				if #ConnectedParts <= 1 then
					return
				end
				for i, v in pairs(ConnectedParts) do
					if v == Torso then
						Connected = true
					end
				end
				if not Connected then
					return
				end
				local character = Hit.Parent
				if character:IsA("Hat") then
					character = character.Parent
				end
				if character ~= Figure.Target.Value then
					return
				end
				local player = Players:GetPlayerFromCharacter(character)
				local CreatorValue = Figure.Creator.Value
				if not CreatorValue then
					return
				end
				local CreatorPlayer = ((CreatorValue:IsA("Player") and CreatorValue) or Players:GetPlayerFromCharacter(CreatorValue))
				if player then
					if player == CreatorPlayer then
						return
					end
					if player and CreatorPlayer and Functions.IsTeamMate(CreatorPlayer, player) then
						return
					end
				end
				local creator = character:FindFirstChild("Creator")
				if creator and creator:IsA("ObjectValue") and creator.Value == CreatorValue then
					return
				end
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or not humanoid:IsA("Humanoid") or humanoid.Health == 0 then
					return
				end
				Figure.TouchDebounce = true
				Functions.UntagHumanoid(humanoid)
				Functions.TagHumanoid(humanoid, CreatorPlayer)
				humanoid:TakeDamage(Figure.Damage.Value)
				wait(0.25)
				Figure.TouchDebounce = false
			end)
			table.insert(Figure.Connections, TouchedConnection)
		end
	end
	Figure.Sounds.Wow:Play()
	table.insert(Figures, Figure)
end

function SecureJump(Table)
	local Humanoid = Table.Humanoid
	local Torso = Table.Torso
	if not Humanoid or Humanoid.Jump or not Torso then
		return
	end
	local TargetPoint = Torso.Velocity.Unit
	local Blockage, BlockagePos = Functions.CastRay((Torso.CFrame + CFrame.new(Torso.Position, Vector3.new(TargetPoint.X, Torso.Position.Y, TargetPoint.Z)).lookVector * (Torso.Size.Z / 2)).p, Torso.CFrame.lookVector, (Torso.Size.Z * 2.5), {Figure, (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character) and Creator.Value.Character) or nil)}, false)
	local Jumpable = false
	if Blockage then
		Jumpable = true
		if Blockage:IsA("Terrain") then
			local CellPos = Blockage:WorldToCellPreferSolid((BlockagePos - Vector3.new(0, 2, 0)))
			local CellMaterial, CellShape, CellOrientation = Blockage:GetCell(CellPos.X, CellPos.Y, CellPos.Z)
			if CellMaterial == Enum.CellMaterial.Water then
				Jumpable = false
			end
		elseif Blockage.Parent:FindFirstChild("Humanoid") then
			Jumpable = false
		end
	end
	if Jumpable then
		Humanoid.Jump = true
	end
end

RunService.Stepped:connect(function()
	_, Time = wait(0.05)
	for i, v in pairs(Figures) do
		Spawn(function()
			pcall(function()
				if v and v.Figure and v.Figure.Parent then
					Spawn(function()
						SecureJump(v)
					end)
					local Disabled = v.Figure:FindFirstChild("Disabled")
					if not Disabled then
						local CreatorValue = v.Creator.Value
						if CreatorValue then
							local CreatorPlayer = ((CreatorValue:IsA("Player") and CreatorValue) or Players:GetPlayerFromCharacter(v.Creator.Value))
							if CreatorPlayer then
								local CreatorCharacter = CreatorPlayer.Character
								if CreatorCharacter and CreatorCharacter.Parent then
									local CreatorTorso = CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso")
									if CreatorTorso then
										local DistanceApart = (CreatorTorso.Position - v.Torso.Position).magnitude
										if DistanceApart > v.MaxDistance.Value then
											v.Mode.Value = "Follow"
										end
									end
								end
							end
						end
						if v.Mode.Value == "Follow" then
							local FollowValue = v.Follow.Value
							if FollowValue then
								if FollowValue:IsA("Player") and FollowValue.Character and FollowValue.Character.Parent then
									FollowValue = FollowValue.Character
								end
								local FollowHumanoid = FollowValue:FindFirstChild("Humanoid")
								local FollowTorso = FollowValue:FindFirstChild("Torso") or FollowValue:FindFirstChild("UpperTorso")
								if FollowHumanoid and FollowHumanoid.Health > 0 and FollowTorso then
									--if (v.Torso.Position - FollowTorso.Position).magnitude > 5 then
										v.Humanoid:MoveTo((FollowTorso.CFrame * CFrame.new(v.Offset.Value)).p)
									--end
								end
							end
						elseif v.Mode.Value == "MoveTo" then
							v.Humanoid:MoveTo(v.TargetPos.Value)
							LastMove = Time
							v.Mode.Value = "Nothing"
						elseif v.Mode.Value == "Attack" then
							local TargetCharacter = v.Target.Value
							local TargetDisabled = v.Target:FindFirstChild("Disabled")
							local NotFound = false
							if not TargetDisabled or not TargetDisabled.Value then
								if TargetCharacter and TargetCharacter.Parent then
									local TargetHumanoid = TargetCharacter:FindFirstChild("Humanoid")
									local TargetTorso = TargetCharacter:FindFirstChild("Torso") or TargetCharacter:FindFirstChild("UpperTorso")
									local creator = TargetCharacter:FindFirstChild("Creator")
									if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso and (not creator or (creator and v.Creator.Value ~= creator.Value and not Functions.IsTeamMate(v.Creator.Value, creator.Value))) then
										local Direction = CFrame.new(v.Torso.Position, Vector3.new(TargetTorso.Position.X, v.Torso.Position.Y, TargetTorso.Position.Z))
										local ChaseOffset = 8
										local ChasePosition = (CFrame.new(TargetTorso.Position) - Direction.lookVector * ChaseOffset).p
										local Time = tick()
										local Distance = (v.Torso.Position - TargetTorso.Position).Magnitude
										if Distance <= (ChaseOffset + 1) and not v.Bark.Paused and (Time - v.Bark.LastBark) > v.Bark.TimeOut then
											v.Bark.Paused = true
											Spawn(function()
												for i = 1, math.random(1, 3) do
													local Sound = v.Sounds.Bark:Clone()
													Sound.Pitch = (math.random(900, 1150) * 0.001)
													Debris:AddItem(Sound, 1.5)
													Sound.Parent = v.Head
													v.Sounds.Bark:Play()
													wait(0.15)
												end
												v.Bark.TimeOut = (math.random(250, 750) * 0.001)
												v.Bark.LastBark = tick()
												v.Bark.Paused = false
											end)
											local TargetPlayer = Players:GetPlayerFromCharacter(TargetCharacter)
											if TargetPlayer then
												v.DogeData.ObscureScreen(TargetPlayer)
											end
  										end
										local BodyGyro = Create("BodyGyro"){
											maxTorque = Vector3.new(math.huge, math.huge, math.huge),
											cframe = Direction,
										}
										Debris:AddItem(BodyGyro, Rate)
										BodyGyro.Parent = v.Torso
										v.Humanoid:MoveTo(ChasePosition)
									else
										NotFound = true
									end
								else
									NotFound = true
								end
							end
							if NotFound then
								v.Target.Value = nil
								v.Mode.Value = "Follow"
							end
						elseif v.Mode.Value == "Nothing" then
							if (Time - LastMove) >= 30 then
								v.Mode.Value = "Follow"
							end
						end
					end
				end
			end)
		end)
	end
end)

IncludeFigure(Figure)