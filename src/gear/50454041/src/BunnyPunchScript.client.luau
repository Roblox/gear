local Tool = script.Parent
local Carrot = Tool.Handle

local vCharacter
local connection

local bunnyActive = Tool:FindFirstChild("BunnyActive")

function blow(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	torso = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 
		rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Carrot or rightGrip.Part1 == Carrot) then 
				fire = Carrot:FindFirstChild("Fire")
				if fire then 
					fire:Destroy()
				end
				if connection then 
					connection:disconnect()
				end
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(60)
				bv = Instance.new("BodyVelocity")
				bv.P = 100000
				bv.maxForce = Vector3.new(bv.P, bv.P, bv.P)
				bv.velocity = (torso.Position - vCharacter.Torso.Position).unit * 50.0
				bv.Parent = torso
				wait(1.0)
				untagHumanoid(humanoid)				
				if bv then bv:Destroy() end
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid 
	end
end

function untagHumanoid(humanoid)
	if humanoid then 
		tag = humanoid:FindFirstChild("creator")
		if tag then 
			tag:Destroy() 
		end
	end
end

function onKeyDown(key)
	if key:lower() == "q" and bunnyActive.Value == 1 then 
		fire = Carrot:FindFirstChild("Fire")
		if fire == nil then
			wait(1.0)
			vCharacter = Tool.Parent
			myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
			if myTorso then 
				fire = Instance.new("Fire")
				fire.Parent = Carrot 			
				connection = Carrot.Touched:connect(blow)
			end
		end
	end
end

function onActivatedL()
end

function onEquippedL(mouse)
	mouse.KeyDown:connect(onKeyDown)
end

function onUnequippedL()
end

Tool.Activated:connect(onActivatedL)
Tool.Equipped:connect(onEquippedL)
Tool.Unequipped:connect(onUnequippedL)