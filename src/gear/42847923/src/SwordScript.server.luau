local bigCount = 0

local Tool = script.Parent
local sword = script.Parent.Handle

local waitTime = 0.05
local maxDamage = 7
local damage = 0

local debris = game:GetService("Debris")

local maxNumClones = 6
local numClones = maxNumClones

Tool.Enabled = true
equipped = false

local mySwords = {}
local iceblox = {}
local swordConnections = {}

for i = 1, numClones do
	local newSword = Tool.Handle:Clone()
	newSword.Transparency = (numClones-i+1)/(numClones+1)
	--newSword.Mesh.VertexColor = Vector3.new((i+numClones)/(2*numClones+1), (i+numClones)/(2*numClones+1), 1)
	newSword.Mesh.VertexColor = Vector3.new((i+numClones)/(2*numClones+1), (i+2*numClones)/(3*numClones+1), 1)
	newSword.Anchored = false
	newSword.CanCollide = false
	swordConn = newSword.Touched:connect(function (hit) 
										blow(hit, 1-newSword.Transparency)
									end)
	table.insert(swordConnections, swordConn)

	local newBodyPos = Instance.new("BodyPosition")
	newBodyPos.Name = "SwordPos"
	newBodyPos.P = 10000
	newBodyPos.maxForce = Vector3.new(newBodyPos.P, newBodyPos.P, newBodyPos.P)
	newBodyPos.Parent = newSword

	local newBodyGyro = Instance.new("BodyGyro")
	newBodyGyro.Name = "SwordGyro"
	newBodyGyro.P = 10000
	newBodyGyro.maxTorque = Vector3.new(newBodyGyro.P, newBodyGyro.P, newBodyGyro.P)
	newBodyGyro.Parent = newSword

	table.insert(mySwords, newSword)
end


function blow(hit, swordOpacity)
	if swordOpacity == nil then swordOpacity = 0 end
	if hit == nil then return end
	if hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter.Name == "Backpack" then return end
	--local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		-- final check, make sure sword is in-hand
		local right_arm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				--humanoid:TakeDamage(damage)
				humanoid:TakeDamage(damage*swordOpacity)
				wait(1)
				untagHumanoid(humanoid)
			end
		end
	end
end

--function blow(hit, swordOpacity)
--	if swordOpacity ~= nil and swordOpacity < 1 and swordOpacity > 0 then
--	print(bigCount)
--	bigCount = bigCount + 1
--[[
	if swordOpacity == nil then swordOpacity = 0 end
	if swordOpacity < 1 and swordOpacity > 0 then print("A1") end
	if hit == nil then return end
	if hit.Parent == nil then return end
			if swordOpacity < 1 and swordOpacity > 0 then print("A2") end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter.Name == "Backpack" then return end
			if swordOpacity < 1 and swordOpacity > 0 then print("A3") end
	--local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		-- final check, make sure sword is in-hand
		if swordOpacity < 1 and swordOpacity > 0 then print("B") end
		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				if swordOpacity < 1 and swordOpacity > 0 then print("C") end
				tagHumanoid(humanoid, vPlayer)
				--humanoid:TakeDamage(damage)
				if swordOpacity < 1 and swordOpacity > 0 then print("YAYYY!") end
				if swordOpacity < 1 then humanoid:TakeDamage(damage*swordOpacity) end
				wait(1)
				untagHumanoid(humanoid)
			end
		end

	end  --]]
--	end
--end

function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end




