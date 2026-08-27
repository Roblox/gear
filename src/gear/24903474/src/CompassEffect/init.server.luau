debris = game:GetService("Debris")

-- finds direction to point compass at for rare egg

function findNearestRareEgg(pos)
	local temp = nil
	local rareEgg = nil
	local list = game.Workspace:FindFirstChild("eggroot")

	if list ~= nil then
		list = list:GetChildren()
		for x = 1, #list do
			local temp = list[x]
			eggNum = eggNameToRarity(temp.Name)
			if rareEgg == nil then
				rareEgg = temp
			elseif eggNum > eggNameToRarity(rareEgg.Name) then
				rareEgg = temp
			elseif eggNum == eggNameToRarity(rareEgg.Name) then
				rareEgg = closerEgg(rareEgg,temp)
			end
		end
	end
	return rareEgg
end

function closerEgg(rareEgg, temp)

	local rareEggPos = rareEgg.Handle.Position
	local tempEggPos =  temp.Handle.Position

	local humanPos = script.Parent.Torso.Position

	if math.abs((rareEggPos - humanPos).magnitude) > math.abs((tempEggPos - humanPos).magnitude) then
		return temp
	end

	return rareEgg

end

function eggNameToRarity(eggName)
	
	local rarity = 0

	local eggNum = tonumber(eggName)

	if eggNum == 1 then
		rarity = 0
	elseif eggNum == 2 then
		rarity = 0
	elseif eggNum == 3 then
		rarity = 0
	elseif eggNum == 4 then
		rarity = 0
	elseif eggNum == 5 then
		rarity = 0
	elseif eggNum == 6 then
		rarity = 0
	elseif eggNum == 7 then
		rarity = 1
	elseif eggNum == 8 then
		rarity = 1
	elseif eggNum == 9 then
		rarity = 1
	elseif eggNum == 10 then
		rarity = 1
	elseif eggNum == 11 then
		rarity = 1
	elseif eggNum == 12 then
		rarity = 2
	elseif eggNum == 13 then
		rarity = 2
	elseif eggNum == 14 then
		rarity = 3
	elseif eggNum == 15 then
		rarity = 4
	elseif eggNum == 16 then
		rarity = 5
	elseif eggNum == 18 then
		rarity = 0
	elseif eggNum == 19 then
		rarity = 2
	elseif eggNum == 20 then
		rarity = 0
	elseif eggNum == 21 then
		rarity = 0
	elseif eggNum == 22 then
		rarity = 1
	elseif eggNum == 23 then
		rarity = 6
	elseif eggNum == 24 then
		rarity = 7
	end

	return rarity

end

local closeRareEgg = findNearestRareEgg(script.Parent.EggCompass.Handle.Position)

if closeRareEgg ~= nil then

local pointDirection = nil

if closeRareEgg ~= nil then
		if(closeRareEgg.className == "Part") then
			pointDirection =  closeRareEgg.Position - script.Parent.Torso.Position
		else
			pointDirection =  closeRareEgg.Handle.Position - script.Parent.Torso.Position
		end
	end

	-- create arrow
	local p = Instance.new("Part")
	p.formFactor = 2
	p.Size = Vector3.new(1,.4,1)
	p.Transparency = .5
	p.BrickColor = BrickColor.new(104)
	p.CanCollide = false
	p.Locked = true
	p.RotVelocity = Vector3.new(math.random(), math.random(), math.random()) * 10
	local v = Vector3.new(script.Parent.Torso.CFrame.lookVector.x, 0, script.Parent.Torso.CFrame.lookVector.z)

	p.CFrame = CFrame.new(script.Parent.Torso.CFrame.p + v  * 4, v.unit)

	local m = script.ArrowMesh:Clone() -- NASTY
	m.Parent = p


	local b = Instance.new("BodyPosition")
	b.position = p.Position
	b.Parent = p

	local g = Instance.new("BodyGyro")
	g.cframe = CFrame.new(Vector3.new(0,0,0), pointDirection.unit) -- point towards egg
	g.maxTorque = Vector3.new(7e8, 7e8, 7e8)
	g.Parent = p

	p.Parent = game.Workspace

	debris:AddItem(p, 10)


	wait(3)
end

script.Parent = nil
