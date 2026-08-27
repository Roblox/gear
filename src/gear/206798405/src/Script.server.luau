--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

BaseLaser = BasePart:Clone()
BaseLaser.Name = "Laser"
BaseLaser.BrickColor = BrickColor.new("Really red")
BaseLaser.Material = Enum.Material.CorrodedMetal
BaseLaser.Size = Vector3.new(1, 1, 1)
BaseLaser.CanCollide = false
BaseLaserMesh = Instance.new("CylinderMesh")
BaseLaserMesh.Parent = BaseLaser

ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}

DefaultDistance = 25
MaxDistance = 200

MaxChargeTime = 5
ChargeTick = 0

DefaultCharge = 25
MaxCharge = 100

DefaultSize = 0.25
MaxSize = 1

DefaultDamage = 5
MaxDamage = 20

MaxFireTime = 3

DefaultReloadTime = 1
MaxReloadTime = 5

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Mesh.VertexColor = Vector3.new(1, 1, 1)
Tool.Enabled = true

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
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
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit.Transparency > 0.8 or CheckTableForString(ProjectileNames, Hit.Name) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function PositionPart(cframe, x, y, z)
	local PartCloneY = cframe
	PartCloneY = cframe * CFrame.Angles(-math.rad(90), 0, 0)
	PartCloneY = PartCloneY - PartCloneY.lookVector * y
	local PartCloneZ = PartCloneY + cframe.lookVector * z
	local PartCloneX = PartCloneZ * CFrame.Angles(0, math.rad(90), 0)
	PartCloneX = PartCloneX - PartCloneX.lookVector * x
	return PartCloneX * CFrame.Angles((math.pi / 2), 0, (math.pi / 2))
end

