ball = script.Parent
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=34376514"
HitSound.Parent = ball
HitSound.Volume = 1

hitPerson = false

function onTouched(hit)
	if hitPerson then return end
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		hitPerson = true
		humanoid:TakeDamage(damage)
		HitSound:Play()

		myPlayer = game.Players:GetPlayerFromCharacter(humanoid.Parent)
		if myPlayer == nil then
			ball.Parent = nil
			return
		end
		cScreen = myPlayer.PlayerGui:FindFirstChild("CakeScreen")
		if (cScreen == nil) then
			-- need to make a new cScreen
			cScreen = script:FindFirstChild("CakeScreen")
			if cScreen == nil then print("CSCREEN NOT CLONEABLE!") end
			cScreen:Clone().Parent = myPlayer.PlayerGui
		end

		cScript = script:FindFirstChild("CakeScript")
		if (cScript == nil) then print("CSCRIPT NOT CLONEABLE!") end
		newCScript = cScript:Clone()
		newCScript.Parent = myPlayer.PlayerGui
		newCScript.Disabled = false
	end

	ball.Parent = nil

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
	--[[if not hitPerson then ball.Parent = nil
	elseif humanoid ~= nil then
		ball.BodyForce.force = Vector3.new(0,ball:GetMass()*196.1643,0)
		ball.Velocity = Vector3.new(0,0,0)
		ball.RotVelocity = Vector3.new(0,0,0)
		--[[bodyPart = nil
		switch = math.random(1,6)
		if switch == 1 then ball.Position = humanoid.Parent.Head.Position end
		if switch == 2 then ball.Position = humanoid.Parent.Torso.Position end
		if switch == 3 then
			bodyPart = humanoid.Parent:findFirstChild("Left Arm")
		end
		if switch == 4 then
			bodyPart = humanoid.Parent:findFirstChild("Right Arm")
		end
		if switch == 5 then
			bodyPart = humanoid.Parent:findFirstChild("Left Leg")
		end
		if switch == 6 then
			bodyPart = humanoid.Parent:findFirstChild("Right Leg")
		end
		if bodyPart ~= nil then
			ball.Position = bodyPart.Position
		end
		print(switch)
		--ball.Position = hit.Position+Vector3.new((math.random()-.5)*2, (math.random()-.5)*2, (math.random()-.5)*2)
		--print(hit)
		]]--]]
		--ball.Position = humanoid.Parent.Head.Position+Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5)
	--end
end

connection = ball.Touched:connect(onTouched)


function isNotCreator(target)
	name_tag = ball:findFirstChild("creator")
	if name_tag == nil then return false end

	--print(target)
	--print(name_tag.Value)

	if (target == name_tag.Value) then return false
	else return true end
end


for i = 1,50 do
	if not hitPerson then
	myPlayers = game.Players:GetPlayers()

	local bestTarget = nil
	local bestDistance = 1000
	
	-- search for closest potential target
	for j = 1, #myPlayers do
		if myPlayers[j] ~= nil then
			if isNotCreator(myPlayers[j]) then
				newDistance = myPlayers[j]:DistanceFromCharacter(ball.Position)
				if newDistance < bestDistance then
					bestDistance = newDistance
					bestTarget = myPlayers[j]
				end
			end
		end
	end

	--if bestTarget ~= nil and ball.Velocity.Y < 0 then
	if bestTarget ~= nil then
		-- home in on this target
		--print("homing")
		dPos = bestTarget.Character.PrimaryPart.Position - ball.Position
		--ball.BodyForce.force = dPos*.01
		--ball.Velocity = Vector3.new(dPos.unit.X*15, 0, dPos.unit.Z*15)

		-- 2D-angle-back-solving-code
		-- A is deltaY, B is (.5*g*deltaX^2)/v^2, and C is deltaX
		-- then our quadratic to be solved is (A^2+C^2)*x^2 + (2AB-C^2)*x + B^2
		-- where x is cos(theta)*cos(theta)

		-- we solve for the optimal angle to be traveling at this speed (given gravity), and then adjust the velocities
		--    to go closer to this optimal angle-based velocity (using a weighted average)

		deltaX = math.sqrt(dPos.X*dPos.X+dPos.Z*dPos.Z)
		vSq = ball.Velocity:Dot(ball.Velocity)
		A = dPos.Y
		B = .5*196.1643*deltaX*deltaX/vSq
		C = deltaX

		qA = A*A+C*C
		qB = 2*A*B - C*C
		qC = B*B

		det = qB*qB - 4*qA*qC
		if qA ~= 0 and det >= 0 then
			xSquaredPlus = (-qB + math.sqrt(det))/(2*qA)
			--xSquaredMinus = (-qB - math.sqrt(det)/(2*qA)
			
			if xSquaredPlus > 0 then
				newCosX = math.sqrt(xSquaredPlus)
				--newAlpha = math.acos(newX)
				newSinX = (1 - newCosX*newCosX)
				if newSinX >= 0 then
					v = math.sqrt(vSq)
					newSinX = math.sqrt(newSinX)

					if (dPos.Y + B/(newCosX*newCosX)) < 0 then newSinX = -newSinX end

					vXZ = v * newCosX
					vY = v * newSinX
					vX = vXZ * dPos.X / deltaX
					vZ = vXZ * dPos.Z / deltaX
					--ball.Velocity = Vector3.new(vX, vY, vZ)
					ball.Velocity = Vector3.new(ball.Velocity.X*.7+vX*.3, ball.Velocity.Y*.7+vY*.3, ball.Velocity.Z*.7+vZ*.3)
				end
			end
		end
	end
	wait(.05)
	end
end
--ball.SparkSound.Looped = false
--ball.SparkSound:Stop()
if hitPerson then wait(5) end
ball.Parent = nil