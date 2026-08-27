--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Functions = require(script:WaitForChild("Functions"))

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


FreezePlayer = script:WaitForChild("FreezePlayer")
RechargeGui = script:WaitForChild("RechargeGui")

BaseUrl = "http://www.roblox.com/asset/?id="

Gravity = 196.20

Damage = 60
CoolDownTime = 9
MaxJumpDistance = 60
LastUse = 0
PointsAlongJump = 18

Rate = (1 / 60)

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Anchored = false,
	CanCollide = true,
	Locked = true,
}

BaseBoot = Functions.SetProperties({Object = BasePart:Clone(), Properties = {
	Name = "Boot",
	Size = Vector3.new(1, 1, 1.6),
	CanCollide = false,
}})

BootMesh = Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "97180581"),
	TextureId = (BaseUrl .. "97180639"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseBoot,
}

Grips = {
	Equipped = CFrame.new(0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Unequipped = CFrame.new(1.5, 3.5, -1.3, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Animations = {
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Hit = Handle:WaitForChild("Hit"),
	Jump = Handle:WaitForChild("Jump")
}

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

ToolEquipped = false

Handle.Transparency = 1
Tool.Enabled = true

function EquipBoots()
	UnequipBoots()
	local LeftLeg = Character:FindFirstChild("Left Leg")
	local RightLeg = Character:FindFirstChild("Right Leg")
	for i, v in pairs({LeftLeg, RightLeg}) do
		if v and v.Parent then
			local Boot = Functions.SetProperties({Object = BaseBoot:Clone(), Properties = {
				Name = (((v == LeftLeg and "Left") or "Right") .. "Boot"),
			}})
			local Weld = Create("Weld"){
				Part0 = Boot,
				Part1 = v,
				C0 = CFrame.new(0, 0.57, 0.19),
				Parent = Boot,
			}
			if i == LeftLeg then
				LeftBoot = Boot
				LeftWeld = Weld
			else
				RightBoot = Boot
				RightWeld = Weld
			end
			Boot.Parent = Tool
		end
	end
end

function CreateDisplayBoots()
	for i = 1, 2 do
		local Boot = Functions.SetProperties({Object = BaseBoot:Clone(), Properties = {
			Name = (((i == 1 and "Left") or "Right") .. "Boot")
		}})
		local Weld = Create("Weld"){
			Part0 = Boot,
			Part1 = Handle,
			C0 = CFrame.new(((((Boot.Size.X / 2) + (Handle.Size.X / 2)) / 2.5) * ((i == 1 and -1) or 1)), 0, 0.19),
			Parent = Boot,
		}
		Boot.Parent = Tool
	end
end

function UnequipBoots()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and (v.Name == "LeftBoot" or v.Name == "RightBoot") then
			v:Destroy()
		end
	end
end

function PointOnCircle(OriginX, OriginZ, Radius, Theta)
	local x = OriginX + Radius * math.cos(Theta)
	local z = OriginZ + Radius * math.sin(Theta)
	return x, z
end

function SquishCharacter(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
	end
	local LowestY = math.huge
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			local SquishedPoint = (v.CFrame.p - (v.Size * 0.4))
			if SquishedPoint.Y < LowestY then
				LowestY = SquishedPoint.Y
			end
		end
	end
	if not LowestY then
		return
	end
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			local OriginalCFrame = v.CFrame
			local OffsetY = (OriginalCFrame.p.Y - LowestY)
			Functions.SetProperties({Object = v, Properties = {
				Anchored = true,
				FormFactor = Enum.FormFactor.Custom,
			}})
			local OrigCFrame = v.CFrame
			local OffsetY = (OrigCFrame.p.Y - LowestY)
			if v.Name ~= "Head" then
				v.Size = v.Size * Vector3.new(1.6, 0.2, 1.6)
			else
				local Mesh = v:FindFirstChild("Mesh")
				if Mesh then
					Mesh.Scale = Vector3.new(Mesh.Scale.X, ((Mesh.Scale.Y / 4) * 3), Mesh.Scale.Z)
				end
			end
			v.CFrame = (OrigCFrame - Vector3.new(0, OffsetY, 0))
			if v.Name == "Torso" then
				v.CFrame = v.CFrame + Vector3.new(0, 0.1, 0)
			end
		elseif v:IsA("CharacterMesh") then
			local BodyParts = character:GetChildren()
			local BodyPart
			for ii, vv in pairs(character:GetChildren()) do
				if vv:IsA("BasePart") and string.lower(string.gsub(v.BodyPart.Name, " ", "")) == string.lower(vv.Name) then
					local MeshPresent = false
					for iii, vvv in pairs(vv:GetChildren()) do
						if vvv:IsA("DataModelMesh") then
							MeshPresent = true
						end
					end
					if not MeshPresent then
						local NewMesh = Create("SpecialMesh"){
							MeshId = (BaseUrl .. tostring(v.MeshId)),
							TextureId = ((v.OverlayTextureId ~= 0 and (BaseUrl .. v.OverlayTextureId)) or (v.BaseTextureId ~= 0 and (BaseUrl .. v.BaseTextureId)) or ""),
							Scale = Vector3.new(1, 0.2, 1),
							Parent = vv,
						}
					end
				end
			end
		end
	end
end

function Jump(Destination, TargetObject)
	
	if not ToolEquipped or not CheckIfAlive() then
		return
	end	
	
	local DifferenceVector = (Torso.CFrame.p - Destination)
	local Distance = DifferenceVector.Magnitude
	local DirVector = DifferenceVector.Unit
	local HalfPoint = ((DifferenceVector / 2) + Torso.Position)
	local ArcedHalfPoint = (DirVector:Cross(Vector3.new(0, 1, 0)):Cross(DirVector) * (Distance / 2) + HalfPoint)
	
	if Distance > MaxJumpDistance then
		if RechargeGuiClone and RechargeGuiClone.Parent then
			local RechargeText = RechargeGuiClone:FindFirstChild("RechargeText")
			if RechargeText then
				RechargeText.Text = (RechargeText.Text .. " ")
				RechargeText.Text = "Too Far Away!"
				local TextChanged = false
				local TextChangedConnection = RechargeText.Changed:connect(function(Property)
					if Property == "Text" then
						TextChanged = true
					end
				end)
				Delay(2, (function()
					if TextChangedConnection then
						TextChangedConnection:disconnect()
					end
					if not TextChanged then
						RechargeText.Text = "Ready"
					end
				end))
			end
		end
		LastUse = 0
		return
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	
	StartGuiRecharge()
	if TargetObject and TargetObject.Parent then
		local character = TargetObject.Parent
		if character and character:IsA("Hat") then
			character = character.Parent
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local freezePlayerCopy = FreezePlayer:Clone()
			freezePlayerCopy.Disabled = false
			freezePlayerCopy.Parent = character
		end
	end

	local WayPoints = {}
	for i = 1, PointsAlongJump do
		if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
			break
		end
		local ObjectZ, ObjectY = PointOnCircle((Distance / 2), 0, (Distance / 2), (math.pi - (math.pi / PointsAlongJump) * i))
		local NextPoint = CFrame.new(Torso.CFrame.p, Destination):pointToWorldSpace(Vector3.new(0, ObjectY, -ObjectZ))
		local NextTargetPart = Functions.SetProperties({Object = BasePart:Clone(), Properties = {
			Name = tostring(i),
			BrickColor = BrickColor.new("Really red"),
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(1, 1, 1),
			CanCollide = false,
			Anchored = true,
			CFrame = CFrame.new(NextPoint),
		}})
		Debris:AddItem(NextTargetPart, 10)
		NextTargetPart.Parent = game:GetService("Workspace")
		table.insert(WayPoints, NextTargetPart)
	end
	Humanoid.PlatformStand = true
	Sounds.Jump:Play()
	local BodyPosition = Create("BodyPosition"){
		Parent = Torso,
	}
	local BodyGyro = Create("BodyGyro"){
		maxTorque = Vector3.new(math.huge, math.huge, math.huge),
		Parent = Torso,
	}
	local CurrentWayPoint = 1
	Spawn(function()
		BodyGyro.cframe = CFrame.new(Torso.CFrame.p, Destination)
		while BodyPosition and BodyPosition.Parent and ToolEquipped and CurrentlyEquipped and CheckIfAlive() do
			local WayPoint = WayPoints[CurrentWayPoint]
			local ConnectedParts = Functions.GetAllConnectedParts(Torso)
			local Mass = 0
			for i, v in pairs(ConnectedParts) do
				Mass = (Mass + v:GetMass())
			end 
			local Mass = (Mass * Gravity * math.huge)
			BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyPosition.position = WayPoint.Position
			if (Torso.Position - WayPoint.Position).magnitude <= 10 then
				CurrentWayPoint = (CurrentWayPoint + 1)
				if CurrentWayPoint > #WayPoints then
					CurrentWayPoint = #WayPoints
				end
				if CurrentWayPoint == #WayPoints then
					break
				end
			end
			wait(Rate)
		end
		for i, v in pairs({BodyPosition, BodyGyro}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		Humanoid.PlatformStand = false
		wait(0.5)
		for i, v in pairs({LeftBootConnection, RightBootConnection}) do
			if v then
				v:disconnect()
			end
		end
		for i, v in pairs(WayPoints) do
			if v and v.Parent then
				v:Destroy()
			end
		end
	end)
	
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end

	local BootsTouched = false
	for i, v in pairs({LeftBoot, RightBoot}) do
		local Weld = ((v == LeftBoot and LeftWeld) or RightWeld)
		local connection = v.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or CurrentWayPoint < (#WayPoints - 1) or BootsTouched or not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			if not Weld or not Weld.Parent or not Weld.Part0 or not Weld.Part1 or Weld.Part0 ~= v then
				return
			end
			local character = Hit.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			if character == Character then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if player and Functions.IsTeamMate(Player, player) then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				return
			end
			BootsTouched = true
			if humanoid and humanoid.Health <= Damage then
				SquishCharacter(character)
			end
			Functions.UntagHumanoid(humanoid)
			Functions.TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage)
			Sounds.Hit:Play()
			for i, v in pairs({LeftBootConnection, RightBootConnection}) do
				if v then
					v:disconnect()
				end
			end
		end)
		if v == LeftBoot then
			LeftBootConnection = connection
		else
			RightBootConnection = connection
		end
	end
	Debris:AddItem(BodyPosition, CoolDownTime)
	Debris:AddItem(BodyGyro, CoolDownTime)
	wait(CoolDownTime)
	if CheckIfAlive() then
		Humanoid.PlatformStand = false
	end
	for i, v in pairs({LeftBootConnection, RightBootConnection}) do
		if v then
			v:disconnect()
		end
	end
end

function StartGuiRecharge()
	if not RechargeGuiClone or not RechargeGuiClone.Parent then
		return
	end
	local Bar = RechargeGuiClone:FindFirstChild("Bar")
	local RechargeText = RechargeGuiClone:FindFirstChild("RechargeText")
	if not Bar or not RechargeText then
		return
	end
	local Backing = Bar:FindFirstChild("Backing")
	local Fill = Bar:FindFirstChild("Fill")
	if not Backing or not Fill then
		return
	end
	RechargeText.Text = "Recharging..."
	local TimeRemaining = math.min(CoolDownTime, tick() - LastUse)
	Fill.Size = UDim2.new((TimeRemaining / CoolDownTime), 0, 1, 0)
	Fill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", (CoolDownTime - TimeRemaining), false, (function()
		RechargeText.Text = "Ready"
	end))
end

function FindClosestTorso()
	local NearestTorso = nil
	local NearestDistance = MaxJumpDistance
	for i, v in pairs(Players:GetPlayers()) do
		if v:IsA("Player") and v ~= Player and v.Character then
			local character = v.Character
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso")
			if humanoid and humanoid.Health > 0 and torso then
				local DistanceApart = (torso.Position - Torso.Position).magnitude
				if DistanceApart < NearestDistance then
					NearestTorso = torso
					NearestDistance = DistanceApart
				end
			end
		end
	end
	return NearestTorso
end

function Activated(MouseData)
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	local MouseTarget = MouseData.Target
	if not MouseTarget or not MouseTarget.Parent then
		return
	end
	local character = MouseTarget.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if (tick() - LastUse) > CoolDownTime then
		LastUse = tick()
		if humanoid then
			Jump(MouseData.Position, MouseTarget)
		else
			Jump(MouseData.Position)
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		if PlayerGui then
			RechargeGuiClone = RechargeGui:Clone()
			RechargeGuiClone.Parent = PlayerGui
		end
		Spawn(EquipBoots)
		Spawn(StartGuiRecharge)
		Spawn(function()
			InvokeClient("PlayAnimation", Animations.Idle)
		end)
	end)
	Tool.Grip = Grips.Equipped
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	Spawn(function()
		if RechargeGuiClone and RechargeGuiClone.Parent then
			RechargeGuiClone:Destroy()
		end
		for i, v in pairs({LeftBootConnection, RightBootConnection}) do
			if v then
				v:disconnect()
			end
		end
		Spawn(function()
			InvokeClient("StopAnimation", Animations.Idle)
		end)
		Spawn(UnequipBoots)
		Spawn(CreateDisplayBoots)
	end)
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "MouseClick" then
		local Down = value.Down
		if Down then
			Activated({Target = value.Target, Position = value.Position})
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

UnequipBoots()
CreateDisplayBoots()

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)