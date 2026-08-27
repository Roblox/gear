local BLAST_RADIUS = 7

local Rocket = script.Parent
local StartAt = Rocket.Position

--make sure we go away if all else fails
game.Debris:AddItem(Rocket, 20)

--wait for the creator
while not script:FindFirstChild('creator') do script.ChildAdded:wait() end
while not script.creator.Value do script.creator.Changed:wait() end
local Creator = script.creator.Value

--ontouched
Rocket.Touched:connect(function(part)
	local hum = (part.Parent or game):FindFirstChild('Humanoid')
	hum = hum or ((part.Parent or game).Parent or game):FindFirstChild('Humanoid')
	--
	if hum then
		--first see if it's us
		if game.Players:GetPlayerFromCharacter(hum.Parent) == Creator then
			return --don't explode on ourself
		end

		--we have a direct hit of a humanoid, kill it
		--first tag:
		if script:FindFirstChild('creator') then
			local tag = script.creator:Clone()
			tag.Parent = hum
			game.Debris:AddItem(tag, 2)
		end
		--then damage
		hum:TakeDamage(hum.MaxHealth)

	elseif not part.CanCollide then
		--not cancollide, don't explode
		return
	end
	--get rid of the rocket
	Rocket.Anchored = true
	Rocket.CanCollide = false
	Rocket.Transparency = 1

	--make an explosion
	local exp = Instance.new('Explosion')
	exp.Position = Rocket.Position
	exp.BlastPressure = 0
	exp.BlastRadius = BLAST_RADIUS


	--set up damage
	local hasHitMap = {}
	exp.Hit:connect(function(hit, radius)
		--did we hit a humanoid?
		local hum2 = (hit.Parent or game):FindFirstChild('Humanoid')
		hum2 = hum2 or ((hit.Parent or game).Parent or game):FindFirstChild('Humanoid')
		if hum2 and not hasHitMap[hum2] then
			--mark it
			hasHitMap[hum2] = true

			--calculate how much damage to do
			local damageFrac = radius/BLAST_RADIUS
			damageFrac = 1 - damageFrac*damageFrac

			--tag them
			if script:FindFirstChild('creator') then
				local tag = script.creator:Clone()
				tag.Parent = hum2
				game.Debris:AddItem(tag, 2)
			end

			--do the damage
			hum2:TakeDamage(50*damageFrac)
		end
	end)

	--let it fly
	exp.Parent = game.Workspace

	--give it a chance to fly, and then get rid of us
	wait(1)
	Rocket:Destroy()
end)

wait(10)
Rocket:Destroy()