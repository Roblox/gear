--Rescripted by Luckymaxer

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


BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

MaxChargeRange = 100
MaxWayPoints = 5
MaxJumpDistance = 100
JumpBackDist = 5
ChargeDamage = 50

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
function CastRay(startPos, vec, rayLength)
	local Ignore = {Character}
	vec = vec.unit
	local hitObject, hitPos = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(startPos + (vec * .01), vec * rayLength), Ignore)
	if hitObject and hitPos then
		local distance = rayLength - (hitPos - startPos).magnitude
		if CheckIntangible(hitObject) and distance > 0 then
			-- there is a chance here for potential infinite recursion
			return CastRay(hitPos, vec, distance)
		end
	end
	return hitObject, hitPos
end

function CreateTrail(pt1, pt2)
	local Path = BasePart:Clone()
	Path.Name = "Effect"
	Path.Transparency = 0.5
	Path.Size = Vector3.new(0.2, 4, (pt2 - pt1).Magnitude)
	Path.CFrame = CFrame.new((pt1 + pt2)/2, pt2)
	Path.Anchored = true
	Path.CanCollide = false
	Path.BrickColor = BrickColor.new("Really red")
	Debris:AddItem(Path, 5)
	Path.Parent = game:GetService("Workspace")
	Spawn(function()
		local start = tick()
		while Path and Path.Parent and (tick() - start) < 2 do
			Path.Transparency = (0.5 + (((tick() - start) / 2)))
			wait()
		end
	end)
	return Path
end

function ClassifySurface(part, point)
	local psize = part.Size
	local localPoint = part.CFrame:pointToObjectSpace(point)
	local posDiff = psize/2 - localPoint
	local negDiff = psize/2 + localPoint
	local minDiff = Vector3.new(
		math.min(math.abs(posDiff.x), math.abs(negDiff.x)),
		math.min(math.abs(posDiff.y), math.abs(negDiff.y)),
		math.min(math.abs(posDiff.z), math.abs(negDiff.z))
	)		 
	if minDiff.x <= math.min(minDiff.y, minDiff.z) then -- On x-axis
		if math.abs(posDiff.x) < math.abs(negDiff.x) then
			return Enum.NormalId.Right
		else
			return Enum.NormalId.Left
		end
	elseif minDiff.y <= minDiff.z then -- On y-axis
		if math.abs(posDiff.y) < math.abs(negDiff.y) then
			return Enum.NormalId.Top
		else
			return Enum.NormalId.Bottom
		end
	else -- On z-axis
		if math.abs(posDiff.z) < math.abs(negDiff.z) then
			return Enum.NormalId.Back
		else
			return Enum.NormalId.Front
		end
	end
end

function GetTangentVectors(part, point)
	local normalId = ClassifySurface(part, point)
	local normal = Vector3.FromNormalId(normalId)
	local localHitOffset = part.CFrame:pointToObjectSpace(point)
	local tangentVectors = {}
	for i = -1, 1, 2 do
		-- Add three so we can round the corners
		local xVec = Vector3.new(((part.Size.x)/2 + JumpBackDist) * i  - localHitOffset.x,0,0)
		if math.abs(normal:Dot(xVec.unit)) < 0.8 then
			-- To World Space
			table.insert(tangentVectors, (part.CFrame-part.CFrame.p)*(xVec))
		end
		local yVec = Vector3.new(0,((part.Size.y)/2 + JumpBackDist) * i  - localHitOffset.y,0)
		if math.abs(normal:Dot(yVec.unit)) < 0.8 then
			table.insert(tangentVectors, (part.CFrame-part.CFrame.p)*(yVec))
		end
		local zVec = Vector3.new(0,0,((part.Size.z) /2 + JumpBackDist) * i - localHitOffset.z)
		if math.abs(normal:Dot(zVec.unit)) < 0.8 then
			table.insert(tangentVectors, (part.CFrame-part.CFrame.p)*(zVec))
		end
	end
	return tangentVectors
end

