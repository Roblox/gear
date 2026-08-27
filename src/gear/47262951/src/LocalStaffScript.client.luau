-- Ninja Staff -- 

local Tool = script.Parent
local Staff = Tool.Handle

Tool.Enabled = true

local BoStaff = Tool.Handle:Clone()
BoStaff.Name = "BoStaff"

BoStaff.CanCollide = false
newBAV = Instance.new("BodyAngularVelocity")
newBAV.P = 100000
newBAV.maxTorque = Vector3.new(newBAV.P, newBAV.P, newBAV.P)


newBP = Instance.new("BodyPosition")
newBP.P = 100000
newBP.maxForce = Vector3.new(newBP.P, newBP.P, newBP.P)

newBAV.Parent = BoStaff
newBP.Parent = BoStaff


StaffUnequipped = false

-- Sounds
local SlashSound = Tool.Handle.SlashSound
local SpinSound = Tool.Handle.SpinSound

-- Animation
local StaffSwing 
local StaffSlash

-- damage
local damage = 0
local spinDamage = 1
local slashDamage = 30

function blow(hit)
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")
	
	if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then 
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then 
			joint = rightArm:FindFirstChild("RightGrip")
			if joint ~= nil and (joint.Part0 == Staff or joint.Part1 == Staff) then 
				tagHumanoid(humanoid, vPlayer)
				print(damage)
				humanoid:TakeDamage(damage)
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end
	end
end

function tagHumanoid(humanoid, Player)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = Player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag.Parent = nil
		end
	end
end


function onActivated()
	
	if not Tool.Enabled then 
		return 
	end
	
	Tool.Enabled = false

	myHumanoid = Tool.Parent:FindFirstChild("Humanoid")
	if not myHumanoid then 
		return
	end
	
	
	MyTorso = Tool.Parent:FindFirstChild("Torso")
	if MyTorso ~= nil then
		--BoStaff.Transparency = 0
		Staff.Transparency = 1
		BoStaff.CFrame = Staff.CFrame
		BoStaff.Parent = Staff.Parent
		damage = spinDamage
		connection = BoStaff.Touched:connect(blow)

		StaffSpin = myHumanoid:LoadAnimation(Tool.StaffSpin6)
		StaffSpin:Play()		

		SpinSound:Play()
		--newBAV.Parent = BoStaff
		--newBP.Parent = BoStaff
		
		-- vertical spin
		for i = 1, 25 do
			if not StaffUnequipped then
				theta = i*2*math.pi/25
				BoStaff.BodyPosition.position = MyTorso.Position + math.cos(theta)*MyTorso.CFrame.lookVector + 2*math.sin(theta)*MyTorso.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0))
				BoStaff.BodyAngularVelocity.angularvelocity = MyTorso.CFrame:vectorToWorldSpace(Vector3.new(0, 0, 20))
				wait(.1)
			end
		end
	
		if not StaffUnequipped then StaffSpin:Play() end
		-- horizontal spin
		for i = 1, 25 do
			if not StaffUnequipped then 
				theta = i*2*math.pi/25
				BoStaff.BodyPosition.position = MyTorso.Position + math.cos(theta)*MyTorso.CFrame.lookVector + 2*math.sin(theta)*MyTorso.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0))
				BoStaff.BodyAngularVelocity.angularvelocity = MyTorso.CFrame:vectorToWorldSpace(Vector3.new(0, 20, 0))
				wait(.1)
			end
		end

		BoStaff.Parent = nil
		Staff.Transparency = 0
		connection:disconnect()
		if not StaffUnequipped then
			connection = Staff.Touched:connect(blow)
			wait(0.1)		
			Tool.Handle.Fire.Enabled = true
			damage = slashDamage
			StaffSlash = myHumanoid:LoadAnimation(Tool.StaffSlash)
			StaffSlash:Play()		
			SlashSound:Play()
			wait(0.5)
			if connection then connection:disconnect() end	
		end
	end
		damage = 0
		Tool.Enabled = true
		Tool.Handle.Fire.Enabled = false
	
end

function onEquippedLocal()
	StaffUnequipped = false
	BoStaff.Parent = nil
end

function onUnequippedLocal()
	StaffUnequipped = true
	if StaffSlash then StaffSlash:Stop() end
	if SlashSound then SlashSound:Stop() end
	if StaffSpin then StaffSpin:Stop() end
	if SpinSound then SpinSound:Stop() end

	Staff.Transparency = 0.0
	BoStaff.Parent = nil

	--if newBAV ~= nil then newBAV:Remove() end
	--if newBP ~= nil then newBP:Remove() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

