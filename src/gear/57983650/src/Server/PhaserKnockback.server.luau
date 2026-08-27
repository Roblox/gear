vChar = script.Parent

r = game:GetService("RunService")

myTorso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")
myHumanoid = vChar:FindFirstChildOfClass("Humanoid")

blastAOE = Vector3.new(7, 7, 7)

gunChar = script:FindFirstChild("GunChar")

if myTorso then 	
	newBV = Instance.new("BodyVelocity")
	newBV.Name = "BlastBV"
	newBV.P = 100000
	newBV.MaxForce = Vector3.new(newBV.P, newBV.P, newBV.P)
	distance = (myTorso.Position - script.Pos.Value).Magnitude	
	if distance < 15.0 then newBV.Velocity = (myTorso.Position - script.Pos.Value).Unit * 50.0
	else newBV.Velocity = (myTorso.Position - script.Pos.Value).Unit * 900.0 * 1/distance end
	newBV.Parent = myTorso

	newBAV = Instance.new("BodyAngularVelocity")
	newBAV.Name = "BlastBAV"
	newBAV.P = 100000
	math.randomseed(1234)
	newBAV.AngularVelocity = Vector3.new(math.random(6, 10), math.random(6, 10), math.random(6, 10))
	newBAV.Parent = myTorso	

	myHumanoid.Sit = true

	parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - blastAOE, myTorso.Position + blastAOE), vChar, 100)
	for i = 1, #parts do 
		tempChar = parts[i].Parent
		tempTorso = tempChar:FindFirstChild("Torso") or tempChar:FindFirstChild("UpperTorso")
		if tempTorso and tempChar ~= gunChar.Value then 
			bv = tempTorso:FindFirstChild("BlastBV")
			bav = tempTorso:FindFirstChild("BlastBAV")
			if not bv and not bav then
				newBV = Instance.new("BodyVelocity")
				newBV.Name = "BlastBV"
				newBV.P = 100000
				newBV.maxForce = Vector3.new(newBV.P, newBV.P, newBV.P)
				if distance < 15.0 then newBV.Velocity = (myTorso.Position - script.Pos.Value).Unit * 50.0
				else newBV.Velocity = (myTorso.Position - script.Pos.Value).Unit * 900.0 * 1/distance end
				newBV.Parent = tempTorso

				newBAV = Instance.new("BodyAngularVelocity")
				newBAV.Name = "BlastBAV"
				newBAV.P = 100000
				tick()
				math.randomseed(4567)
				newBAV.angularvelocity = Vector3.new(math.random(3, 6), math.random(3,6), math.random(3,6))
				newBAV.Parent = tempTorso				
			end
		end	
	end
	wait(1.5)
	for i = 1, #parts do 
		BV = parts[i]:FindFirstChild("BlastBV")
		BAV = parts[i]:FindFirstChild("BlastBAV")
		if BV then BV:Destroy() end
		if BAV then BAV:Destroy() end
	end	
	bv = myTorso:FindFirstChild("BlastBV")
	bav = myTorso:FindFirstChild("BlastBAV")
	if bv then bv:Destroy() end
	if bav then bav:Destroy() end
end

wait(1.0)
script:Destroy()
				
			