Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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


BaseUrl = "rbxassetid://"

BombScript = script:WaitForChild("BombScript"):Clone()

Sounds = {
	Release = Handle:WaitForChild("Release"),
}

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

local Bomb = Tool.Pumpkin:Clone()
local BombMotor = Bomb:FindFirstChildOfClass("Motor6D")
if BombMotor then
	BombMotor:Destroy()
end
BombMotor = nil
Tool.Pumpkin:Destroy()

Gravity = workspace.Gravity

Duration = 0.25
ReloadTime = 4

BombReady = true
ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")

ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})

ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

Tool.Enabled = true

function WeldToAttachments(attach1, attach2)
	local NewMotor = Instance.new("Motor6D")
	NewMotor.Name = "BombWeld"
	NewMotor.Part0 = attach1.Parent
	NewMotor.Part1 = attach2.Parent
	NewMotor.C0 = attach1.CFrame
	NewMotor.C1 = attach2.CFrame
	NewMotor.Parent = attach1.Parent	
	
	return NewMotor
end

function CreateBomb()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	if BombCopy and BombCopy.Parent then
		BombCopy:Destroy()
	end
	BombCopy = Bomb:Clone()
	WeldToAttachments(BombCopy:FindFirstChild("PumpkinAttachment"), Handle.PumpkinAttachment)
	BombCopy.Parent = Tool
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not MouseData.Position then
		return
	end
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped or not BombReady then
		return
	end

	Tool.Enabled = false
	BombReady = false
	Sounds.Release.Pitch = (math.random(900, 1200) * 0.001)
	Sounds.Release:Play()
	if BombCopy and BombCopy.Parent then
		spawn(function()
			local CurrentBomb = BombCopy
			BombCopy = nil
			local SpawnPos = CurrentBomb.Position
			local TargetPos = MouseData.Position
			
			local Direction = (TargetPos - SpawnPos)
			Direction = (Direction - Direction.unit * 5)
			
			local DeltaXZSquared = ((Direction.X ^ 2) + (Direction.Z ^ 2))
			local DeltaXZ = math.sqrt(DeltaXZSquared)
			local DeltaY = Direction.Y
			local Alpha = (math.random() * math.pi / 4 + math.pi / 8)
			local Numerator = (-0.5 * Gravity * DeltaXZSquared)
			local Denominator = (math.cos(Alpha) * math.cos(Alpha) * (DeltaY - math.tan(Alpha) * DeltaXZ))
			if Denominator == 0 then
				return
			end
			local MissileSpeed = math.sqrt(Numerator / Denominator)
			if MissileSpeed > 80 or tostring(MissileSpeed) == "-1.#IND" or tostring(MissileSpeed) == "1.#INF" then
				MissileSpeed = 80
			end
			
			local VectorXZ = (MissileSpeed * math.cos(Alpha))
			local VectorY = (MissileSpeed * math.sin(Alpha))
			local VectorX = (VectorXZ * Direction.X / DeltaXZ)
			local VectorZ = (VectorXZ * Direction.Z / DeltaXZ)
			
			local BombWeld = CurrentBomb:FindFirstChildOfClass("Motor6D")
			if BombWeld then
				BombWeld:Destroy()
			end

			CurrentBomb.CanCollide = true
			CurrentBomb.Velocity = Vector3.new(VectorX, VectorY, VectorZ)
			
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "PushForce", Class = "NumberValue", Value = 40},
				{Name = "Damage", Class = "NumberValue", Value = 5},
			}
			
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = CurrentBomb,
				}
			end
			
			local BombScriptCopy = BombScript:Clone()
			BombScriptCopy.Disabled = false
			BombScriptCopy.Parent = CurrentBomb
			
			Debris:AddItem(CurrentBomb, 10)
			CurrentBomb.Parent = game:GetService("Workspace")
		end)
	end

	wait(ReloadTime)
	CreateBomb()
	BombReady = true
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Tool.Equip.AnimationId = BaseUrl .. 1130818092
	else
		Tool.Equip.AnimationId = BaseUrl .. 1130831306
	end
	spawn(function() InvokeClient("PlayAnimation", {Animation = Tool.Equip}) end)
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	spawn(function()
		if BombReady then
			CreateBomb()
		end
	end)
end

function Unequipped()
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)