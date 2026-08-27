--Updated for R15 avatars by StarWars

local Tool = script.Parent
local bounceCount = 0
local enabled = true
local beenActivated = false
local healPlayers = false
local bounceUp = Instance.new("BodyPosition")
local bounceAround = Instance.new("BodyForce")

function onTouched(part)
	
	local h = part.Parent:FindFirstChild("Humanoid")
	if h ~= nil and beenActivated then
		
		if Tool.Handle.BeachBallHit.IsPlaying == false then
			Tool.Handle.BeachBallHit:Play()
		end
		
		if healPlayers then
			if h.Health < h.MaxHealth then
				h.Health = h.Health + 2
				if h.Health > h.MaxHealth then
					h.Health = h.MaxHealth
				end
			end
		end

		bounceCount = bounceCount + 1

		local torso = h.Parent:FindFirstChild("Torso", false) or h.Parent:FindFirstChild("UpperTorso", false)
		local torsoNormal = torso.CFrame.lookVector
		local distanceToBounce = 30
		local bounceVectorX = distanceToBounce
		local bounceVectorZ = distanceToBounce

		local denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
		bounceVectorX = bounceVectorX * (torsoNormal.x/denom)
		bounceVectorZ = bounceVectorZ * (torsoNormal.z/denom)

		local torso = h.Parent:FindFirstChild("Torso", false) or h.Parent:FindFirstChild("UpperTorso", false)
		bounceVectorX = bounceVectorX * math.abs(torso.Velocity.x/h.WalkSpeed)
		bounceVectorZ = bounceVectorZ * math.abs(torso.Velocity.y/h.WalkSpeed)

		local upToHere = torso.Position.y + 35
		bounceUp.position = Vector3.new(Tool.Handle.Position.x + bounceVectorX,upToHere,Tool.Handle.Position.z + bounceVectorZ)
		bounceUp.maxForce = Vector3.new(250,500,250)
		bounceUp.P = 500
		bounceUp.D = 400
		bounceUp.Parent = Tool.Handle
		wait(1)
		bounceUp.Parent = nil
		wait(0.2)
		bounceUp.Parent = Tool.Handle
		bounceUp.position = Vector3.new(Tool.Handle.Position.x  + bounceVectorX/2,upToHere - 35,Tool.Handle.Position.z +  bounceVectorZ/2)
		wait(1)
		bounceUp.Parent = nil
		
	end

	if bounceCount >= 9 then

		if Tool.Handle.BeachBallRiff.IsPlaying == false then
			Tool.Handle.BeachBallRiff:Play()
		end

		
		if healPlayers == false then
			sparkly = Instance.new("Sparkles")
			sparkly.SparkleColor = Color3.new(math.random(0,1),math.random(-1,0.5),math.random(0,1))
			sparkly.Parent = Tool.Handle
			healPlayers = true
		end

		bounceCount = 0

	end

end

Tool.Handle.Touched:connect(onTouched)


function onActivated()

	if not enabled  then
		return
	end

	enabled = false

	local h = Tool.Parent:FindFirstChild("Humanoid")
	if h ~= nil then
		local playerPos = h.Parent:FindFirstChild("Torso") or h.Parent:FindFirstChild("UpperTorso")
		if playerPos ~= nil then

			beenActivated = true
			playerPos = playerPos.Position
			local torso = h.Parent:FindFirstChild("Torso", false) or h.Parent:FindFirstChild("UpperTorso", false)
			local torsoNormal = torso.CFrame.lookVector 
			local distanceToBounce = 20
			local bounceVectorX = distanceToBounce
			local bounceVectorZ = distanceToBounce

			denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
			bounceVectorX = bounceVectorX * (torsoNormal.x/denom)
			bounceVectorZ = bounceVectorZ * (torsoNormal.z/denom)
			
			bounceUp.position = Vector3.new(playerPos.x + bounceVectorX ,playerPos.y + distanceToBounce + 15,playerPos.z + bounceVectorZ)
			bounceUp.Parent = Tool.Handle
			bounceUp.D = 30
			bounceUp.P = 70
			h.Jump = true
			Tool.Parent = game.Workspace
			wait(0.3)

			bounceUp.Parent = nil
			wait(0.1)

			bounceUp.Parent = Tool.Handle
			bounceUp.P = 31
			bounceUp.D =  17
			bounceUp.position = Vector3.new(playerPos.x + (bounceVectorX * 2),playerPos.y,playerPos.z + (bounceVectorZ * 2))
			wait(0.5)

			bounceUp.Parent = nil
			
		end
	end
	enabled = true

end

Tool.Activated:connect(onActivated)