local canEquip = true
function onEquipped()
	if not canEquip then return end
	canEquip = false
	Tool.Handle.Transparency = 1

	Tool.Handle.DrinkSound:Play()

	local snowStars = {}

	for k = 1, 5 do
		local snowStar = Tool.Snowstar:Clone()
		snowStar.Anchored = false
		snowStar.CFrame = Tool.Handle.CFrame
		snowStar.Transparency = 0

	--local starWeld = Instance.new("Weld")
	--starWeld.Part0 = snowStar
	--starWeld.Part1 = Tool.Handle
	--starWeld.C1 = Tool.Handle.CFrame

		snowStar.RotVelocity = Vector3.new(math.random(-20,20), math.random(-20,20), math.random(-20, 20))
		newBP = Instance.new("BodyPosition")
		newBP.Name = "StarPos"
		newBP.P = 10000
		newBP.maxForce = Vector3.new(newBP.P, newBP.P, newBP.P)
		newBP.position = Tool.Handle.Position
		newBP.Parent = snowStar
		snowStar.Parent = workspace
		table.insert(snowStars, snowStar)
	end

	iceblox = {}
	for i = 1, 20 do
		local iceblock = Instance.new("Part")
		iceblock.Size = Vector3.new(.05,.05,.05)
		iceblock.BrickColor = BrickColor.new("Institutional white")
		iceblock.BottomSurface = "Smooth"
		iceblock.TopSurface = "Smooth"
		iceblock.Material = "Concrete"

		local iceweld = Instance.new("Weld")
		iceweld.Part0 = iceblock
		iceweld.Part1 = Tool.Handle
		iceweld.C1 = CFrame.Angles(math.random()*math.pi, math.random()*math.pi, math.random()*math.pi) + Vector3.new(0, 0, 1.8-i*.2)
		iceweld.Parent = iceblock
	
		iceblock.Parent = Tool
		table.insert(iceblox, iceblock)

		--snowStar.StarPos.position = Tool.Handle.Position + Vector3.new(3,0,0)*math.sin(i*3*math.pi/10) + Vector3.new(0,0,3)*math.cos(i*3*math.pi/10)
		for k = 1, #snowStars do
			snowStars[k].StarPos.position = Tool.Handle.Position + Vector3.new(3,0,0)*math.sin(i*3*math.pi/10+k*.5) + Vector3.new(0, i*.15-1.2, 0) + Vector3.new(0,0,3)*math.cos(i*3*math.pi/10+k*.5)
		end

		wait(.1)
	end

	for k = 1, #snowStars do
		snowStars[k]:Destroy()
	end

	wait(1)

	if #iceblox > 1 and iceblox[1].Transparency < 1 and iceblox[#iceblox].Transparency < 1 then equipped = true damage = maxDamage end
	for i = 1, #iceblox, 2 do
		local count = 5

		if equipped then
	
		if i == 1 then Tool.Handle.ExplodeSound:Play() end

		for i=1,count do
			local p = Instance.new("Part")
			p.BrickColor = BrickColor.new("White")
			p.formFactor = 2
			p.Size = Vector3.new(1,.4,1)
			--p.Material = Enum.Material.Ice
			p.Material = "Concrete"
			p.TopSurface = 0
			p.BottomSurface = 0
			p.CanCollide = false
			
			--p.Velocity = iceblox[i].Velocity * (4 + (math.random() *2))
			--p.RotVelocity = Vector3.new(math.random(-20,20), math.random(-20,20), math.random(-20,20))
			--p.Position = iceblox[i].Position + (iceblox[i].Velocity * math.random() * .05) + Vector3.new(0,math.random() * 3, 0)
			p.Velocity = iceblox[i].Velocity * math.random() + Vector3.new(50*(math.random()-.5), math.random()*20, 50*(math.random()-.5))
			p.RotVelocity = Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
			p.Position = iceblox[i].Position + (iceblox[i].Velocity * math.random() * .05) + Vector3.new(0,math.random(), 0)
			p.Parent = workspace
	
			debris:AddItem(p, 10)
		end
		end

		iceblox[i]:Destroy()
		if i+1 <= #iceblox then iceblox[i+1]:Destroy() end

	end

	Tool.Handle.Transparency = 0
	canEquip = true
end

function onUnequipped()
	Tool.Handle.Transparency = 1

	damage = 0

	numClones = maxNumClones

	for i = 1, #iceblox do
		if iceblox[i] ~= nil and iceblox[i].Parent ~= nil then iceblox[i].Transparency = 1 end
	end

	for i = 1, #mySwords do
		--mySwords[i].Parent = nil
		mySwords[i].Parent = game.Lighting
	end

	equipped = false
end

function onActivated()
	if not Tool.Enabled or not equipped then
		return
	end

	Tool.Enabled = false

	--Tool.Handle.DrinkSound:Play()

	--wait(1)

	for k = 1, #swordConnections do
		swordConnections[k]:disconnect()
		swordConnections[k] = mySwords[k].Touched:connect(function(hit) blow(hit, 1-mySwords[k].Transparency) end)
	end


	-- use a ring array, for efficiency, so need a counter to keep track of current index
	local index = 1

	-- start out at current sword's CFrame
	local swordFrames = {}
	for i = 1, numClones do
		table.insert(swordFrames, Tool.Handle.CFrame)
		mySwords[i].CFrame = Tool.Handle.CFrame
		--mySwords[i].Parent = workspace
		mySwords[i].Parent = Tool.Parent
	end
	
	local numSteps = 5 / waitTime
	for i = 1, numSteps do -- 5 seconds of sword ghosting/strobing
		for j = 1, numClones do
			--mySwords[j].CFrame = swordFrames[index]
			if swordFrames[index] ~= nil then
				mySwords[j].SwordGyro.cframe = swordFrames[index]
				mySwords[j].SwordPos.position = swordFrames[index].p
			end
			index = index + 1
			if index > numClones then index = 1 end
		end
		swordFrames[index] = Tool.Handle.CFrame
		index = index + 1
		if index > numClones then index = 1 end
		wait(waitTime)

	end

	for i = 1, numClones do
		mySwords[i].Parent = game.Lighting
	end

	if numClones > 0 then numClones = numClones - 1 end

	wait(5)

	Tool.Enabled = true

end

								
sword.Touched:connect(function (hit) 
								blow(hit, 1) 
							end)

script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

script.Parent.Activated:connect(onActivated)
