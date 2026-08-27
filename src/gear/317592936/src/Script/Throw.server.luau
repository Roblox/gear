--Made by Luckymaxer

--[[local MaxDistance = 150
local StartPosition = Handle.Position
local Direction = CFrame.new(StartPosition, Vector3.new(TargetPosition.X, StartPosition.Y, TargetPosition.Z))
local SpawnPosition = ((CFrame.new(StartPosition) * CFrame.Angles(Axe.CFrame:toEulerAnglesXYZ())) + Direction.lookVector * Axe.Size.Z * 2)
local Distance = (StartPosition - TargetPosition).Magnitude
if Distance > MaxDistance then
	TargetPosition = (SpawnPosition + Direction.lookVector * MaxDistance)
	Distance = MaxDistance
end
local Velocity = Distance	
local ThrowVelocity = ((Direction.lookVector * Velocity) + Vector3.new(0, (Distance * 1), 0))
--Axe.CFrame = SpawnPosition
Axe.Velocity = ThrowVelocity
--Axe.RotVelocity = Vector3.new((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01))]]

--[[local MaxDistance = 150
local Direction = (TargetPosition - Axe.Position)
local Distance = Direction.Magnitude
if Distance >= MaxDistance then
	Distance = 300
	TargetPosition = (CFrame.new(Axe.Position, TargetPosition).lookVector * Distance)
	Direction = (TargetPosition - Axe.Position)
end
Direction = (Direction - Direction.Unit * 5)
local DeltaXZSquared = (Direction.X * Direction.X + Direction.Z * Direction.Z)
local DeltaXZ = math.sqrt(DeltaXZSquared)
local DeltaY = Direction.Y
local Alpha = (math.random() * math.pi / 4 + math.pi / 8)
local Numerator = (-0.5 * Gravity * DeltaXZSquared)
local Denominator = (math.cos(Alpha) * math.cos(Alpha) * (DeltaY - math.tan(Alpha) * DeltaXZ))
if Denominator == 0 then
	return
end
local Speed = math.sqrt(Numerator / Denominator)
Speed = ((Speed > MaxSpeed and MaxSpeed) or Speed)
local VectorXZ = (Speed * math.cos(Alpha))
local VectorY = (Speed * math.sin(Alpha))
local VectorX = (VectorXZ * Direction.X / DeltaXZ)
local VectorZ = (VectorXZ * Direction.Z / DeltaXZ)
Axe.Velocity = Vector3.new(VectorX, VectorY, VectorZ)]]