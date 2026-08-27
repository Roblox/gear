local currentTurkeys = 0

--math.randomseed(string.len(newPlayer.Name) % 5 * math.random(newPlayer.userId / 2, newPlayer.userId * 2))

local tShooter = script.Parent

function turkeyTouched(part, turkey)
	if part == nil or (part.Parent == nil) then return end
	hum = part.Parent:FindFirstChild("Humanoid")
	if hum ~= nil then
		if turkey.Name == "Turkey1" then
			hum:TakeDamage(1)
		elseif turkey.Name == "Turkey2" then
			hum:TakeDamage(2)
		else
			hum:TakeDamage(5)
		end
	end
end

function stick(x, y)
	weld = Instance.new("Weld") 

	weld.Part0 = x
	weld.Part1 = y

	local HitPos = x.Position

	local CJ = CFrame.new(HitPos) 
	local C0 = x.CFrame:inverse() * CJ 
	local C1 = y.CFrame:inverse() * CJ 

	weld.C0 = C0 
	weld.C1 = C1 
	
	weld.Parent = x
end

tShooter.Enabled = true
function spawnTurkey()
	if currentTurkeys < 5 and tShooter.Enabled then
	tShooter.Enabled = false
	randomInt = math.random(0, 100)
	if randomInt < 51 then
		turkeyType = 1
	elseif randomInt < 86 then
		turkeyType = 2
	else
		turkeyType = 3
	end
	local newTurkey = tShooter.Handle:findFirstChild("Turkey".. turkeyType):clone()
	newTurkey.Parent = game.Workspace
	newTurkey:moveTo(tShooter.Handle.Position + tShooter.Handle.CFrame:vectorToWorldSpace(Vector3.new(0, -1, 0)).unit*5) -- + Vector3.new(0,2,0))
	local base = newTurkey.Base
	g = newTurkey:getChildren()
	for i = 1, #g do
		if g[i].className == "Part" and g[i] ~= base then
			stick(base, g[i])
			g[i].Touched:connect(function(touched) turkeyTouched(touched, newTurkey) end)
		end
	end
	for i = 1, #g do
		if g[i].className == "Part" then 
			g[i].Anchored = false 
			if g[i].Name ~= "Base" then
				g[i].CanCollide = true
				g[i].Transparency = 0
			end 
		end
	end

	tShooter.Handle.CakeBang:Play()
	tShooter.Handle.TurkeySound:Play()

	if turkeyType > 1 then newTurkey.Body.Sparkles.Enabled = true end

	base.BodyGyro.cframe = base.CFrame

	base.Velocity = tShooter.Handle.CFrame:vectorToWorldSpace(Vector3.new(0, -1, 0)).unit*200 + Vector3.new(0, 50, 0)

	currentTurkeys = currentTurkeys + 1
	tShooter.Enabled = true

	wait(10)
	currentTurkeys = currentTurkeys - 1
	newTurkey:remove()

	end
end

function onEquip()
	tShooter.Handle.TurkeySound.Volume = 1
	tShooter.Handle.CakeBang.Volume = 1
end

function onUnequip()
	tShooter.Handle.TurkeySound.Volume = 0
	tShooter.Handle.CakeBang.Volume = 0
end

tShooter.Activated:connect(spawnTurkey)
tShooter.Equipped:connect(onEquip)
tShooter.Unequipped:connect(onUnequip)

