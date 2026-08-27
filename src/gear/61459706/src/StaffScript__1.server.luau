local Tool = script.Parent
local Staff = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 

Tool.Enabled = true 

local staffDamage = 16

local staffAOE = Vector3.new(20, 20, 20)

local bvTable = {}

local debris = game:GetService("Debris")

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1.5)
	end
end

function blow(hit)
	if hit and hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid and myHumanoid and myHumanoid ~= humanoid then 
			local rightArm = vCharacter:FindFirstChild("Right Arm")
			if rightArm then 
				local rightGrip = rightArm:FindFirstChild("RightGrip")
				if rightGrip and (rightGrip.Part0 == Staff or rightGrip.Part1 == Staff) then 
					tagHumanoid(humanoid, player)
					humanoid:TakeDamage(staffDamage)
				end
			end
		end
	end
end

function fuse(part, hit)
	if hit and hit.Parent and hit.Parent ~= part.Parent and hit.Parent ~= vCharacter then 
		local bv = hit:FindFirstChild("StaffBV")
		local bav = hit:FindFirstChild("StaffBAV")
		local fire = hit:FindFirstChild("CRFire")
		if bv or bav or fire then return end 
		bv = part:FindFirstChild("StaffBV")
		bav = part:FindFirstChild("StaffBAV")
		fire = part:FindFirstChild("CRFire")
		if bv then 
			local bvc = bv:Clone()
			bvc.Parent = hit 
			debris:AddItem(bvc,  1)
		end
		if bav then 
			local bavc = bv:Clone()
			bavc.Parent = hit 
			debris:AddItem(bavc, 1)
		end
		if fire then 
			local firec = fire:Clone()
			firec.Parent = hit 
			debris:AddItem(fire, 1)
		end
	end
end

function chainReactor()
	if myTorso == nil or myHumanoid == nil then 
		Tool.Enabled = true 
		return 
	end

	local animate = Tool:FindFirstChild("Animate")
	if animate then animate.Value = 1 end

	local parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - staffAOE, myTorso.Position + staffAOE), vCharacter, 100)
	for i = 1, #parts do 
		if parts[i] and parts[i].Parent then
			parts[i].Touched:connect(function(hit) fuse(parts[i], hit) end)
			local tempChar = parts[i].Parent
			local tempHumanoid = tempChar:FindFirstChild("Humanoid")
			tick()
			if tempHumanoid == nil then				
				local bv = Instance.new("BodyVelocity")
				bv.maxForce = Vector3.new(100000, 100000, 100000)
				bv.P = 100000
				bv.velocity = (parts[math.random(1, #parts)].Position - parts[i].Position).unit * 10.0
				bv.Parent = parts[i]
				bv.Name = "StaffBV"

				local bav = Instance.new("BodyAngularVelocity")
				bav.Name = "StaffBAV"
				bav.P = 100000				
				bav.angularvelocity = Vector3.new(math.random(1, 10000)/2000, math.random(1, 20000)/2500, math.random(1, 30000)/1500)
				bav.Parent = parts[i]	

				fire = Instance.new("Fire")
				fire.Name = "CRFire"
				fire.Parent = parts[i]
				fire.Color = Color3.new(51/255, 51/255, 51/255)
				fire.SecondaryColor = Color3.new(204/255, 102/255, 0)
				fire.Heat = 0
				fire.Size = 2
				table.insert(bvTable, bv)	
				
			else
				tempHumanoid.Sit = true				
				tempTorso = tempChar:FindFirstChild("Torso")
				if tempTorso and tempTorso:FindFirstChild("StaffBV") == nil then 
					tempHumanoid:TakeDamage(3 * staffDamage)
					local count = 10
					local targetPart = parts[math.random(1, #parts)] 
					while targetPart.Parent == parts[i].Parent and count > 0 do 
						targetPart = parts[math.random(1, #parts)]
						count = count - 1
					end					
					if targetPart.Parent ~= parts[i].Parent then
						local bv = Instance.new("BodyVelocity")
						bv.maxForce = Vector3.new(100000, 100000, 100000)
						bv.P = 100000
						bv.velocity = ((parts[math.random(1, #parts)].Position - tempTorso.Position).unit * 15.0) + Vector3.new(0, 3, 0)
						bv.Parent = tempTorso
						bv.Name = "StaffBV"

						local bav = Instance.new("BodyAngularVelocity")
						bav.Name = "StaffBAV"
						bav.P = 100000				
						bav.angularvelocity = Vector3.new(math.random(1, 10000)/1000, math.random(1, 20000)/1000, math.random(1, 40000)/1000)
						bav.Parent = tempTorso	

						fire = Instance.new("Fire")
						fire.Name = "CRFire"
						fire.Parent = parts[i]
						fire.Color = Color3.new(51/255, 51/255, 51/255)
						fire.SecondaryColor = Color3.new(204/255, 102/255, 0)
						fire.Heat = 0
						fire.Size = 2
						table.insert(bvTable, bv)
					end
				end
			end			
		end
	end 

	wait(1.5)
	for i = 1, #parts do 
		if parts[i] and parts[i].Parent then 
			local bv = parts[i]:FindFirstChild("StaffBV")
			local fire = parts[i]:FindFirstChild("CRFire")	
			local bav = parts[i]:FindFirstChild("StaffBAV")
			if bv then bv:Remove() end
			if fire then fire:Remove() end
			if bav then bav:Remove() end
		end
		if parts[i].Parent and parts[i].Parent:FindFirstChild("Torso") then
			local torso = parts[i].Parent.Torso
			local bv = torso:FindFirstChild("StaffBV") 
			local bav = torso:FindFirstChild("StaffBAV")
			if bv then bv:Remove() end		
			if bav then bav:Remove() end
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")

	if myHumanoid == nil or myTorso == nil then
		return 
	end

	local animate = Tool:FindFirstChild("Animate")
	if animate and animate.Value == 1 then return end

	Tool.Enabled = false

	chainReactor()

	wait(5.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	animate = Tool:FindFirstChild("Animate")
	if animate then animate.Value = 0 end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Staff.Touched:connect(blow)