function WaypointsRecurse(currPos, desiredPos, wps, depth)
	if (desiredPos - currPos).magnitude < 10 then
		return true
	end
	if depth <= MaxWayPoints then
		local rayDir = desiredPos - currPos
		local hitObj, hitPos = CastRay(currPos, rayDir, math.min(MaxJumpDistance, rayDir.magnitude))
		-- back up JumpBackDist studs for torso
		local directPos = hitPos - (rayDir.unit * JumpBackDist)
		local candidates = {}
		table.insert(candidates, directPos)
		if hitObj then
			local tang = GetTangentVectors(hitObj, hitPos)
			for _, vec in pairs(tang) do
				-- Turn the tangent vector into a translation vector
				local tangVec = (hitPos + vec) - currPos
				local obj, pos = CastRay(currPos, tangVec, math.min(MaxJumpDistance, (tangVec.magnitude)))
				table.insert(candidates, pos)
			end
		else
			local xObj, xPos = CastRay(currPos, Vector3.new(rayDir.x, 0,0), math.min(MaxJumpDistance, math.abs(rayDir.x)))
			local yObj, yPos = CastRay(currPos, Vector3.new(0,rayDir.y, 0), math.min(MaxJumpDistance, math.abs(rayDir.y)))
			local zObj, zPos = CastRay(currPos, Vector3.new(0,0,rayDir.z), math.min(MaxJumpDistance, math.abs(rayDir.z)))
			
			table.insert(candidates, xPos - (xObj and (xPos - currPos).unit * JumpBackDist or Vector3.new()))
			table.insert(candidates, yPos - (yObj and (yPos - currPos).unit * JumpBackDist or Vector3.new()))
			table.insert(candidates, zPos - (zObj and (zPos - currPos).unit * JumpBackDist or Vector3.new()))
		end
		-- sort by closeness
		table.sort(candidates, function(a,b) return (desiredPos - a).magnitude < (desiredPos - b).magnitude end)
		while candidates[1] do
			local currPoint = table.remove(candidates)
			if WaypointsRecurse(currPoint, desiredPos, wps, depth + 1) then
				table.insert(wps, 1, currPoint)
				return true
			end
		end
	end
	return false
end

function GetClosestTarget()
	local PlayerDistances = {}
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Player and not IsTeamMate(Player, v) then
			local character = v.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				local torso = character:FindFirstChild("Torso")
				local DistanceApart = (Torso.Position - torso.Position).Magnitude
				if DistanceApart < 150 and humanoid and humanoid.Health > 0 and torso then
					table.insert(PlayerDistances, {Player = v, DistanceApart = DistanceApart, Humanoid = humanoid, Torso = torso})
				end
			end
		end
	end
	if #PlayerDistances == 0 then
		return
	end
	table.sort(PlayerDistances, (function(a, b)
		return (a.DistanceApart < b.DistanceApart)
	end))
	return PlayerDistances[1]
end

function Charge()
	local player = GetClosestTarget()
	if CheckIfAlive() and ToolEquipped and player then
		local wps = {}
		local success = WaypointsRecurse(Torso.CFrame.p, player.Torso.CFrame.p, wps, 0)
		if success then
			ChargeVelocity = Create("BodyVelocity"){
				Name = "ChargeVelocity",
				velocity = Vector3.new(0, 0, 0),
				maxForce = Vector3.new(0, 0, 0),
				P = 100000000,
			}
			ChargeGyro = Create("BodyGyro"){
			}
			Debris:AddItem(ChargeVelocity, 10)
			Debris:AddItem(ChargeGyro, 10)
			ChargeVelocity.Parent = Torso
			ChargeGyro.Parent = Torso
			local start = tick()
			ChargeVelocity.maxForce = Vector3.new(10000000, 100000, 10000000)
			for i, waypoint in pairs(wps) do
				local PathSuccess = false
				local PathFailed = false
				while CheckIfAlive() and ToolEquipped and not PathSuccess and not PathFailed do
					if (Vector3.new(waypoint.X, Torso.Position.Y, waypoint.Z) - Torso.Position).Magnitude < 5 then
						PathSuccess = true
					elseif (tick() - start) > 2 then
						PathFailed = true
					end
					ChargeVelocity.velocity = ((waypoint - Torso.CFrame.p).Unit * 150)
					wait()
				end
				if PathFailed then
					break
				end
				if CheckIfAlive() and ToolEquipped then
					if i > 1 and PathSuccess then
						local trail = CreateTrail(wps[(i - 1)], wps[i])
						Debris:AddItem(trail, 2)
					end
					if i == #wps then
						local humanoid = player.Humanoid
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(ChargeDamage)
					end
				end
			end
			for i, v in pairs({ChargeVelocity, ChargeGyro}) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			wait(math.max(0, (10 - (tick() - start))))
		end
	end
end

function GrowHorns(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Horns = BasePart:Clone()
	Horns.Name = "Horns"
	Horns.Size = Vector3.new(2, 2, 2)
	Horns.CanCollide = false
	Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		MeshId = (BaseUrl .. "138330146"),
		TextureId = (BaseUrl .. "138330253"),
		Scale = Vector3.new(1, 1, 1),
		VertexColor = Vector3.new(1, 1, 1),
		Offset = Vector3.new(0, 0, 0),
		Parent = Horns,
	}
	local Weld = Create("Weld"){
		Part0 = Horns,
		Part1 = Head,
		C0 = CFrame.new(0, -0.6, 1),
		C1 = CFrame.new(0, 0, 0),
		Parent = Horns,
	}
	Horns.Parent = Tool
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Charge()
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		GrowHorns(true)
	end)
end

function Unequipped()
	for i, v in pairs({ChargeVelocity, ChargeGyro, Horns}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	ToolEquipped = false
end

GrowHorns(false)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)