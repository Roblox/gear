local Tool = script.Parent
local CharAddPartCn;

local Equipped = false

local mObjectToToucherCount = {}

local TouchingMap = {}

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

function TagHumanoid(humanoid)
	local player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	if player then
		local tag = Create'ObjectValue'{
			Name = "creator", 
			Value = player,
			Parent = humanoid,
		}
		game.Debris:AddItem(tag, 1)
	end
end

function onBeginTouch(part)
	TouchingMap[part] = true
	local hum = (part.Parent or game):FindFirstChild('Humanoid')
	hum = hum or ((part.Parent or game).Parent or game):FindFirstChild('Humanoid')
	--
	if hum and hum ~= Tool.Parent.Humanoid then
		Spawn(function()
			while TouchingMap[part] do
				TagHumanoid(hum)
				hum:TakeDamage(2)
				wait(0.1)
			end
		end)
	end
end

function onEndTouch(part)
	TouchingMap[part] = nil
end

local function beginTouch(part, lick)
	if not mObjectToToucherCount[part] then
		onBeginTouch(part)
	end
	mObjectToToucherCount[part] = (mObjectToToucherCount[part] or 0)+1
	--try removal
	--removal strtegy:
	--try to figure out what's scenery. If it's hot a humanoid in it, definitely
	--don't remove the flame. Once it's established that there's no humanoid, it
	--must be Anchored. But not all anchored things are scenery, some are effects
	--from gear and what not, so only block on sufficiently large parts (flames
	--should be able to bend around small objects too, so this msakes sense).
	local hum = (part.Parent or game):FindFirstChild('Humanoid')
	hum = hum or ((part.Parent or game).Parent or game):FindFirstChild('Humanoid')
	local partVolume = part.Size.x*part.Size.y*part.Size.z
	if part.Anchored and not hum and partVolume > 17 then
		lick.QueuedForRemoval = true
	end
end
local function endTouch(part, lick)
	if not mObjectToToucherCount[part] then return end
	mObjectToToucherCount[part] = mObjectToToucherCount[part]-1
	if mObjectToToucherCount[part] <= 0 then
		mObjectToToucherCount[part] = nil
		onEndTouch(part)
	end
end

local function frand(a,b)
	return a+math.random()*(b-a)
end

local function frand2(a,b)
	return frand(a,b)*frand(a,b)
end

local mFreeFlameBitList = {}
local mFlameBitList = {}
local function AddFlameBit(cf)
	local lick = {}
	lick.Transparency = frand(0.4, 0.6)
	if #mFreeFlameBitList > 0 then
		lick.Part = mFreeFlameBitList[#mFreeFlameBitList]
		mFreeFlameBitList[#mFreeFlameBitList] = nil
		--
		lick.Part.Size = Vector3.new(frand(1,1.5), 0.2, frand(3,5))
	else
		lick.Part = Create'Part'{
			Name = 'FireLick',
			Parent = Tool.Parent,
			FormFactor = 'Custom',
			CanCollide = false,
			--
			Size = Vector3.new(frand(1,1.5), 0.2, frand(3,5)),
			Transparency = 1,
			--
			Create'Decal'{
				Name = 'TopDecal',
				Face = 'Top',
				Shiny = 0,
				Texture = 'http://www.roblox.com/asset/?id=4723996',
				Transparency = lick.Transparency,
			},
			Create'Decal'{
				Name = 'BottomDecal',
				Face = 'Bottom',
				Shiny = 0,
				Texture = 'http://www.roblox.com/asset/?id=4723996',
				Transparency = lick.Transparency,
			},
			Create'BodyVelocity'{
				Name = 'Fly',
				maxForce = Vector3.new(100000,100000,100000),
				velocity = Vector3.new(0,0,0),	
			},
		}
	end
	lick.TouchCn = lick.Part.Touched:connect(function(p) beginTouch(p, lick) end)
	lick.EndTouchCn = lick.Part.TouchEnded:connect(function(p) endTouch(p, lick) end)
	lick.Part.CFrame = cf
	lick.Part.Fly.velocity = cf.lookVector*(-60)
	lick.Part.Parent = Tool.Parent
	lick.Timestamp = tick()
	mFlameBitList[lick] = true
end


local function Destroy()
	for lick, _ in pairs(mFlameBitList) do
		lick.Part.Parent = nil
		lick.TouchCn:disconnect()
		lick.EndTouchCn:disconnect()
		mFreeFlameBitList[#mFreeFlameBitList+1] = lick.Part
		mFlameBitList[lick] = nil
	end
end

Tool.Equipped:connect(function()
	Equipped = true
	CharAddPartCn = Tool.Parent.ChildAdded:connect(function(msg)
		print("Got Message "..msg.Name)
		if msg:IsA('CFrameValue') and msg.Name == 'MSG_AddFlameBit' then
			local cf = msg.Value
			msg:Destroy()
			--
			AddFlameBit(cf)
		elseif msg:IsA('BoolValue') and msg.Name == 'MSG_Stop' then
			msg:Destroy()
			Destroy()
		end
	end)
end)
Tool.Unequipped:connect(function()
	Destroy()
	Equipped = false
	if CharAddPartCn then
		CharAddPartCn:disconnect()
		CharAddPartCn = nil
	end
end)

while true do
	local t = tick()
	for lick, _ in pairs(mFlameBitList) do
		if (t-lick.Timestamp) > 0.5 or lick.QueuedForRemoval then
			lick.Part.Parent = nil
			lick.TouchCn:disconnect()
			lick.EndTouchCn:disconnect()
			mFreeFlameBitList[#mFreeFlameBitList+1] = lick.Part
			mFlameBitList[lick] = nil
		else
			local tfrac = (t-lick.Timestamp)/0.5
			lick.Part.TopDecal.Transparency = lick.Transparency*tfrac
			lick.Part.BottomDecal.Transparency = lick.Transparency*tfrac
		end
	end
	wait()
end
 