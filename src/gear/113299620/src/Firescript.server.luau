--[[
	Fixed by ArceusInator.  Fixed animation sticking, fixed first-person mode, fixed flopping around after you unequip.
--]]

-- Made by Stickmasterluke
 -- edited by fusroblox
local GoreOn=false
function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do wait() end
	return parent[child]
end
 
local GunObject = {
	Tool = script.Parent,
	Handle = WaitForChild(script.Parent,'Handle'),
	check = true,
	
	GunDamage = 35, -- Base output damage per shot.
	FireRate = .5, -- How often the weapon can fire.
	Automatic = false, -- hold down to continue firing
	Range = 250, -- Max distance that the weapon can fire.
	Spread = 1, -- The bigger the spread, the more inaccurate the shots will be.
	ClipSize = 8, -- Shots in a clip
	ReloadTime = 3, -- Time it takes to reload the tool.
	StartingClips = 10, -- If you want infinit clips, remove the IntValue named "Clips" from the tool.
	SegmentLength = 5, -- How long the shot segments are, or the speed of the shot.
	FadeDelayTime = 1/30,
	MouseDown = false,
	MouseTarget = Vector3.new(),
	
	
	BarrelPos = CFrame.new(0, 0, - 1.2), -- L, F, U
	Rate = 1/30,
	--local Colors = {BrickColor.new("Bright red"), BrickColor.new("Really red"), BrickColor.new("Dusty Rose"), BrickColor.new("Medium red")}
	Colors = {BrickColor.new("Bright yellow"),BrickColor.new("Mid gray"), BrickColor.new("Medium stone grey"), BrickColor.new("Dark stone grey")},
	FlashColors = {"Medium red", "Dusty Rose", "Bright red", "Really red"},
	
	Reloading = false,
	Debris = game:GetService("Debris"),
	Ammo,
	Clips,
	LaserObj,
	SparkEffect,
	ShellPart,
	--tool children
	ReloadingVal=WaitForChild(script.Parent, 'Reloading'),
	DoFireAni = WaitForChild(script.Parent,'DoFireAni'),
	ScreamingSound = WaitForChild(script.Parent,'Screaming'),
	
	--handlechildren
	Fire,
	
}
GunObject.Tool.MouseDown.OnServerEvent:connect(function(client) 
	if client.Character == GunObject.Tool.Parent then 
		GunObject.MouseDown = true
		if GunObject.DownChanged then
			GunObject.DownChanged()
		end
	end
end)
GunObject.Tool.MouseUp.OnServerEvent:connect(function(client)
	if client.Character == GunObject.Tool.Parent then
		GunObject.MouseDown = false
		if GunObject.DownChanged then
			GunObject.DownChanged()
		end
	end
end)
GunObject.Tool.MousePos.OnServerEvent:connect(function(client, pos)
	if client.Character == GunObject.Tool.Parent then
		GunObject.MouseTarget = pos
	end
end)

--[[Member functions]]

function GunObject:Initialize()

	self.Fire=WaitForChild(self.Handle, 'Fire')
	
	self.Ammo = self.Tool:FindFirstChild("Ammo")
	if self.Ammo ~= nil then
		self.Ammo.Value = self.ClipSize
	end
	self.Clips = self.Tool:FindFirstChild("Clips")
	if self.Clips ~= nil then
		self.Clips.Value = self.StartingClips
	end
	self.Tool.Equipped:connect(function()
		self.Tool.Handle.Fire:Stop()
		self.Tool.Handle.Reload:Stop()
	end)
	self.Tool.Unequipped:connect(function()
		self.Tool.Handle.Fire:Stop()
		self.Tool.Handle.Reload:Stop()
	end)
	self.LaserObj = Instance.new("Part")
	self.LaserObj.Name = "Bullet"
	self.LaserObj.Anchored = true
	self.LaserObj.CanCollide = false
	self.LaserObj.Shape = "Block"
	self.LaserObj.formFactor = "Custom"
	self.LaserObj.Material = Enum.Material.Plastic
	self.LaserObj.Locked = true
	self.LaserObj.TopSurface = 0
	self.LaserObj.BottomSurface = 0
	local tshellmesh=WaitForChild(script.Parent,'BulletMesh'):Clone()
	tshellmesh.Parent=self.LaserObj

	local tSparkEffect = Instance.new("Part")
	tSparkEffect.Name = "Effect"
	tSparkEffect.Anchored = false
	tSparkEffect.CanCollide = false
	tSparkEffect.Shape = "Block"
	tSparkEffect.formFactor = "Custom"
	tSparkEffect.Material = Enum.Material.Plastic
	tSparkEffect.Locked = true
	tSparkEffect.TopSurface = 0
	tSparkEffect.BottomSurface = 0
	self.SparkEffect=tSparkEffect

	local tshell = Instance.new('Part')
	tshell.Name='effect'
	tshell.FormFactor='Custom'
	tshell.Size=Vector3.new(1, 0.4, 0.33)
	tshell.BrickColor=BrickColor.new('Bright yellow')
	self.ShellPart = tshell

	GunObject.DownChanged = function()
		while GunObject.MouseDown and self.check and not self.Reloading do
			self.check = false
			local humanoid = self.Tool.Parent:FindFirstChild("Humanoid")
			local plr1 = game.Players:GetPlayerFromCharacter(self.Tool.Parent)
			if humanoid ~= nil and plr1 ~= nil then
				if humanoid.Health > 0 then
					local spos1 = (self.Tool.Handle.CFrame * self.BarrelPos).p
					delay(0, function() self:SendBullet(spos1, GunObject.MouseTarget, self.Spread, self.SegmentLength, self.Tool.Parent, self.Colors[1], self.GunDamage, self.FadeDelayTime) end)
				else
					self.check = true
					break
				end
			else
				self.check = true
				break
			end
			wait(self.FireRate)
			self.check = true
			if not self.Automatic then
				break
			end
		end
	end

