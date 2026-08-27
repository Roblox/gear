local user
local tool = script.Parent
local handle = tool:WaitForChild('Handle')
local arrow = tool:WaitForChild('Arrow')
local equipped = false

function MakeJoint(name, part0, part1, c0, c1)
	local c0 = c0 or CFrame.new()
	local c1 = c1 or CFrame.new()
	local motor = Instance.new('Motor6D')
	motor.Name = name
	motor.Parent = part0
	motor.Part0 = part0
	motor.Part1 = part1
	motor.C0 = c0
	motor.C1 = c1
	motor.MaxVelocity = 0.1
	return motor
end

function findNearestNormalEgg()
	local minDistance = math.huge
	local closestEgg = nil
	for _, egg in pairs(workspace:WaitForChild('SpawnedEggs'):GetChildren()) do
		if egg.Respawn.Value < 1800 then
			local eggDistance = (egg:GetModelCFrame().p - handle.Position).magnitude
			if  eggDistance < minDistance then
				minDistance = eggDistance
				closestEgg = egg
			end
		end
	end
	return closestEgg
end

local joint = handle.motor


tool.Equipped:connect(function ()
	user = tool.Parent
		
	equipped = true	
	
	while equipped do
		local target = findNearestNormalEgg()
		if target then
			local targetVector = ((target:GetModelCFrame().p-arrow.Position)*Vector3.new(1,0,1)).unit
			local arrowVector = (arrow.CFrame.lookVector*Vector3.new(1,0,1)).unit
			local distanceVector = arrowVector-targetVector
			if arrowVector.x < 0 then distanceVector = targetVector-arrowVector end
			local distance = distanceVector.magnitude
			
			
			if distanceVector.z < 0 then
				joint.DesiredAngle = joint.CurrentAngle + 2*math.asin(distance/2)
				if joint.CurrentAngle > 4*math.pi then
					joint.CurrentAngle = 0
				end
			elseif distanceVector.z > 0 then
				joint.DesiredAngle = joint.CurrentAngle - 2*math.asin(distance/2)
				if joint.CurrentAngle < -4*math.pi then
					joint.CurrentAngle = 0
				end
			end


--			print('target ', targetVector.x, targetVector.z)
--			print('arrow ', arrowVector.x, arrowVector.z)
--			print(distanceVector.x ,distanceVector.z )
--			print()

		end
		wait(1)
	end
end)

tool.Unequipped:connect(function ()
	equipped = false
end)

arrow.Transparency=0

