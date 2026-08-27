-- Made by Stickmasterluke
 -- edited by fusroblox

local Tool = script.Parent
local check = true

local GunDamage = 20 -- Base output damage per shot.
local FireRate = .25 -- How often the weapon can fire.
local Automatic = false -- hold down to continue firing
local Range = 250 -- Max distance that the weapon can fire.
local Spread = 6 -- The bigger the spread, the more inaccurate the shots will be.
local ClipSize = 25 -- Shots in a clip
local ReloadTime = 6 -- Time it takes to reload the tool.
local StartingClips = 10 -- If you want infinit clips, remove the IntValue named "Clips" from the tool.
local SegmentLength = 40 -- How long the shot segments are, or the speed of the shot.
local FadeDelayTime = 1/30


local BarrelPos = CFrame.new(0, 0, - 1.2) -- L, F, U
local Rate = 1/30
local Intangibles = {"Shock", "Bolt", "Bullet", "Plasma", "Effect", "Laser", "Handle", "Effects", "Effect", "Flash"}
local Colors = {BrickColor.new("Bright red"), BrickColor.new("Really red"), BrickColor.new("Dusty Rose"), BrickColor.new("Medium red")}
local FlashColors = {"Medium red", "Dusty Rose", "Bright red", "Really red"}

local Reloading = false
local Debris = game:GetService("Debris")

local Ammo = Tool:FindFirstChild("Ammo")
if Ammo ~= nil then
	Ammo.Value = ClipSize
end
local Clips = Tool:FindFirstChild("Clips")
if Clips ~= nil then
	Clips.Value = StartingClips
end

Tool.Equipped:connect(function()
	Tool.Handle.Fire:Stop()
	Tool.Handle.Reload:Stop()
end)
Tool.Unequipped:connect(function()
	Tool.Handle.Fire:Stop()
	Tool.Handle.Reload:Stop()
end)

function Round(number, decimal)
	decimal = decimal or 0
	local mult = 10^decimal
	return math.floor(number * mult + .5)/mult
end

function CheckIntangible(t)
	for i3, v3 in ipairs(Intangibles) do
		if string.lower(v3) == string.lower(t.Name) or t.Transparency == 1 then
			return true
		end
	end
	return false
end

function Reload()
	Reloading = true
	Tool.Reloading.Value = true
	if Clips ~= nil then
		if Clips.Value > 0 then
			Clips.Value = Clips.Value - 1
		else
			Reloading = false
			Tool.Reloading.Value = false
			return
		end
	end
	Tool.Handle.Reload:Play()
	for i = 1, ClipSize do
		wait(ReloadTime/ClipSize)
		Ammo.Value = i
	end
	Reloading = false
	Tool.Reloading.Value = false
end

function CastRay(startpos, vec, length, ignore, delayifhit)
	if length > 999 then
		length = 999
	end
	hit, endpos2 = game.Workspace:FindPartOnRay(Ray.new(startpos, vec * length), ignore)
	if hit ~= nil then
		if CheckIntangible(hit) then
			if delayifhit then
				wait()
			end
			hit, endpos2 = CastRay(endpos2 + (vec * .01), vec, length - ((startpos - endpos2).magnitude), ignore, delayifhit)
		end
	end
	return hit, endpos2
end

function SendBullet(boltstart, targetpos, fuzzyness, SegmentLength, ignore, clr, damage, fadedelay)
	if Ammo ~= nil then
		if Ammo.Value > 0 then
			Ammo.Value = Ammo.Value - 1
		else
			Reload()
			return
		end
	end
	Tool.Handle.Fire.Pitch = (math.random() * .5) + .75
	Tool.Handle.Fire:Play()
	Tool.DoFireAni.Value = not Tool.DoFireAni.Value
	print(Tool.Handle.Fire.Pitch)
	local boltdist = Range
	local clickdist = (boltstart - targetpos).magnitude
	local targetpos = targetpos + (Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * (clickdist/100) * fuzzyness)
	local boltvec = (targetpos - boltstart).unit
	local totalsegments = math.ceil(boltdist/SegmentLength)
	local lastpos = boltstart
	for i = 1, totalsegments do
		local newpos = (boltstart + (boltvec * (boltdist * (i/totalsegments))))
		local segvec = (newpos - lastpos).unit
		local boltlength = (newpos - lastpos).magnitude
		local bolthit, endpos = CastRay(lastpos, segvec, boltlength, ignore, false)
		DrawBeam(lastpos, endpos, clr, fadedelay)
		if bolthit ~= nil then
			local h = bolthit.Parent:FindFirstChild("Humanoid")
			if h ~= nil then
				local plr = game.Players:GetPlayerFromCharacter(Tool.Parent)
				if plr ~= nil then
					local creator = Instance.new("ObjectValue")
					creator.Name = "creator"
					creator.Value = plr
					creator.Parent = h
				end
				if hit.Parent:FindFirstChild("BlockShot") then
						hit.Parent:FindFirstChild("BlockShot"):Fire(newpos)
						delay(0, function() HitEffect(endpos, 10) end)
				else
					h:TakeDamage(damage)
				end
			else
				delay(0, function() HitEffect(endpos, 5) end)
			end
			break
		end
		lastpos = endpos
		wait(Rate)
	end