end





function GunObject:Reload()
	self.Reloading = true
	self.ReloadingVal.Value = true
	if self.Clips ~= nil then
		if self.Clips.Value > 0 then
			self.Clips.Value = Clips.Value - 1
		else
			self.Reloading = false
			self.ReloadingVal.Value = false
			return
		end
	end
	self.Tool.Handle.Reload:Play()
	for i = 1, self.ClipSize do
		wait(self.ReloadTime/self.ClipSize)
		self.Ammo.Value = i
	end
	self.Reloading = false
	self.Tool.Reloading.Value = false
end

function GunObject:SpawnShell()
	local tshell=self.ShellPart:Clone()
	tshell.CFrame=self.Handle.CFrame
	tshell.Parent=Workspace
	game.Debris:AddItem(tshell,2)
end


local function weldBetween(a, b)
    local weld = Instance.new("Weld")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse() * a.CFrame
    weld.Parent = a
    return weld;
end

local function NumNormal(n)
	return n == 0 and 0 or n/math.abs(n)
end


function LocktoSurface(part,mpart)
	local point = mpart.CFrame.p
	local p = part.CFrame:pointToObjectSpace(point)
	local s = part.Size*.5
	local ax,ay,az = math.abs(p.x/s.x),math.abs(p.y/s.y),math.abs(p.z/s.z)
	local max_side = Vector3.new(
	(ax>ay and ax>az) and 1 or 0,
	(ay>ax and ay>az) and 1 or 0,
	(az>ax and az>ay) and 1 or 0
	)
	point = part.CFrame:pointToObjectSpace(point)
	if max_side.x~=0 then
		point= Vector3.new(s.x*NumNormal(p.x),point.y,point.z)
	elseif max_side.y~=0 then
		point= Vector3.new(point.x,s.y*NumNormal(p.y),point.z)
	elseif max_side.z~=0 then
		point= Vector3.new(point.x,point.y,s.z*NumNormal(p.z))
	end
	
	local normal =  Vector3.new(NumNormal(p.x),NumNormal(p.y),NumNormal(p.z)) * max_side
	
	mpart.CFrame = CFrame.new(part.CFrame:pointToWorldSpace(point+(normal*1.4)))
			*CFrame.new(Vector3.new(0,0,0),part.CFrame:vectorToWorldSpace(-1*normal))
			*CFrame.Angles(0,0,0)
	--mpart.Anchored = true	
	weldBetween(part,mpart)
end


function GunObject:AttachSnake(part,human,lastpos)
	local lockedPart = self.LaserObj:Clone()
	local hitSound = self.ScreamingSound:Clone()
	hitSound.Parent = lockedPart
	lockedPart.Size = Vector3.new(.2, .2, .2)
	lockedPart.CanCollide= false
	lockedPart.CFrame = CFrame.new()+lastpos
	lockedPart.Parent = game.Workspace
	LocktoSurface(part,lockedPart)
	lockedPart.Anchored = false
	wait(0)
	hitSound:Play()	
	for i=0,10,1 do
		human.Sit = true
		human:TakeDamage(5)
		wait(.5)
		human.Sit = false
	end
	lockedPart:Destroy()
