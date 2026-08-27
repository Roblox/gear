-- SolarCrane




local SwingTrack = nil
local TuckTrack = nil

local SKI_MESH = 142468161
local POLE_MESH = 142468332
local SKI_TX1 = 142465527
local SKI_TX2 = 142465545

--- FRICTION COEFFIECIENTS ---
local KineticWoodSnow = 0.1
local KineticSkiSnow = 0.05
local StaticWoodSnow = 0.14
local StaticSkiSnow = 0.1

local BodyVelocity = nil
local BodyGyro = nil

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')


local SKI_SWING_ANIM = Tool:WaitForChild('Swing')
local SKI_TUCK_ANIM =  Tool:WaitForChild('Tuck')

local PlayersService = Game:GetService('Players')

local Character, Torso, LeftLeg, RightLeg = nil
local Skis = {}

local function New(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				if type(v) == 'function' then
					obj[k]:connect(v)
				else
					obj[k] = v
				end
			end
		end
		return obj
	end
end

local function GetAssetUrl(assetId)
	return 'http://www.roblox.com/asset/?id=' .. tostring(assetId)
end

local function GetCharacter()
	if PlayersService:GetPlayerFromCharacter(Tool.Parent) then
		return Tool.Parent
	end
end

local function GetTorso()
	return GetCharacter() and GetCharacter():FindFirstChild('HumanoidRootPart')
end

local function GetLeftLeg()
	return GetCharacter() and GetCharacter():FindFirstChild('Left Leg')
end

local function GetRightLeg()
	return GetCharacter() and GetCharacter():FindFirstChild('Right Leg')
end

local function GetPlayer()
	return PlayersService:GetPlayerFromCharacter(Tool.Parent)
end

local function GetLA()
	return GetCharacter() and GetCharacter():FindFirstChild('Left Arm')
end

local function GetRA()
	return GetCharacter() and GetCharacter():FindFirstChild('Right Arm')
end

local NormalIdToSurfaceId =
{
	[Enum.NormalId.Back] = 'BackSurface';
	[Enum.NormalId.Front] = 'FrontSurface';
	[Enum.NormalId.Left] = 'LeftSurface';
	[Enum.NormalId.Right] = 'RightSurface';
	[Enum.NormalId.Top] = 'TopSurface';
	[Enum.NormalId.Bottom] = 'BottomSurface';
}

local function ClassifySurface(part, point)
	local psize = part.Size
	local localPoint = part.CFrame:pointToObjectSpace(point)
	local posDiff = psize/2 - localPoint
	local negDiff = psize/2 + localPoint
	local minDiff = Vector3.new(
			math.min(math.abs(posDiff.x), math.abs(negDiff.x)),
			math.min(math.abs(posDiff.y), math.abs(negDiff.y)),
			math.min(math.abs(posDiff.z), math.abs(negDiff.z)))
		 
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


local function GetNormal(part, point)
	local normal = ClassifySurface(part, point)
	return ((part.CFrame-part.CFrame.p)*Vector3.FromNormalId(normal))
end

local function AngleFromFlat(vec1)
	local vec1 = vec1.unit
	local flatVec = (vec1 * Vector3.new(1,0,1)).unit
	local angle = math.acos(vec1:Dot(flatVec))
	-- if the angle is nan then assume flat surface
	if angle ~= angle then
		return math.rad(90)
	end
	return math.rad(90) - angle
end

------ RAYCASTING FUNCTIONS ---------

-- Defaulted ray ignore check if none specified
local function RayIgnoreCheck(hit, pos)
	return false
end

local function RayIgnoreCamera(hit, pos)
	if hit then
		if hit.CanCollide == false then return true end
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
local function RayCast(startPos, vec, rayLength, ignoreFunc, ignoreList)
	ignoreFunc = ignoreFunc or RayIgnoreCheck
	ignoreList = ignoreList or {GetCharacter()}
	vec = vec.unit
	local ray = Ray.new(startPos, vec*rayLength)
	local hitObject, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
	if hitObject and hitPos then
		if ignoreFunc(hitObject, hitPos) then
			table.insert(ignoreList, hitObject)
			return RayCast(startPos, vec, rayLength, ignoreFunc, ignoreList)
		end
	end
	return hitObject, hitPos
end

------ END RAYCASTING FUNCTIONS ---------


local function GetGroundBelowCharacter(character)
	local torso = GetTorso(character)
	local leftLeg = GetLeftLeg()
	if torso and leftLeg then
		local torsoCFrame = torso.CFrame
		local hitData = {}
		for z = -1, 1, 2 do
			for x = -1, 1, 2 do
				local hit, pos = RayCast(
					torsoCFrame.p + torsoCFrame:vectorToWorldSpace(Vector3.new(torso.Size.X/2*x,0,torso.Size.Z/2*z)),
					Vector3.new(0,-1,0),
					torso.Size.Y/2 + leftLeg.Size.Y + 6, 
					RayIgnoreCamera)
				if hit and pos then
					table.insert(hitData, {['Pos'] = CFrame.new(Vector3.new(torsoCFrame.p.X, pos.Y + 3, torsoCFrame.p.Z)), ['Part'] = hit})
				end
			end
		end
		table.sort(hitData, function(a,b) return a['Pos'].p.Y > b['Pos'].p.Y end)
		if #hitData > 0 then
			return hitData[1]['Pos'], hitData[1]['Part']
		end
		return torsoCFrame, nil
	end
end


local function StudsPerSToMetersPerS(studs)
	return studs / 2
end

local function MetersPerSToStudsPerS(meters)
	return meters * 2.5
end

local LastUpdate = nil
local State = "Stopped"
local LastStateTime = tick()
--[[
Cd*Ap = 0.11 for an upright body, minimal frontal area
Cd*Ap = 0.84 for a horizontal body, maximal frontal area
Cd*Ap = 0.46 for a body in tuck position
--]]
-- http://www.math.utah.edu/~eyre/rsbfaq/physics.html
local function UpdateCharacter()
	local now = tick()
	if LastUpdate == nil then
		LastUpdate = now
		return
	end
	local char = GetCharacter()
	local torso = char and char:FindFirstChild('Torso')
	if char and torso then
		local groundHit, groundPart = GetGroundBelowCharacter(char)
		if groundHit and groundPart then
			local normal = GetNormal(groundPart, groundHit.p)
			-- orient you so you are standing on the surface
			if BodyGyro then
				if normal:Dot(Vector3.new(0,1,0)) < 0.7 then -- we would trip here so abort
					BodyGyro.cframe = CFrame.new()
				else
					local newCFrame = CFrame.new(Vector3.new(), normal) * CFrame.Angles(-math.pi/2,0,0)
					BodyGyro.cframe = newCFrame
				end
			end
			local theta = AngleFromFlat(normal) --[[ Angle of slope --]]
			local deltaTime = now - LastUpdate
			-- on flat, if speed is slow need to push
			if normal.unit:Dot(Vector3.new(0,1,0)) > 0.9 and BodyVelocity.velocity.magnitude < 22 then
				-- use poles!
				if State ~= "Poles" and tick() - LastStateTime > 0.5 then
					print'Poles State engage'
					TuckTrack:Stop()
					SwingTrack:Play()
					State = "Poles"
					LastStateTime = tick()
				end
				local skiOrientation = (torso.CFrame.lookVector * Vector3.new(1,0,1)).unit
				if BodyVelocity then
					BodyVelocity.maxForce = Vector3.new(100000000, 0, 10000000)
					if math.abs(math.acos(skiOrientation:Dot(BodyVelocity.velocity.unit))) > math.pi/3 then
						BodyVelocity.velocity = BodyVelocity.velocity * (1 - 0.55 * deltaTime)
					end
					BodyVelocity.velocity = (BodyVelocity.velocity + (skiOrientation * 19 * deltaTime))
				end
			else -- on the slope
				if State ~= "Tuck" and tick() - LastStateTime > 0.5 and (State ~= "Poles" or BodyVelocity.velocity.magnitude > 24) then
					print'Tuck State engage'
					SwingTrack:Stop()
					TuckTrack:Play()
					State = "Tuck"
					LastStateTime = tick()
				end

				local mu = KineticSkiSnow --[[ dynamic coeff of snow --]]
				local g = 9.81 --[[ gravity --]]
				local CdAp = 0.65 --[[ Drag coeff with frontal area --]]
				--[[ Density of air, http://en.wikipedia.org/wiki/Density_of_air --]]
				local rho = 1.3413 --[[ kg*m^3 --]]
				local V = StudsPerSToMetersPerS(torso.Velocity).magnitude --[[ current velocity --]]
				local m = 65  --[[ mass --]]
				
				local downhillVec = Vector3.new(0,1,0):Cross(normal):Cross(normal)
				
				local skiOrientation = (torso.CFrame.lookVector * Vector3.new(1,0,1)).unit
				local angleBetweenLookAndHill = math.acos((downhillVec * Vector3.new(1,0,1)).unit:Dot(skiOrientation))
				if math.abs(angleBetweenLookAndHill) > math.rad(90) then -- if we are pointed uphill, flip direction
					skiOrientation = skiOrientation * -1
					angleBetweenLookAndHill = math.acos((downhillVec * Vector3.new(1,0,1)).unit:Dot(skiOrientation))
				end
				
				local accel = g*math.sin(theta) - mu*g*math.cos(theta) - (CdAp*rho*(V*V))/(2*m)
				if BodyVelocity then
					BodyVelocity.maxForce = Vector3.new(100000000, 0, 10000000)
					if math.abs(math.acos(skiOrientation:Dot(BodyVelocity.velocity.unit))) > math.pi/3 then
						BodyVelocity.velocity = BodyVelocity.velocity * (1 - 0.55 * deltaTime)
					end
					BodyVelocity.velocity = (BodyVelocity.velocity + ((skiOrientation + Vector3.new(0,0.0001,0)).unit * accel) * deltaTime) 
				end
			end
			
			
			LastUpdate = now
		else
			--[[
			if State ~= "Falling" and tick() - LastStateTime > 0.5 then
				SwingTrack:Stop()
				TuckTrack:Play()
				State = "Falling"
				LastStateTime = tick()
			end
			--]]
			if BodyGyro then
				BodyGyro.cframe = CFrame.new()
			end
			if BodyVelocity then
				--BodyVelocity.maxForce = Vector3.new()
			end
		end

	end
end

local function CreateSkis(leftLeg, rightLeg, leftArm, rightArm)
	DestroySkis()
	local leftSki = New'Part'
	{
		Name = 'LeftSki';
		FormFactor = 'Custom';
		Size = Vector3.new(0.7, 0.2, 5.5);
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		CanCollide = false;
		New'SpecialMesh'
		{
			TextureId = GetAssetUrl(SKI_TX2);
			MeshId = GetAssetUrl(SKI_MESH);
			Scale = Vector3.new(3,3,3);
		}
	}
	local rightSki = leftSki:Clone()
	rightSki.Name = 'RightSki';

	Skis['left'] = leftSki
	Skis['right'] = rightSki
	--Skis['left'].CFrame = CFrame.new(0, 10, 0);
	--Skis['right'].CFrame = CFrame.new(3, 10, 0);
	
	local leftLegWeld = New'ManualWeld'
	{
		Name = 'LeftSkiWeld';
		Part0 = leftLeg;
		Part1 = leftSki;
		C0 = CFrame.new(0,-leftLeg.Size.Y/2 + 0.1,-0.5);
		Parent = leftSki;
	}
	local rightLegWeld = New'ManualWeld'
	{
		Name = 'RightSkiWeld';
		Part0 = rightLeg;
		Part1 = rightSki;
		C0 = CFrame.new(0,-rightLeg.Size.Y/2 + 0.1,-0.5);
		Parent = rightSki;
	}
	
	local leftPole = New'Part'
	{
		Name = 'LeftPole';
		FormFactor = 'Custom';
		Size = Vector3.new(0.3, 0.3, 4);
		TopSurface = 'Smooth';
		BottomSurface = 'Smooth';
		CanCollide = false;
		New'SpecialMesh'
		{
			TextureId = GetAssetUrl(SKI_TX2);
			MeshId = GetAssetUrl(POLE_MESH);
			Scale = Vector3.new(3,3,3);
		}
	}
	local rightPole = leftPole:Clone()
	rightPole.Name = 'RightPole';

	Skis['leftPole'] = leftPole
	Skis['rightPole'] = rightPole
	
	local leftArmWeld = New'ManualWeld'
	{
		Name = 'LeftArmWeld';
		Part0 = leftArm;
		Part1 = leftPole;
		C0 = CFrame.new(0,-leftArm.Size.Y/2 + 0.1,1.8);-- * CFrame.Angles(math.pi,0,0);
		Parent = leftPole;
	}
	local rightArmWeld = New'ManualWeld'
	{
		Name = 'RightArmWeld';
		Part0 = rightArm;
		Part1 = rightPole;
		C0 = CFrame.new(0,-rightArm.Size.Y/2 + 0.1,1.8);-- * CFrame.Angles(math.pi,0,0);
		Parent = rightSki;
	}
	
	Skis['left'].Parent = GetCharacter()
	Skis['right'].Parent = GetCharacter()
	Skis['leftPole'].Parent = GetCharacter()
	Skis['rightPole'].Parent = GetCharacter()
end

function DestroySkis()
	for key, ski in pairs(Skis) do
		ski:Destroy()
		Skis[key] = nil
	end
end

function OnTouched(hitPart)
	
end

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	Tool.Enabled = true
end

function ControlLoop()
	UpdateCharacter()
end

local Equipped = false

function OnEquipped(mouse)
	Equipped = true
	Character, Torso, LeftLeg, RightLeg = GetCharacter(), GetTorso(), GetLeftLeg(), GetRightLeg()
	LeftArm, RightArm = GetLA(), GetRA()
	if LeftLeg and RightLeg then
		-- Spawn because welds
		Spawn(function()
			CreateSkis(LeftLeg, RightLeg, LeftArm, RightArm)
			BodyGyro = Instance.new('BodyGyro')
			BodyGyro.Parent = Torso
			BodyVelocity = Instance.new('BodyVelocity')
			BodyVelocity.maxForce = Vector3.new(100000000, 0, 10000000)
			BodyVelocity.velocity = Vector3.new()
			BodyVelocity.Parent = Torso
		end)
	end
	LastUpdate = nil
	local co = coroutine.create(function() while Equipped do ControlLoop() wait() end end)
	coroutine.resume(co)
	local humanoid = Character:WaitForChild('Humanoid')
	SwingTrack = humanoid:LoadAnimation(SKI_SWING_ANIM)
	TuckTrack = humanoid:LoadAnimation(SKI_TUCK_ANIM)
	SwingTrack:Play()
	Handle.Transparency = 1
end

function OnUnequipped()
	Equipped = false
	Character, Torso, LeftLeg, RightLeg = nil, nil, nil, nil
	DestroySkis()
	if BodyVelocity then
		BodyVelocity:Destroy()
		BodyVelocity = nil
	end
	if BodyGyro then
		BodyGyro:Destroy()
		BodyGyro = nil
	end
	if SwingTrack then
		SwingTrack:Stop()
		SwingTrack = nil
	end
	if TuckTrack then
		TuckTrack:Stop()
		TuckTrack = nil
	end
	LastUpdate = nil
	Handle.Transparency = 0
end


Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
