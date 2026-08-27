-- Made by Stickmasterluke
 -- edited by fusroblox
local GoreOn=false
function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do print("2waiting for " .. child) wait() end
	return parent[child]
end

local GLib = require(206209239)
 
local GunObject = {
	Tool = script.Parent,
	Handle = WaitForChild(script.Parent,'Handle'),
	check = true,
	
	GunDamage = 15, -- Base output damage per shot.
	FireRate = .12, -- How often the weapon can fire.
	Automatic = true, -- hold down to continue firing
	Range = 250, -- Max distance that the weapon can fire.
	Spread = 7, -- The bigger the spread, the more inaccurate the shots will be.
	ClipSize = 50, -- Shots in a clip
	ReloadTime = 3, -- Time it takes to reload the tool.
	StartingClips = 10, -- If you want infinit clips, remove the IntValue named "Clips" from the tool.
	SegmentLength = 40, -- How long the shot segments are, or the speed of the shot.
	FadeDelayTime = 1/30,
	
	
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
	DownVal=WaitForChild(script.Parent, 'Down'),
	AimVal=WaitForChild(script.Parent, 'Aim'),
	ReloadingVal=WaitForChild(script.Parent, 'Reloading'),
	DoFireAni = WaitForChild(script.Parent,'DoFireAni'),
	
	--handlechildren
	Fire,
	
}

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
	local tshellmesh=WaitForChild(script.Parent,'BulletMesh'):Clone()
	tshellmesh.Parent=tshell
	self.ShellPart = tshell

	self.DownVal.Changed:connect(function()
		while self.DownVal.Value and self.check and not self.Reloading do
			self.check = false
			local humanoid = self.Tool.Parent:FindFirstChild("Humanoid")
			local plr1 = game.Players:GetPlayerFromCharacter(self.Tool.Parent)
			if humanoid ~= nil and plr1 ~= nil then
				if humanoid.Health > 0 then
					local spos1 = (self.Tool.Handle.CFrame * self.BarrelPos).p
					delay(0, function() self:SendBullet(spos1, self.AimVal.Value, self.Spread, self.SegmentLength, self.Tool.Parent, self.Colors[1], self.GunDamage, self.FadeDelayTime) end)
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
	end)

	self.ReloadingVal.Changed:connect(function() if self.ReloadingVal.Value then self:Reload() end end)

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

function KnockOffHats(tchar)
	for _,i in pairs(tchar:GetChildren()) do
		if i:IsA('Hat') then
			i.Parent=game.Workspace
		end
	end
end

function KnockOffTool(tchar)
	for _,i in pairs(tchar:GetChildren()) do
		if i:IsA('Tool') then
			i.Parent=game.Workspace
		end
	end
end

function GunObject:SendBullet(boltstart, targetpos, fuzzyness, SegmentLength, ignore, clr, damage, fadedelay)
	if self.Ammo.Value <=0 then return end
	self.Ammo.Value = self.Ammo.Value - 1
	self:SpawnShell()
	self.Fire.Pitch = (math.random() * .5) + .75
	self.Fire:Play()
	self.DoFireAni.Value = not self.DoFireAni.Value
	print(self.Fire.Pitch)
	local boltdist = self.Range
	local clickdist = (boltstart - targetpos).magnitude
	local targetpos = targetpos + (Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * (clickdist/100))
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
						delay(0, function() self:HitEffect(endpos, bolthit,5) end)
				else
					if(hit.Name=='Head') then
						KnockOffHats(hit.Parent)
					end
					if GoreOn then delay(0,function() self:HitEffect(endpos, bolthit,20) end) end
					if not GLib.IsTeammate(GLib.GetPlayerFromPart(script), GLib.GetPlayerFromPart(h)) then
						GLib.TagHumanoid(GLib.GetPlayerFromPart(script), h, 1)
						h:TakeDamage(damage)
					end
				end
			else
				delay(0, function() self:HitEffect(endpos, bolthit,5) end)
			end
			break
		end
		lastpos = endpos
		wait(Rate)
	end

	if self.Ammo.Value < 1 then
		self:Reload()
	end

end



function GunObject:MakeSpark(pos,p)
	local effect=self.SparkEffect:Clone()
	effect.BrickColor = p.BrickColor
	effect.Material = p.Material
	effect.Transparency = p.Transparency
	effect.Reflectance = p.Reflectance
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

function GunObject:HitEffect(pos,p,numSparks)
	for i = 0, numSparks, 1 do
		Spawn(function() self:MakeSpark(pos,p) end)
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
	print(hitObj.Name)
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
	tlaser.Size = Vector3.new(.1, .1, dis + .2)
	tlaser.CFrame = CFrame.new((beamend+beamstart)/2, beamstart) * CFrame.new(0, 0, - dis/2)
	tlaser.Parent = game.Workspace
	game.Debris:AddItem(tlaser, fadedelay)
end

--[[/Static functions]]


GunObject:Initialize()