--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Smoke = Handle:WaitForChild("Smoke")

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


FadeScript = script:WaitForChild("FadeScript")

BaseUrl = "http://www.roblox.com/asset/?id="

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

Animations = {
	Spray = {Animation = Tool:WaitForChild("Spray"), FadeTime = nil, Weight = nil, Speed = nil},
}

Sounds = {
	Audio = Handle:WaitForChild("Audio"),
	Spray = Handle:WaitForChild("Spray"),
}

CoolDown = 2
MaxRange = 10
Images = {273067017}

AudioPlayed = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:FindFirstChild("Humanoid") then
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

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local MousePosition = InvokeClient("MousePosition")
	if not MousePosition then
		Tool.Enabled = true
		return
	end
	local MousePosition = MousePosition.Position
	if SmokePart and SmokePart.Parent then
		SmokePart:Destroy()
	end
	SmokePart = BasePart:Clone()
	SmokePart.Name = "SmokePart"
	SmokePart.Transparency = 1
	SmokePart.CanCollide = 1
	local SmokeParticles = Smoke:Clone()
	SmokeParticles.Enabled = true
	SmokeParticles.Parent = SmokePart
	local SmokeWeld = Create("Weld"){
		Part0 = Handle,
		Part1 = SmokePart,
		C0 = (CFrame.new(0, (Handle.Size.Y / 2), 0) * CFrame.Angles((-(math.pi * 2) / 3), 0, 0)),
		C1 = CFrame.new(0, 0, 0),
		Parent = SmokePart,
	}
	Debris:AddItem(SmokePart, (CoolDown + 1.5))
	SmokePart.Parent = Tool
	Delay(CoolDown, (function()
		SmokeParticles.Enabled = false
	end))
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Spray)
	end)
	if AudioPlayed then
		Sounds.Spray:Play()
	else
		Sounds.Audio:Play()
	end
	AudioPlayed = true
	local Direction = CFrame.new(SmokePart.Position, MousePosition)
	local RayHit, RayPos, RayNormal = CastRay(SmokePart.Position, Direction.lookVector, MaxRange, {Character}, false)
	if RayHit then
		local ImagePart = BasePart:Clone()
		ImagePart.Name = "Effect"
		ImagePart.Transparency = 1
		ImagePart.Size = Vector3.new(8, 4.5, 0.2)
		ImagePart.Anchored = false
		ImagePart.CanCollide = false
		local Decal = Create("Decal"){
			Name = "Decal",
			Texture = (BaseUrl .. Images[math.random(1, #Images)]),
			Transparency = 1,
			Face = Enum.NormalId.Front,
			Parent = ImagePart,
		}
		local FadeScriptClone = FadeScript:Clone()
		FadeScriptClone.Disabled = false
		FadeScriptClone.Parent = ImagePart
		local PartCFrame = CFrame.new(RayPos, (CFrame.new(RayPos) + RayNormal * 2).p)
		PartCFrame = (PartCFrame * CFrame.new(0, (ImagePart.Size.Y / 4), 0))
		--[[local NewDirection = CFrame.new(SmokePart.Position, RayPos)
		local OPX, OPY, OPZ, OXX, OYX, OZX, OXY, OYY, OZY, OXZ,OYZ, OZZ = PartCFrame:components()
		local NPX, NPY, NPZ, NXX, NYX, NZX, NXY, NYY, NZY, NXZ, NYZ, NZZ = NewDirection:components()
		PartCFrame = CFrame.new(
			OPX, OPY, OPZ,
			NXX, OYX, OZX,
			OXY, OYY, OZY,
			NXZ, OYZ, OZZ
		) * CFrame.Angles(math.pi, 0, 0)]]
		local Weld = Create("Motor6D"){
			Name = "Stick",
			Part0 = ImagePart,
			Part1 = RayHit,
			C0 = PartCFrame:inverse(),
			C1 = RayHit.CFrame:inverse(),
			Parent = ImagePart,
		}
		Debris:AddItem(ImagePart, 10)
		ImagePart.Parent = game:GetService("Workspace")
	end
	wait(CoolDown)
	Sounds.Spray:Stop()
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	AudioPlayed = false
	ToolEquipped = true
end

function Unequipped()
	if SmokePart and SmokePart.Parent then
		SmokePart:Destroy()
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)