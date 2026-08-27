local Tool = script.Parent

local damage = 15

local debris = game:GetService("Debris")
Tool.Enabled = true 

local starClone

local maxDistance = 60.0
local count = 0

local AwayFromCharacter = true


-- Sounds
local chakraSpin = nil
while chakraSpin == nil do
	chakraSpin = Tool:FindFirstChild("ChakraSpin")
	wait(.5)
end

-- Animation
local chakraThrow 

-- connection!
local connection


function returnToCharacter()
	--print("RETURNING TO CHARACTER")
	--print(starClone)
	local torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")

--	if starClone then
--		newBP = starClone:FindFirstChild("starPos")
--		if newBP == nil then
--			newBP = Instance.new("BodyPosition")
--			newBP.P = 1
--			newBP.maxForce = Vector3.new(newBP.P, newBP.P, newBP.P)
--			if starClone then newBP.Parent = starClone end
--		end
	--end
	
	if starClone and torso then 
		local distance = (torso.Position - starClone.Position).magnitude
		--print(Tool.Parent.Torso.Position)
		--print(starClone.Position)
		--print(distance)
		local lookAt  = torso.Position - starClone.Position
		while distance > 4.0 and starClone ~= nil do 			
			--print("INSIDE WHILE LOOP")
			--starClone.Velocity = lookAt.unit * 30.0
			starClone.Velocity = lookAt.unit * 30
			--starClone.starPos.position = torso.Position
			--print(starClone.Velocity)
			--print(distance)

			starClone.RotVelocity = Vector3.new(0.0, -50.0, 0.0)
			if starClone ~= nil then 
				lookAt  = torso.Position - starClone.Position
				distance = lookAt.magnitude
			end
			--if distance < 5.0 then print("DISTANCE = ", distance) end
			wait(0.1)
		end		
	end	
	starClone.Parent = nil
	Tool.Handle.Transparency = 0
	if connection then connection:disconnect() end
	Tool.Enabled = true
	AwayFromCharacter = true
	if chakraSpin then chakraSpin:Stop() end
end



-- Shoot!!
function shoot(pos, star)
	print("In Shoot")
	
	local vCharacter = Tool.Parent
	if vCharacter == nil or vCharacter:findFirstChild("Humanoid") == nil then 
		print("NO Character")
		Tool.Enabled = true
		return
	end
	
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	if vPlayer == nil then print("NO PLAYER?") end
	-- Spawning position of the clone star
	local sPos = vCharacter.PrimaryPart.Position
	sPos = sPos + pos*5
	--print("SPAWN POS", sPos)
	
	star.CFrame = CFrame.new(sPos, sPos+pos)  * CFrame.Angles(math.pi/2,0.0, 0.0)
	star.Velocity = pos*30

	--star.Velocity = pos * 30
	star.RotVelocity = Vector3.new(0.0, 50.0, 0.0)
	star.Name = "ThrownStar"
	star.CanCollide = false
	star.Parent = game.Workspace


	-- Touched event must be added HERE!
	if connection ~= nil then connection:disconnect() end
	connection = starClone.Touched:connect(doDamage)


	-- To keep the star afloat
	local starFloat = Instance.new("BodyForce")
	starFloat.force = Vector3.new(0.0, star:GetMass() * 196.1, 0.0)	
	starFloat.Parent = star
	distance = (star.Position - sPos).magnitude
	chakraSpin:Play()
	while AwayFromCharacter and distance < maxDistance and star ~= nil do 		
		wait(.25)
		-- print("INFINITE WAIT")
		distance = (star.Position - sPos).magnitude
		
		--else Tool.Enabled = true break end
	end
	AwayFromCharacter = false
	if star then returnToCharacter() end
	
	-- Play Sounds here
	--
end

function doDamage(hit)
	print("hit")
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
		AwayFromCharacter = false
		wait(1.0)
		untagHumanoid(humanoid)
		print(hit.Parent)
	end
	if humanoid == nil and hit.Parent.Name ~= "Chakra" then
		print(hit.Parent)
		AwayFromCharacter = false
	end
end




function tagHumanoid(humanoid, player)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
	creatorTag.Value = player
end

function untagHumanoid()
	if humanoid ~= nil then 
		local tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag.Parent = nil
		end
	end
end

function onActivated()
	--if game.Workspace:FindFirstChild("ThrownStar") ~= nil then game.Workspace:FindFirstChild("ThrownStar"):Remove() end
	if not Tool.Enabled then 
		return
	end
	
	Tool.Enabled = false
	local character = Tool.Parent
	if character == nil then
		print("No character")
		Tool.Enabled = true
		return
	end
	local humanoid = character.Humanoid
	if humanoid  == nil then 
		print("No Humanoid")
		Tool.Enabled = true
		return
	end
	
	local Animation = Tool.ChakraThrow
	if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Tool.R15ChakraThrow
	end
	
	chakraThrow = humanoid:LoadAnimation(Animation)

	starClone = Tool.Handle:Clone()
	starClone.Transparency = 0
	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit
	--local ThrowAnim = humanoid:	LoadAnimation(Tool.Spin)
	--ThrowAnim:Play()
	if chakraThrow then chakraThrow:Play() end
	wait(0.2)
	Tool.Handle.Transparency = 1.0	
	shoot(lookAt, starClone)
end

function onEquipped()
	count = 0
	Tool.Handle.Transparency = 0.0
	AwayFromCharacter = true
	wait(1.0)
	Tool.Enabled = true
end

function onUnequipped()
	Tool.Handle.Transparency = 0.0
	if starClone then starClone:Destroy() end
	if chakraSpin then chakraSpin:Stop() end
	if chakraThrow then chakraThrow:Stop() end
	if connection then connection:disconnect() end
	count = 0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)