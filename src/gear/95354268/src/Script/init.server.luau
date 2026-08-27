-- Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

AIScript = script:WaitForChild("AIScript")
RemoverScript = script:WaitForChild("RemoverScript")

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


FigureModel = InsertService:LoadAsset(105428829)
Figure = FigureModel:GetChildren()[1]:Clone()
Debris:AddItem(FigureModel, 1)

Sounds = {
	LaserSound = Handle:WaitForChild("LaserSound")
}

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

LaserDamage = 3
LaserDuration = 1.5
ChanceToSpawn = 0.1
Duration = 30
CoolDown = 1

SpawnOffset = Vector3.new(15, 0, 15)

RayPartsLeft = {}
RayPartsRight = {}

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

Tool.Enabled = true

function ResetRayParts()
	for i, v in pairs({RayPartsLeft, RayPartsRight}) do
		for ii, vv in pairs(v) do
			if vv and vv.Parent then
				vv:Destroy()
			end
		end
	end
	RayPartsLeft, RayPartsRight = {}, {}
end

function CastLightRay(StartPos, EndPos, Parts, EffectFunction)
	local EndPos = (StartPos + ((EndPos - StartPos).Unit * 50))
	local Color = BrickColor.new(1, 0, 0)
	local SegLength = 5
	local SegSpeed = 0.2

	local RayHit, RayPos = game:GetService("Workspace"):FindPartOnRay(Ray.new(StartPos, (EndPos - StartPos)), Character)
	if RayPos then
		EndPos = RayPos
	end
	
	if RayHit and RayHit.Parent then
		local character = RayHit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		local IsTeamMate = false
		local player = Players:GetPlayerFromCharacter(character)
		if player and Functions.IsTeamMate(Player, player) then
			IsTeamMate = true
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health > 0 and not IsTeamMate then
			EffectFunction(humanoid, (EndPos - StartPos).Unit)
		end
	end	
	
	local NumSegments = math.floor(math.min(((StartPos - EndPos).Magnitude / SegLength), 50))
	local InitNumParts = #Parts
	for i = NumSegments, InitNumParts, 1 do
		if Parts[i] then
			Parts[i]:Destroy()
			Parts[i] = nil
		end
	end
	
	for i = 1, NumSegments, 1 do
		if not Parts[i] then
			local Laser = BasePart:Clone()
			Laser.Name = "Laser"
			Laser.BrickColor = Color
			Laser.Size = Vector3.new(0, 0, SegLength)
			Laser.Anchored = true
			Laser.CanCollide = false
			Laser.Parent = Tool
			local tlight = Create("PointLight"){
				Name = "Light",
				Color = Color.Color,
				Range = (((math.sin(tick() * 3) + 1) * 1) + 5),
				Brightness = (((math.sin(tick() * 3) + 1) * 1) + 1),
				Parent = Laser,
			}
			Parts[i] = Laser
		end
		Parts[i].CFrame = CFrame.new((((i - 0.4) * (EndPos - StartPos).Unit * SegLength) + StartPos), EndPos)
	end
	
	return Parts
end

function DamageFunction(humanoid)
	if humanoid and humanoid.Health > 0 then
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(LaserDamage)
	end
end

function ShootLaser()
	local StartTime = tick()
	Sounds.LaserSound:Play()
	while ToolEquipped and CheckIfAlive() and (tick() - StartTime) <= LaserDuration do
		local StartPoint = Handle.Position + Handle.CFrame:vectorToWorldSpace(Vector3.new(-0.2, 0.8, -0.2))
		local MousePosition = InvokeClient("MouseData")
		if MousePosition then
			MousePosition = MousePosition.Position
			RayPartsLeft = CastLightRay(StartPoint, MousePosition, RayPartsLeft, DamageFunction)
			StartPoint = Handle.Position + Handle.CFrame:vectorToWorldSpace(Vector3.new(0.2, 0.8, -0.2))
			RayPartsRight = CastLightRay(StartPoint, MousePosition, RayPartsRight, DamageFunction)
		end
		wait()
	end
	Sounds.LaserSound:Stop()
	ResetRayParts()
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	if (not FigureCopy or not FigureCopy.Parent) and math.random() <= ChanceToSpawn then
		FigureCopy = Figure:Clone()
		if FigureCopy then
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Tool", Class = "ObjectValue", Value = Tool},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = FigureCopy,
				}
			end
			for i, v in pairs({AIScript, RemoverScript}) do
				local ScriptClone = v:Clone()
				ScriptClone.Disabled = false
				ScriptClone.Parent = FigureCopy
			end
			Debris:AddItem(FigureCopy, Duration)
			FigureCopy.Parent = game:GetService("Workspace")
			FigureCopy:MoveTo(Handle.Position + SpawnOffset)
		end
	end
	ShootLaser()
	wait(CoolDown)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	Spawn(function()
		for i, v in pairs({FigureCopy}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		ResetRayParts()
	end)
	Sounds.LaserSound:Stop()
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
	if player ~= Player or not mode then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)