ball = script.Parent
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

--myAngVel = ball.BodyAngularVelocity
--local noMoreCollision = false

local touchConnection = nil

function onTouched(hit)
	--if noMoreCollision then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local hrp = hit.Parent:FindFirstChild('HumanoidRootPart')

	if humanoid and hrp and hit.Parent:FindFirstChild("FreezeRayIceCube") == nil then
--		noMoreCollision = true
		touchConnection:disconnect()
		tagHumanoid(humanoid)
		humanoid:TakeDamage(damage)
		untagHumanoid(humanoid)
		
		-- freeze them too! :D
		iceCube = Instance.new("Part")
		iceCube.Name = "FreezeRayIceCube"

		iceCube.Size = Vector3.new(5, 10, 5)
		iceCube.CFrame = hrp.CFrame
		iceCube.BrickColor = BrickColor.new("Cyan")
		iceCube.TopSurface = 0
		iceCube.BottomSurface = 0

		local iceWeld = Instance.new("Weld")
		iceWeld.Part0 = iceCube
		iceWeld.Part1 = hrp
		iceWeld.C1 = CFrame.new()
		iceWeld.Parent = iceCube

		iceCube.Transparency = 0.5
		iceCube.Parent = hit.Parent
		humanoid.WalkSpeed = 0

		local frostyTag = Instance.new("NumberValue")
		frostyTag.Name = "FrostyValue"
		frostyTag.Value = 1
		frostyTag.Parent = hit.Parent

		iceCube.CanCollide = true
		HitSound:Play()

		-- below line must be BEFORE frostyTag, or it will fail?
		ball.Parent = nil

		frostyTag.Changed:connect( function () 
			print("Changed is being called")
			
			--if numba <= 0 then
				humanoid.WalkSpeed = 16
				iceCube:remove()
				--iceCube:remove()
				--frostyTag:remove()
			--end
		end)

		
		print("well, we at least got here")

		wait(10)
		humanoid.WalkSpeed = 16
		iceCube:remove()
		frostyTag:remove()
	else

		HitSound:Play()
		ball.Parent = nil
	
	end
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = ball:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
	end
end


function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

touchConnection = ball.Touched:connect(onTouched)

wait(4)
--myAngVel.angularvelocity = 20*ball.CFrame:vectorToWorldSpace(Vector3.new(0, 0, 1)).unit
--ball.SparkSound.Looped = false
--ball.SparkSound:Stop()
ball.Parent = nil