--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Seat = Model:WaitForChild("Seat")

Base = Model:WaitForChild("Base")

Wheel = Model:WaitForChild("Wheel")
WheelMotor = Wheel:WaitForChild("Motor")

AttachmentWeld = Model:FindFirstChild("AttachmentWeld")
Tool = Model:FindFirstChild("Tool")

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)) or Number)
end

function Sign(x)
	return (x > 0 and 1 or x < 0 and -1 or 0)
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

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal, RayMaterial = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal, RayMaterial = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal, RayMaterial
end

function CleanUp()
	if CleaningUp then
		return
	end
	CleaningUp = true
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			if v.Transparency < 0.5 then
				v.Transparency = 0.5
			end
			if v:IsA("Seat") or v:IsA("VehicleSeat") then
				v.Disabled = true
			end
			v:BreakJoints()
		end
	end
	Debris:AddItem(Model, 1)
end

function CheckIfDetached()
	return (((not Tool or not Tool.Value or not Tool.Value.Parent or not AttachmentWeld or not AttachmentWeld.Parent or not AttachmentWeld.Part0 or not AttachmentWeld.Part0.Parent or not AttachmentWeld.Part1 or not AttachmentWeld.Part1.Parent) and true) or false)
end

function Animate()
	if CheckIfDetached() then
		CleanUp()
		return
	end
	local WheelSpeed = {Min = 0, Max = 10}
	local Velocity = ((Wheel.Velocity * Vector3.new(1, 0, 1)))
	local WheelVelocity = (Clamp(GetPercentage(0, 30, Velocity.Magnitude), 0, 100) * 0.01)
	local RotationSpeed = Clamp((WheelSpeed.Max * WheelVelocity), WheelSpeed.Min, WheelSpeed.Max)
	local StartPoint = (Base.CFrame + Base.CFrame.lookVector * (Base.Size.Z / 2))
	local EndPoint = (StartPoint + Velocity.Unit * Velocity.Magnitude)
	local MoveDirection = Clamp(((StartPoint.p - EndPoint.p).Unit + EndPoint.lookVector).Magnitude, 0, 2)
	local Direction = ((MoveDirection < 1 and 1) or -1)
	local RayHit, RayPos, RayNormal, RayMaterial = CastRay(Wheel.Position, Vector3.new(0, -1, 0), 3, {Model}, false)
	if RayHit then
		WheelMotor.MaxVelocity = math.abs(RotationSpeed * 0.01)
		WheelMotor.DesiredAngle = (99999999 * Direction)
	else
		WheelMotor.MaxVelocity = 0
	end
end

function Seated(Child)
	if not Child:IsA("Weld") or not Child.Name == "SeatWeld" then
		return
	end
	if Child.Part0 ~= Seat or not Child.Part1 or not Child.Part1.Parent then
		return
	end
	Child.C1 = (Child.C1 * CFrame.new(0, 0.75, 0))
end

if CheckIfDetached() then
	CleanUp()
	return
end

RunService.Stepped:connect(Animate)

Seat.ChildAdded:connect(Seated)