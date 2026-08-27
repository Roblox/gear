ball = script.Parent
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")

--	if humanoid ~= nil then
--		tagHumanoid(humanoid)
--		humanoid:TakeDamage(damage)
--		untagHumanoid(humanoid)
--	end

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
	--ball.Parent = nil
end

--connection = ball.Touched:connect(onTouched)


function isNotCreator(target)
	name_tag = ball:findFirstChild("creator")
	if name_tag == nil then return false end
	if (target == name_tag.Value) then return false
	else return true end
end


function sleepOpponent(distance, player)
	-- copy a whirlscreen if one is not there already
	whirlScreen = player.PlayerGui:FindFirstChild("WhirlScreen")
	if (whirlScreen == nil) then
		-- need to make a new whirlScreen
		whirlScreen = script:FindFirstChild("WhirlScreen")
		whirlScreen:Clone().Parent = player.PlayerGui
	end

	whirlScript = player.PlayerGui:FindFirstChild("WhirlScript")
	if (whirlScript == nil) then
		firstWhirlScript = script:FindFirstChild("WhirlScript")
		whirlScript = firstWhirlScript:Clone()
		whirlScript.Parent = player.PlayerGui
		--whirlScript.Disabled = false
	end


	if whirlScreen.WhirlStrength.Value > distance then

		whirlScript.Disabled = false
	
		-- reset the whirlscreen timer
		--whirlScreen.WhirlTimer.Value = 50 --in ms
		
		-- set the whirlscreen strength
		whirlScreen.WhirlStrength.Value = distance
	
		-- set the walking speed of the character
		-- will be done inside whirlScript

	end

end


local rvChangeSpeed = 2
local anim = 0
local step = .1
for i = 1,50 do
	myPlayers = game.Players:GetPlayers()

	-- sleep any players close enough who aren't the creator
	for j = 1, #myPlayers do
--		if myPlayers[j] ~= nil then
			if isNotCreator(myPlayers[j]) then
				newDistance = myPlayers[j]:DistanceFromCharacter(ball.Position)
				if newDistance < 50 then
					sleepOpponent(newDistance, myPlayers[j])
				end
			end
--		end
	end

	-- and also change spin directions
	ball.RotVelocity = ball.RotVelocity + Vector3.new((math.random()-.5)*rvChangeSpeed,(math.random()-.5)*rvChangeSpeed,(math.random()-.5)*rvChangeSpeed)

	anim = anim + step
	if anim >= 1 or anim <= 0 then step = -step end
	--ball.Size = Vector3.new(3+anim, 3+anim, 3+anim)
	ball.Color = Color3.new(1-anim,1,1-anim)
	ball.Transparency = anim
	wait(0.1)
end

--ball.SparkSound.Looped = false
--ball.SparkSound:Stop()

-- get rid of the hypnoSphere
ball.Parent = nil