function HandleHit(Hit, Damage, StartPosition, TargetPosition)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		if StartPosition and TargetPosition then
			local FirePart = BasePart:Clone()
			FirePart.Name = "Effect"
			FirePart.Size = Vector3.new(0.2, 0.2, 0.2)
			FirePart.Transparency = 1
			FirePart.CanCollide = false
			FirePart.Anchored = true
			local Fire = Instance.new("Fire")
			Fire.Heat = 3
			Fire.Size = 5
			Fire.Enabled = true
			Fire.Parent = FirePart
			Debris:AddItem(FirePart, 5)
			FirePart.Parent = game:GetService("Workspace")
			FirePart.CFrame = CFrame.new(TargetPosition, StartPosition) * CFrame.Angles(0, (math.pi / 2), 0)
		end
		return
	end
	if humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (not player.Neutral and player.TeamColor == Player.TeamColor) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	if humanoid.Health == 0 then
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("Hat") or v:IsA("Clothing") then
				v:Destroy()
			elseif v:IsA("BasePart") then
				v.BrickColor = BrickColor.new("Really black")
				v.Material = Enum.Material.Slate
				local Smoke = Instance.new("Smoke")
				Smoke.Opacity = 0.25
				Smoke.Size = 0.1
				Smoke.RiseVelocity = 0
				Smoke.Color = BrickColor.new("Really black").Color
				Smoke.Enabled = true
				Smoke.Parent = v
			end
		end
	end
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
	ToolEquipped = false
	MouseDown = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
		if mode == "MouseClick" then
			local Down = value.Down
			if Down and not MouseDown then
				if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then
					return
				end
				MouseDown = true
				ChargeTick = tick()
				while MouseDown and ToolEquipped and CheckIfAlive() do
					if (tick() - ChargeTick) >= MaxChargeTime then
						Mesh.VertexColor = Vector3.new(1, (math.random(0, 50) * 0.01), (math.random(0, 25) * 0.01))
					end
					wait(0.1)
				end
				Mesh.VertexColor = Vector3.new(1, 1, 1)
			elseif not Down and MouseDown then
				MouseDown = false
				
				Tool.Enabled = false
				
				local CurrentCharge = math.abs(tick() - ChargeTick)
				local ChargePercent = Clamp(GetPercentage(0, MaxChargeTime, CurrentCharge), 0, MaxCharge)
				local ChargePercentToDecimal = (ChargePercent * 0.01)
				local ChargeDistance = Clamp((MaxDistance * ChargePercentToDecimal), DefaultDistance, MaxDistance)
				local ActivationTime = (MaxFireTime * ChargePercentToDecimal)
				local ActivationSize = Clamp((MaxSize * ChargePercentToDecimal), DefaultSize, MaxSize)
				local ActivationDamage = Clamp((MaxDamage * ChargePercentToDecimal), DefaultDamage, MaxDamage)
				local ChargeReload = Clamp((MaxReloadTime * ChargePercentToDecimal), DefaultReloadTime, MaxReloadTime)
				local ActivationTick = tick()
				
				local Laser = BaseLaser:Clone()
				local LaserMesh = Laser.Mesh
				LaserMesh.Scale = Vector3.new(0, 0, 0)
				Debris:AddItem(Laser, (ActivationTime + 2))
				Laser.Parent = Handle
				local LaserWeld = Instance.new("Weld")
				LaserWeld.Part0 = Handle
				LaserWeld.Part1 = Laser
				LaserWeld.Parent = Laser
				
				local TempLaser = Laser:Clone()
				local TempLaserMesh = TempLaser.Mesh
				local TempLaserWeld = Instance.new("Weld")
				TempLaserWeld.Part0 = Handle
				TempLaserWeld.Part1 = TempLaser
				TempLaserWeld.Parent = TempLaser
				TempLaser.Parent = Laser
				
				while (tick() - ActivationTick) < ActivationTime and CheckIfAlive() and ToolEquipped and (Laser and Laser.Parent) do
					local TickTime = (tick() - ActivationTick)
					local ChargePercentage = GetPercentage(0, ActivationTime, (ActivationTime - TickTime))
					local ChargePercentageToDecimal = (ChargePercentage * 0.01)
					local ChargeSize = (ActivationSize * ChargePercentageToDecimal)
					local ChargeDamage = Clamp((ActivationDamage * ChargePercentageToDecimal), DefaultDamage, MaxDamage)
					local ChargeTransparency = (1 - ChargePercentageToDecimal)
					
					local StartPosition = PositionPart(Handle.CFrame, 0.25, -(Handle.Size.Y / 2), 0)
					local TargetPosition = InvokeClient("MousePosition")
					local Direction = CFrame.new(StartPosition.p, TargetPosition).lookVector
					
					local TotalDistance = 0
					
					local RayHit, RayPos, RayNormal = CastRay(StartPosition.p, Direction, ChargeDistance, {Character}, false)
					TotalDistance = (TotalDistance + (StartPosition.p - RayPos).magnitude)
					
					if RayHit then
						if TotalDistance < ChargeDistance and RayHit.Reflectance >= 0.5 then
							HandleHit(RayHit, ChargeDamage)
							local ReflectedDirection = (Direction - 2 * Direction:Dot(RayNormal) * RayNormal)
							local RayHit2, RayPos2, RayNormal2 = CastRay(RayPos, ReflectedDirection, (ChargeDistance - TotalDistance), {Character}, false)
							if RayHit2 then
								HandleHit(RayHit2, ChargeDamage, RayPos, RayPos2)
							end
							local TempDistance = (RayPos - RayPos2).magnitude
							TotalDistance = (TotalDistance + TempDistance)
							local Vec = (RayPos - RayPos2)
							local Pos = (CFrame.new(RayPos) * CFrame.new(0, 0, 0)).p
							local NewCFrame = CFrame.new(Pos, (Pos + Vec))
							TempLaserWeld.C0 = Handle.CFrame:toObjectSpace(NewCFrame) * CFrame.new(0, 0, (TempDistance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
							TempLaserWeld.C1 = CFrame.new(0, 0, 0)
							TempLaser.Transparency = Laser.Transparency
							TempLaserMesh.Scale = Vector3.new(ChargeSize, TempDistance, ChargeSize)
						else
							if ChargeTransparency < 0.75 then
								HandleHit(RayHit, ChargeDamage, StartPosition.p, RayPos)
							else
								HandleHit(RayHit, ChargeDamage)
							end
							TempLaser.Transparency = 1
							LaserMesh.Scale = Vector3.new(0, 0, 0)
						end
					end
					
					local Distance = (StartPosition.p - RayPos).magnitude
					local Vec = (StartPosition.p - RayPos)
					local Pos = (StartPosition * CFrame.new(0, 0, 0)).p
					local NewCFrame = CFrame.new(Pos, (Pos + Vec))
					LaserWeld.C0 = Handle.CFrame:toObjectSpace(NewCFrame) * CFrame.new(0, 0, (Distance / 2)) * CFrame.Angles((math.pi / 2), 0, 0)
					LaserWeld.C1 = CFrame.new(0, 0, 0)
					LaserMesh.Scale = Vector3.new(ChargeSize, Distance, ChargeSize)
					Laser.Transparency = ChargeTransparency
					wait(0.01)
				end
				if Laser and Laser.Parent then
					Laser:Destroy()
				end
				
				wait(ChargeReload)
				
				Tool.Enabled = true
			end
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

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)