end

function GunObject:SendBullet(boltstart, targetpos, fuzzyness, SegmentLength, ignore, clr, damage, fadedelay)
	if self.Ammo.Value <=0 then return end
	self.Ammo.Value = self.Ammo.Value - 1
	self:SpawnShell()
	self.Fire.Pitch = (math.random() * .5) + .75
	self.Fire:Play()
	self.DoFireAni.Value = not self.DoFireAni.Value
	local boltdist = self.Range
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
		DrawBeam(lastpos, endpos, clr, fadedelay, self.LaserObj)
		if bolthit ~= nil then
			local h = bolthit.Parent:FindFirstChild("Humanoid")
			if h ~= nil then
				local plr = game.Players:GetPlayerFromCharacter(self.Tool.Parent)
				if plr ~= nil then
					local creator = Instance.new("ObjectValue")
					creator.Name = "creator"
					creator.Value = plr
					creator.Parent = h
				end
				if hit.Parent:FindFirstChild("BlockShot") then
						hit.Parent:FindFirstChild("BlockShot"):Fire(newpos)
						delay(0, function() self:HitEffect(endpos, BrickColor.new('Medium stone grey'),5) end)
				else
					Spawn(function() self:AttachSnake(bolthit,h,lastpos) end)
					if(hit.Name=='Head') then
						if GoreOn then delay(0,function() self:HitEffect(endpos, BrickColor.new('Bright red'),30) end) end
						--h:TakeDamage(10000000000)
					else
						if GoreOn then delay(0,function() self:HitEffect(endpos, BrickColor.new('Bright red'),20) end) end
						--h:TakeDamage(damage)
					end
				end
			else
				delay(0, function() self:HitEffect(endpos, BrickColor.new('Medium stone grey'),5) end)
			end
			break
		end
		lastpos = endpos
		wait(self.Rate)
	end

	if self.Ammo.Value < 1 then
		self:Reload()
	end

end



function GunObject:MakeSpark(pos,tcolor)
	local effect=self.SparkEffect:Clone()
	effect.BrickColor = tcolor
	effect.CFrame = CFrame.new(pos)
	effect.Parent = game.Workspace
	local effectVel = Instance.new("BodyVelocity")
	effectVel.maxForce = Vector3.new(99999, 99999, 99999)
	effectVel.velocity = Vector3.new(math.random() * 15 * SigNum(math.random( - 10, 10)), 		math.random() * 15 * SigNum(math.random( - 10, 10)), math.random() * 15 * SigNum(math.random( - 10, 10)))
	effectVel.Parent = effect
	effect.Size = Vector3.new(math.abs(effectVel.velocity.x)/30, math.abs(effectVel.velocity.y)/30, math.abs(effectVel.velocity.z)/30)
	wait()
	effectVel:Destroy()
	local effecttime = .5
	game.Debris:AddItem(effect, effecttime * 2)
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

function GunObject:HitEffect(pos,tcolor,numSparks)
	for i = 0, numSparks, 1 do
		Spawn(function() self:MakeSpark(pos,tcolor) end)
	end
	
end

--[[/Member functions]]


--[[Static functions]]

function Round(number, decimal)
	decimal = decimal or 0
	local mult = 10^decimal
	return math.floor(number * mult + .5)/mult
end

function SigNum(num)
	if num == 0 then return 1 end
	return math.abs(num)/num
end

--this is a little bad, but shouldn't really be part of the 'class' of the gun
local Intangibles = {shock=1, bolt=1, bullet=1, plasma=1, effect=1, laser=1, handle=1, effects=1, flash=1,}
function CheckIntangible(hitObj)
	return Intangibles[(string.lower(hitObj.Name))] or hitObj.Transparency == 1
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

function DrawBeam(beamstart, beamend, clr, fadedelay, templatePart)
	local dis = 2 --(beamstart - beamend).magnitude
	local tlaser=templatePart:Clone()
	tlaser.BrickColor = clr
	tlaser.Size = Vector3.new(.5, .5, dis + .2)
	tlaser.CFrame = CFrame.new((beamend+beamstart)/2, beamend) * CFrame.new(0, 0, -dis/2)
	tlaser.Parent = game.Workspace
	game.Debris:AddItem(tlaser, fadedelay)
end

--[[/Static functions]]


GunObject:Initialize()