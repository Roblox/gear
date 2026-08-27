local user
local tool = script.Parent
local handle = tool:WaitForChild('Handle')
local arrow = tool:WaitForChild('Arrow')
local equipped = false

function findNearestRareEgg()
	local minDistance = math.huge
	local closestEgg = nil
	for _, egg in pairs(workspace:WaitForChild('SpawnedEggs'):GetChildren()) do
		if egg:FindFirstChild("Respawn") and egg.className=="Model" and egg.Respawn.Value >= 1800 then
			local eggDistance = (egg:GetModelCFrame().p - handle.Position).magnitude
			if  eggDistance < minDistance then
				minDistance = eggDistance
				closestEgg = egg
			end
		end
	end
	return closestEgg
end

tool.Equipped:connect(function ()
	user = tool.Parent
		
	local joint = handle.motor
	equipped = true	
	
	while equipped do
		local target = findNearestRareEgg()
		if target then
			local targetVector = ((target:GetModelCFrame().p-arrow.Position)*Vector3.new(1,0,1)).unit
			local arrowVector = (arrow.CFrame.lookVector*Vector3.new(1,0,1)).unit
			local distanceVector = arrowVector-targetVector
			if arrowVector.x < 0 then
				distanceVector = targetVector-arrowVector 
			end
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

