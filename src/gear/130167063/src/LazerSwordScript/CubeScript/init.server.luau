local AxisVectors =
{	
}
do
	for val = -1, 1, 2 do
		table.insert(AxisVectors, Vector3.new(val, 0, 0))
	end
	for val = -1, 1, 2 do
		table.insert(AxisVectors, Vector3.new(0, val, 0))
	end
	for val = -1, 1, 2 do
		table.insert(AxisVectors, Vector3.new(0, 0, val))
	end
end

local TangentVectors = {}

do
	for i = 1, #AxisVectors do
		TangentVectors[AxisVectors[i]] = {}
		for ii = 1, #AxisVectors do
			if AxisVectors[i]:Dot(AxisVectors[ii]) == 0 then
				table.insert(TangentVectors[AxisVectors[i]], AxisVectors[ii])
			end
		end
	end	
end

function GetRandomAxisVector()
	return AxisVectors[math.random(1, #AxisVectors)]
end

function GetRandomTangentVector(vec)
	if not TangentVectors[vec] then
		dPrint("GetRandomTangentVector: Error - No Vec found for" , vec)
		return Vector3.new()
	end
	return TangentVectors[vec][math.random(1, #TangentVectors[vec])]
end

function GetRandomFloat(low, high)
	assert(low < high, "GetRandomFloat: Low is larger than high.")
	local rand = math.random()
	rand = rand * (high - low)
	return (rand + low)
end

local CUBE_VELOCITY = 65
local SHIFT_TIME = 0.4
local DAMAGE = 100;

local DebrisService = Game:GetService('Debris')
local Owner = script:WaitForChild('Owner')
local Cube = script.Parent
local touchConn
function NukeChildren(obj)
	for _, child in pairs(obj:GetChildren()) do
		child:Destroy()
	end
end


function FindCharacterAncestor(part)
	if part and part ~= Workspace then
		local humanoid = part:FindFirstChild('Humanoid')
		if part:IsA('Model') and humanoid and humanoid:IsA('Humanoid') then
			return part, humanoid
		end
		return FindCharacterAncestor(part.Parent)
	end	
end

local HitHumanoids = {}
function OnTouched(hitPart)
	local hitCharacter, hitHumanoid = FindCharacterAncestor(hitPart)
	if hitCharacter and (not Owner.Value or hitCharacter ~= Owner.Value.Character) and not HitHumanoids[hitHumanoid] then
		hitHumanoid:TakeDamage(DAMAGE)
		HitHumanoids[hitHumanoid] = true
	end
end

function FlyCube(cube)
	local velocity = nil
	for _, vec in pairs(AxisVectors) do
		if vec:isClose(cube.Velocity) then
			velocity = vec
		end
	end
	if not velocity then
		print("Did not find a vec")
		velocity = GetRandomAxisVector()
	end
	for i = 1, math.random(4, 8) do
		if i == 2 then
			touchConn = Cube.Touched:connect(OnTouched)
		end
		if cube then			
			local speedCoeff = GetRandomFloat(0.66, 1.33)
			velocity = GetRandomTangentVector(velocity)
			local endTime = tick() + (SHIFT_TIME * GetRandomFloat(0.45, 1.67))
			while tick() < endTime do
				local copyCube = cube:Clone()
				NukeChildren(copyCube)
				DebrisService:AddItem(copyCube, 1)
				cube.CFrame = cube.CFrame + (velocity * cube.Size.X)				
				copyCube.Parent = Workspace
				if i > 1 then
					copyCube.Touched:connect(OnTouched)
				end
				wait(cube.Size.X / (CUBE_VELOCITY * speedCoeff)) -- wait one cube away
			end
		end
	end

end

FlyCube(Cube)
if touchConn then
	touchConn:disconnect()
	touchConn = nil
end
Cube:Destroy()
