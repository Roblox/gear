-- 15% life steal
local Tool = script.Parent
local Batarang = Tool.Handle

local damage = 20

local debris = game:GetService("Debris")
Tool.Enabled = true 

local batarangClone

local vCharacter
local myHumanoid
local myTorso

local maxDistance = 80.0
local count = 0

local awayFromCharacter = true

function returnToCharacter()			
	if batarangClone and myTorso then 
		local distance = (myTorso.Position - batarangClone.Position).magnitude		
		local lookAt  = myTorso.Position - batarangClone.Position
		while distance > 4.0 and batarangClone ~= nil do 			
			batarangClone.Velocity = lookAt.unit * 45						
			if batarangClone ~= nil then 
				lookAt  = myTorso.Position - batarangClone.Position
				distance = lookAt.magnitude
			end			
			wait(0.1)
		end		
	end	
	batarangClone.Parent = nil
	Tool.Handle.Transparency = 0	
	Tool.Enabled = true
	awayFromCharacter = true	
end

function doDamage(hit)	
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	if vCharacter == nil then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer == nil then return end
	local myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then return end

	if humanoid ~= nil and myHumanoid ~= humanoid then 		
		tagHumanoid(humanoid, vPlayer)
		humanoid:TakeDamage(damage)
		awayFromCharacter = false
		if myHumanoid.Health + 0.15 * damage < myHumanoid.MaxHealth then 
			myHumanoid.Health = myHumanoid.Health + 0.15 * damage
		end
	end
	if humanoid == nil and hit.Parent.Name ~= "Batarang" then		
		awayFromCharacter = false
	end
end

function shoot(pos)			
	if vCharacter == nil or myHumanoid == nil or batarangClone == nil then 		
		Tool.Enabled = true
		return
	end
	
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then return end	
	local sPos = vCharacter.PrimaryPart.Position
	sPos = sPos + pos * 5.0	
	
	batarangClone.CFrame = CFrame.new(sPos, sPos + pos) * CFrame.Angles(math.pi/2, 0, 0)		
	batarangClone.Velocity = pos * 45	

	batarangClone.Name = "Batarang"
	batarangClone.CanCollide = false
	batarangClone.Parent = game.Workspace
	
	batarangClone.Touched:connect(doDamage)
	
	local starFloat = Instance.new("BodyForce")
	starFloat.force = Vector3.new(0.0, batarangClone:GetMass() * workspace.Gravity, 0.0)	
	starFloat.Parent = batarangClone

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 100000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, 0, bodyGyro.P)
	bodyGyro.cframe = batarangClone.CFrame 
	bodyGyro.Parent = batarangClone

	local bav = Instance.new("BodyAngularVelocity")
	bav.P = 5000000
	bav.maxTorque = Vector3.new(0, bav.P, 0)
	bav.angularvelocity = Vector3.new(0, 20, 0)
	bav.Parent = batarangClone

	local distance = (batarangClone.Position - sPos).magnitude	
	while awayFromCharacter and distance < maxDistance and batarangClone ~= nil do 		
		wait(0.25)		
		distance = (batarangClone.Position - sPos).magnitude		
	end
	awayFromCharacter = false
	if batarangClone then returnToCharacter() end
end

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
		debris:AddItem(creatorTag, 1)
	end
end

function onActivated()	
	if not Tool.Enabled then 
		return
	end
	
	Tool.Enabled = false
	vCharacter = Tool.Parent	
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myHumanoid  == nil or myTorso == nil then 
		return
	end	
	batarangClone = Tool.Handle:Clone()
	batarangClone.CFrame = Batarang.CFrame
	batarangClone.Transparency = 0
	local targetPos = myHumanoid.TargetPoint
	local lookAt = (targetPos - vCharacter.Head.Position).unit	
	wait(0.2)
	Tool.Handle.Transparency = 1.0	
	shoot(lookAt, batarangClone)
end

function onEquipped()
	count = 0
	Tool.Handle.Transparency = 0.0
	awayFromCharacter = true
	wait(1.0)
	Tool.Enabled = true
end

function onUnequipped()
	Tool.Handle.Transparency = 0.0
	if batarangClone then batarangClone:Destroy() end
	if chakraSpin then chakraSpin:Stop() end
	if chakraThrow then chakraThrow:Stop() end
	if connection then connection:disconnect() end
	count = 0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)