end

function DrawBeam(beamstart, beamend, clr, fadedelay)
	local dis = (beamstart - beamend).magnitude
	local laser = Instance.new("Part")
	laser.Name = "Bullet"
	laser.Anchored = true
	laser.CanCollide = false
	laser.Shape = "Block"
	laser.formFactor = "Custom"
	laser.Size = Vector3.new(.2, .2, dis + .2)
	laser.Material = Enum.Material.Plastic
	laser.Locked = true
	laser.TopSurface = 0
	laser.BottomSurface = 0
	laser.BrickColor = clr
	laser.CFrame = CFrame.new(beamend, beamstart) * CFrame.new(0, 0, - dis/2)
	laser.Parent = game.Workspace
	Debris:AddItem(laser, fadedelay)
end

function SigNum(num)
	if num == 0 then return 1 end
	return math.abs(num)/num
end

function MakeSpark(pos)
	local effect = Instance.new("Part")
	effect.Name = "Effect"
	effect.Anchored = false
	effect.CanCollide = false
	effect.Shape = "Block"
	effect.formFactor = "Custom"
	effect.Material = Enum.Material.Plastic
	effect.Locked = true
	effect.TopSurface = 0
	effect.BottomSurface = 0
	effect.BrickColor = Colors[1]
	effect.CFrame = CFrame.new(pos)
	effect.Parent = game.Workspace
 -- effect.velocity = Vector3.new(math.random() * 10, math.random() * 10, math.random() * 10)
 -- effect.Size = Vector3.new(effect.velocity.x, effect.velocity.y, effect.velocity.z)
	local effectVel = Instance.new("BodyVelocity")
	effectVel.maxForce = Vector3.new(99999, 99999, 99999)
	effectVel.velocity = Vector3.new(math.random() * 15 * SigNum(math.random( - 10, 10)), 		math.random() * 15 * SigNum(math.random( - 10, 10)), math.random() * 15 * SigNum(math.random( - 10, 10)))
	effectVel.Parent = effect
	effect.Size = Vector3.new(math.abs(effectVel.velocity.x)/20, math.abs(effectVel.velocity.y)/20, math.abs(effectVel.velocity.z)/20)
	wait()
	effectVel:Destroy()
	local effecttime = .25
	Debris:AddItem(effect, effecttime * 2)
	local startTime = time()
	while time() - startTime < effecttime do
		if effect ~= nil then
			effect.Transparency = (time() - startTime)/effecttime
		end
		wait()
	end
	if effect ~= nil then
		effect.Parent = nil
	end
end

function HitEffect(pos)

	for i = 0, 10, 1 do
		local thread = coroutine.create(MakeSpark)
		coroutine.resume(thread, pos)
	end
	
end

Tool.Down.Changed:connect(function()
	while Tool.Down.Value and check and not Reloading do
		check = false
		local humanoid = Tool.Parent:FindFirstChild("Humanoid")
		local plr1 = game.Players:GetPlayerFromCharacter(Tool.Parent)
		if humanoid ~= nil and plr1 ~= nil then
			if humanoid.Health > 0 then
				spos1 = (Tool.Handle.CFrame * BarrelPos).p
				delay(0, function() SendBullet(spos1, Tool.Aim.Value, Spread, SegmentLength, Tool.Parent, Colors[1], GunDamage, FadeDelayTime) end)
			else
				check = true
				break
			end
		else
			check = true
			break
		end
		wait(FireRate)
		check = true
		if not Automatic then
			break
		end
	end
end)
