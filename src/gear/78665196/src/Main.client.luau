local function class(name)
	local def = {}
	getfenv(0)[name] = def
	return function(ctor, static)
		local nctor = function(...)
			local this = {}
			if ctor then
				ctor(this, ...)
			end
			return this
		end
		getfenv(0)['Create'..name] = nctor
		if static then static(def) end
	end
end

local function Create(ty)
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

--[[----------------------------------------------------------------------------
AnimationProvider
	Manages animations.

	CreateAnimationProvider(animations)
		Returns a new AnimationProvider instance.
		`animations` is a table containing identity/asset_id pairs.
		`asset_id` may be a string (Content) or an integer.
	AnimationProvider:LoadHumanoid(humanoid)
		Loads the animations into `humanoid`.
	AnimationProvider:GetAnimation(identity)
		Returns an AnimationTrack.
		May only be called after LoadHumanoid.
	AnimationProvider:StopAnimations()
		Stops all animations.
]]
class'AnimationProvider'(function(def,anim_ids)
	local animations = {}
	local animationTracks = {}
	local catcherCallbacks = {}
	local keyframeCatchers = {}
	local workingHumanoid

	for name,id in pairs(anim_ids) do
		animations[name] = Create'Animation'{
			Name = name;
			AnimationId = type(id) == "number" and ("rbxassetid://"..id) or id;
			Archivable = false;
		}
	end

	function def:LoadHumanoid(humanoid)
		if humanoid ~= workingHumanoid then
			workingHumanoid = humanoid
			for name,anim in pairs(animations) do
				local old_track = animationTracks[name]
				if old_track then
					old_track:Stop()
					old_track:Destroy()
					if keyframeCatchers[name] then
						keyframeCatchers[name] = nil
					end
				end

				local track = humanoid:LoadAnimation(anim)
				animationTracks[name] = track
				if catcherCallbacks[name] then
					local catcher = CreateKeyframeCatcher(track)
					keyframeCatchers[name] = catcher
					catcher:SetCallbacks(catcherCallbacks[name])
				end
			end
		end
	end

	function def:GetAnimation(name)
		if not workingHumanoid then
			error("GetAnimation: humanoid has not been loaded",2)
		end
		return animationTracks[name]
	end

	function def:StopAnimations(...)
		for name,track in pairs(animationTracks) do
			track:Stop(...)
		end
	end

	-- lazy get
	setmetatable(def,{__index = animationTracks})
end)

--[[
SoundProvider
	Manages sounds.

	CreateSoundProvider(sounds)
		Returns a new SoundProvider.
		`sounds` is a table containing identity/asset_id pairs.
		`asset_id` may be a string (Content) or an integer.
	SoundProvider:SetParent(parent)
		Sets the parent of all the sounds at once. Can be nil.
	SoundProvider:GetSound(identity)
		Returns a Sound.
	SoundProvider:StopSounds()
		Stops all sounds.
	SoundProvider:Fade(identity, goal, time, delta)
		Applies a fading effect to a Sound, starting with the current volume.
		`goal` is the volume to reach by the end of the transition.
		`time` is the amount of time the transition should take, in seconds.
		Optionally, `delta` is a function that transforms the progress of the fade (for non-linear transitions)
]]
class'SoundProvider'(function(def,sound_ids)
	local sounds = {}

	for name,id in pairs(sound_ids) do
		sounds[name] = Create'Sound'{
			Name = name;
			SoundId = type(id) == "number" and ("rbxassetid://"..id) or id;
			Archivable = false;
		}
	end

	function def:SetParent(parent)
		for name,sound in pairs(sounds) do
			sound.Parent = parent
		end
	end

	function def:GetSound(name)
		return sounds[name]
	end

	function def:StopSounds()
		for name,sound in pairs(sounds) do
			sound:Stop()
		end
	end

	function def:Fade(name,g,t,delta)
		local sound = sounds[name]
		delta = delta or function(n) return n end
		if sound then
			local s = sound.Volume
			local i = 0
			while i < 1 do
				i = i + wait()/t
				sound.Volume = (g-s)*delta(i)+s
			end
			sound.Volume = g
		else
			error("SoundProvider::Fade: no such sound named `"..name.."`",2)
		end
	end

	-- lazy get
	setmetatable(def,{__index = sounds})
end)

--[[
ThreadID
	Makes sure new threads override old ones.

	CreateThreadID()
		Returns a new ThreadID.
	ThreadID:Request()
		Returns a new ID and increments the current one.
	ThreadID:Assert(id)
		Returns whether the thread's ID equals the current one.
	ThreadID:Reset()
		Reset the current ID.
]]
class'ThreadID'(function(def)
	local thread_id = 0

	function def:Assert(id)
		return thread_id == id
	end

	function def:Request()
		thread_id = thread_id + 1
		return thread_id
	end

	function def:Reset()
		thread_id = 0
	end
end)

--[[
	WalkSpeedManager
		Manages a Humanoid's WalkSpeed.
		When the walkspeed is set externally (not by this instance), the new value will become the base walkspeed.
		However, the walkspeed can be locked. If so, the walkspeed will be reverted if it has been changed externally.
		This allows the tool to be compatible with, say, a speed potion.

	CreateWalkSpeedManager()
		Returns a new WalkSpeedManager.
	WalkSpeedManager:SetHumanoid(humanoid)
		Sets the humanoid and sets its WalkSpeed as the base.
	WalkSpeedManager:Set(walkspeed)
		Sets and locks the humanoid's walkspeed.
	WalkSpeedManager:Reset()
		Unlocks and resets the humanoid's walkspeed to the base walkspeed.
	WalkSpeedManager:GetBase()
		Returns the base walkspeed.
]]
class'WalkSpeedManager'(function(def)
	local baseWalkSpeed = 16
	local currentWalkSpeed = 16
	local locked = false
	local settingInternal = false
	local humanoid
	local changed

	function def:SetHumanoid(hum)
		humanoid = hum
		locked = false
		if changed then changed:disconnect() end
		if hum then
			baseWalkSpeed = hum.WalkSpeed
			currentWalkSpeed = baseWalkSpeed
			changed = hum.Changed:connect(function(p)
				if p == "WalkSpeed" and not settingInternal then
					-- something external is modifying the walkspeed; use that as the base
					baseWalkSpeed = hum.WalkSpeed
					if locked then
						settingInternal = true
						hum.WalkSpeed = currentWalkSpeed
						settingInternal = false
					end
				end
			end)
		end
	end

	function def:Set(ws)
		if humanoid then
			locked = true
			currentWalkSpeed = ws
			settingInternal = true
			humanoid.WalkSpeed = ws
			settingInternal = false
		end
	end

	function def:Reset()
		if humanoid then
			currentWalkSpeed = baseWalkSpeed
			settingInternal = true
			humanoid.WalkSpeed = baseWalkSpeed
			settingInternal = false
			locked = false
		end
	end

	function def:GetBase()
		return baseWalkSpeed
	end
end)

--[[
Sequencer
	Calls functions in a sequence through activation of a single function.

	:SetSequenceMap(map)
		Sets the sequence of functions to use.
	:SetMinInterval(interval)
		Sets the minimum amount of time allowed between activations.
	:SetResetDelay(delay,time)
		Sets the amount of time to wait after the most recent activation before the sequence is reset.
		`delay` is the time to wait after the last activation.
		`time` is used when comparing the current time with the last activation time.
		If `time` is greater than or close to `delay`, the sequence (probably) wont reset.
	:Activate(...)
		Calls the next function in the sequence. If the end of the sequence is reached, it wraps back to the beginning.
		The first value passed to the function is the current sequence index. Subsequent arguments are the values passed to Activate.
]]
class'Sequencer'(function(def)
	local min_interval = 0
	local reset_delay = 0
	local reset_time = 0
	local seq_map = {}

	local seq_index = 0
	local activate_time = 0

	function def:SetSequenceMap(map)
		seq_map = map
		if seq_index > #map then
			seq_index = 0
		end
	end

	function def:SetMinInterval(interval)
		min_interval = interval
	end

	function def:SetResetDelay(delay,time)
		reset_delay = delay
		reset_time = time
	end

	local function act(...)
		local t = tick()
		if t-activate_time > min_interval then
			activate_time = t
			seq_index = seq_index + 1 > #seq_map and 1 or seq_index + 1
			if seq_map[seq_index] then
				coroutine.wrap(seq_map[seq_index])(seq_index,...)
			end
		end
		wait(reset_delay)
		if tick()-activate_time > reset_time then
			seq_index = 0
		end
	end

	function def:Activate(...)
		coroutine.wrap(act)(...)
	end
end)

--[[
Particle
	Manages a particle.
	
	CreateParticle(constructor)
		Returns a new Particle.
		`constructor` is a function that creates a particle. It should return an Instance.
	:SetCountLimit(count)
		Sets the maximum number of particles that can exist at one time.
	:SetTimeLimit(time)
		Sets the maximum time a paricle is allowed to exist.
		Setting below 0 lets it exist forever.
	:Spawn(...)
		Spawns a particle.
		Received arguments are passed to the `constructor` function.
		Returns the spawned particle.
	:Despawn(particle)
		Removes a spawned particle.
]]
class'Particle'(function(def,newParticle)
	local Debris = Game:GetService("Debris")
	local queue = {}
	local changed = {}
	local maxParticles = 20
	local maxTime = 5

	local function search_remove(t,k)
		local i = 1
		while i <= #t do
			if t[i] == k then
				table.remove(t,i)
			else
				i = i + 1
			end
		end
	end

	function def:SetCountLimit(mp)
		maxParticles = mp
	end

	function def:SetTimeLimit(mt)
		maxTime = mt
	end

	function def:Despawn(particle)
		if changed[particle] then
			changed[particle]:disconnect()
			changed[particle] = nil
		end
		search_remove(queue,particle)
		particle:Destroy()
	end

	function def:Spawn(...)
		if #queue < maxParticles then
			local particle = newParticle(...)
			if maxTime >= 0 then Debris:AddItem(particle,maxTime) end
			queue[#queue+1] = particle
			changed[particle] = particle.AncestryChanged:connect(function(c,p)
				if p == nil then
					self:Despawn(particle)
				end
			end)
		end
		return particle
	end

end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Tiny Event Manager; Add: [[Event.EventName = (event)]]; Remove: [[Disconnect("EventName",...)]]
local Event = {}
local function Disconnect(...)
	for _,name in pairs{...} do
		if Event[name] then
			Event[name]:disconnect()
			Event[name] = nil
		end
	end
end

-- get an object; make it if it doesn't exist
local function GetMake(parent,name,type)
	local object = parent:FindFirstChild(name)
	if not object then
		object = Create(type){Name=name}
		object.Parent = parent
	end
	return object
end

-- wait until child exists; return child
local function WaitForChild(parent,name)
	while not parent:FindFirstChild(name) do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end

-- get a sibling humanoid of object; by humanoid, not by name
local function GetHumanoid(object)
	if object and object.Parent then
		for i,v in pairs(object.Parent:GetChildren()) do
			if v:IsA"Humanoid" then
				return v
			end
		end
	end
	return nil
end

-- get the parent character from an object; verified by GetHumanoid
local function GetCharacter(object)
	local humanoid = GetHumanoid(object)
	if humanoid then
		return object.Parent,humanoid
	end
	return nil
end

-- make a joint, if the objects exist
local function AttemptJoint(x,y,c0,c1)
	if x and y then
		local weld = Instance.new("Motor6D")
		weld.Part0 = x
		weld.Part1 = y
		if c0 then weld.C0 = c0 end
		if c1 then weld.C1 = c1 end
		weld.Parent = x
		return weld
	end
end

-- destroy a joint used only by the two objects
local function KillJoint(x,y)
	if x and y then
		for i,v in pairs(x:GetChildren()) do
			if v:IsA"Motor6D" then
				if v.Part0 == x and v.Part1 == y then
					v:Destroy()
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-----SETTINGS-------------------------------------------------------------------
--Damage
	local sword_damage			= 5
	local charged_sword_damage	= 10
	local arc_damage			= 10
	local charged_arc_damage	= 20

--Charged Attack
	local charge_time			= 6		-- how long it takes to fully charge
	local charge_attack_time	= 8		-- how long charged attack lasts (at full charge)
	local cooldown_time			= 12	-- how long before sword can be charged again (at full charge)
	local charge_walk_mult		= 1.5	-- how much to multiply the base walkspeed when charged

--Short-term Fatigue
	-- min slash interval increases after every slash
	-- more consecutive slashes means longer recovery time
	local fatigue_enabled	= true
	local fatigue_increment	= 0.05		-- controls stamina (seconds added per slash)
	local rest_factor		= 16		-- controls recovery time (multiplied by current fatigue)

--Moon Arc Effect
	local arc_angle_variance	= Vector3.new(2,12,6)	-- degrees
	local arc_distance_variance	= 0.5					-- distance from torso
	local arc_max_speed			= 0.5					-- initial outward speed (gets decayed)
	local arc_time				= 0.3					-- how long arc should exist
	local arc_decay				= 2						-- exp decay factor

--Sphere Effect
	-- a growing sphere during charge
	-- not sure if looks good
	local sphere_enabled	= false
	local sphere_radius		= 5.3	-- radius at end of effect
	local sphere_magnitude	= 2		-- wavyness
	local sphere_time		= 4		-- wavyness time scale
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Debris = Game:GetService("Debris")
local Lighting = Game:GetService("Lighting")

local Tool = script.Parent
local Handle = WaitForChild(Tool,"Handle")
local Character,Humanoid

local DamageBin = GetMake(Tool,"DamageBin","Configuration")
local Damage = sword_damage
local ArcDamage = arc_damage

local MoonArcTemplate = Create'Part'{
	Name = "MoonArc";
	Anchored = true;
	CanCollide = false;
	Transparency = 1;
	FormFactor = Enum.FormFactor.Symmetric;
	TopSurface = Enum.SurfaceType.Smooth;
	BottomSurface = Enum.SurfaceType.Smooth;
	Size = Vector3.new(9,1,4);
	Create'Decal'{
		Name = "DecalTop";
		Face = Enum.NormalId.Top;
		Texture = "http://www.roblox.com/asset/?id=74132306";
	};
	Create'Decal'{
		Name = "DecalBottom";
		Face = Enum.NormalId.Bottom;
		Texture = "http://www.roblox.com/asset/?id=74132306";
	};
	Create'BlockMesh'{
		Scale = Vector3.new(1,0,1);
	};
};
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=74132306")

local WalkSpeed = CreateWalkSpeedManager()

local Animation = CreateAnimationProvider{
	SlashLeft		= "http://www.roblox.com/asset/?id=74909537";
	SlashRight		= "http://www.roblox.com/asset/?id=74909551";
	Charge			= "http://www.roblox.com/asset/?id=74909500";
	SlashSides		= "http://www.roblox.com/asset/?id=74909569";
	SlashForward	= "http://www.roblox.com/asset/?id=74909528";
	DualSword		= "http://www.roblox.com/asset/?id=74909522";
}                   

local Sound = CreateSoundProvider{
	Slash	= "http://www.roblox.com/asset/?id=45885030";
	Charge	= "http://www.roblox.com/asset/?id=75421988";
}
Sound:SetParent(Handle)
Sound.Slash.Volume = 0.25
Sound.Charge.Volume = 0
Sound.Charge.Looped = true

local MoonParticleTemplate = Create'Part'{
	TopSurface = Enum.SurfaceType.Smooth;
	Reflectance = 2;
	BrickColor = BrickColor.new(1001);
	Locked = true;
	Anchored = true;
	CanCollide = false;
	Size = Vector3.new(1, 1, 8);
	FormFactor = Enum.FormFactor.Custom;
	BottomSurface = Enum.SurfaceType.Smooth;
	Name = "MoonParticle";
--[[
	Create'RocketPropulsion'{
		CartoonFactor = 1;
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge);
		TurnP = 100000;
		MaxSpeed = 500;
		MaxThrust = math.huge;
		ThrustD = 100;
		Name = "Rocket";
		ThrustP = 1000;
		TargetRadius = 8;
	};
--]]
	Create'SpecialMesh'{
		MeshType = Enum.MeshType.Sphere;
	};
};
local MoonParticle = CreateParticle(function()
	local pos = Handle.Position
	local dir = Lighting:GetMoonDirection()
	local particle = MoonParticleTemplate:Clone()
	particle.Archivable = false
	local r = Vector2.new(math.random(-14,14),math.random(-14,14))
	if r.magnitude > 14 then r = r.unit*14 end
	local start = CFrame.new(pos,pos-dir) * CFrame.new(r.x,r.y,200)
	particle.CFrame = start
	Spawn(function()
		while ((particle.CFrame*CFrame.new(0,0,-4)).p-Handle.Position).magnitude > 8 do
			particle.CFrame = CFrame.new(particle.Position,Handle.Position) * CFrame.new(0,0,-8)
			wait()
		end
		particle:Destroy()
	end)
	particle.Parent = Character
--[[
	particle.Rocket.Target = Handle
	particle.Rocket.ReachedTarget:connect(function()
		particle:Destroy()
	end)
	particle.Parent = Workspace
	particle.Rocket:Fire()
]]
	return particle
end)
MoonParticle:SetCountLimit(10)
MoonParticle:SetTimeLimit(10)

local SmallParticleTemplate = Create'Part'{
	TopSurface = Enum.SurfaceType.Smooth;
	Reflectance = 2;
	BrickColor = BrickColor.new(1001);
	Locked = true;
	Anchored = true;
	CanCollide = false;
	Size = Vector3.new(0.5, 0.5, 1);
	FormFactor = Enum.FormFactor.Custom;
	BottomSurface = Enum.SurfaceType.Smooth;
	Name = "SmallParticle";
	Create'SpecialMesh'{
		MeshType = Enum.MeshType.Sphere;
	};
--[[
	Create'RocketPropulsion'{
		CartoonFactor = 1;
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge);
		TurnP = 100000;
		ThrustD = 50;
		Name = "Rocket";
		ThrustP = 1000;
		TargetRadius = 1;
	};
--]]
};
local SmallParticle = CreateParticle(function()
	local pos = Handle.Position
	local particle = SmallParticleTemplate:Clone()
	particle.Archivable = false
	local r = Vector3.new(math.random(-12,12),math.random(-12,12),math.random(-12,12))
	if r.magnitude > 12 then r = r.unit*12 end
	local start = CFrame.new(pos+r,pos)
	particle.CFrame = start
	Spawn(function()
		while (particle.Position-Handle.Position).magnitude > 2 do
			particle.CFrame = CFrame.new(particle.Position,Handle.Position) * CFrame.new(0,0,-1)
			wait()
		end
		particle:Destroy()
	end)
	particle.Parent = Character
--[[
	particle.Rocket.Target = Handle
	particle.Rocket.ReachedTarget:connect(function()
		particle:Destroy()
	end)
	particle.Parent = Workspace
	particle.Rocket:Fire()
]]
	return particle
end)
SmallParticle:SetCountLimit(10)
SmallParticle:SetTimeLimit(10)

local SphereParticleTemplate = Create'Part'{
	TopSurface = Enum.SurfaceType.Smooth;
	Reflectance = 0.75;
	Transparency = 0.9;
	BrickColor = BrickColor.new(1001);
	Size = Vector3.new(1, 1, 1);
	FormFactor = Enum.FormFactor.Custom;
	BottomSurface = Enum.SurfaceType.Smooth;
	Name = "SphereParticle";
	Create'SpecialMesh'{
		Scale = Vector3.new(0, 0, 0);
		MeshType = Enum.MeshType.Sphere;
	};
};

-- if theres a character, get a body part from it
local function GetBodyPart(name)
	local character = Character or GetCharacter(Tool)
	if character then
		local object = character:FindFirstChild(name)
		if object then
			return object
		end
	end
	return nil
end

local function DealDamage(hit,damage)
	local humanoid = GetHumanoid(hit)
	if humanoid then
		local dtag = Create'ObjectValue'{
			Name = tostring(damage);
			Value = humanoid;
			Archivable = false;
		}
		dtag.Parent = DamageBin
	end
end

local function MakeMoonArc(start,angle,off)
	local arc = MoonArcTemplate:Clone()
	arc.Archivable = false
	arc.CFrame = start
		* angle
		* CFrame.Angles(
			math.rad(math.random(-arc_angle_variance.x,arc_angle_variance.x)),
			math.rad(math.random(-arc_angle_variance.y,arc_angle_variance.y)),
			math.rad(math.random(-arc_angle_variance.z,arc_angle_variance.z))
		)
		* off
		* CFrame.new(0,0,math.random(-arc_distance_variance*10,arc_distance_variance*10)/10)


	arc.Touched:connect(function(hit)
		if not hit:IsDescendantOf(Character) then
			DealDamage(hit,ArcDamage)
		end
	end)
	arc.Parent = Character

	Spawn(function()
		local MoonArc = arc
		local DecalTop = MoonArc:FindFirstChild("DecalTop")
		local DecalBottom = MoonArc:FindFirstChild("DecalBottom")
		local i = 0
		while i < 1 do
			local n = math.pow(i,arc_decay)
			if DecalTop then DecalTop.Transparency = n end
			if DecalBottom then DecalBottom.Transparency = n end
			MoonArc.CFrame = MoonArc.CFrame * CFrame.new(0,0,-math.pow(1-i,arc_decay)*arc_max_speed)
			i = i + wait()/arc_time
		end
		MoonArc:Destroy()
	end)
end

local function MoonIsVisible(Character)
	local dir = Lighting:GetMoonDirection()
	if Vector3.new(0,1,0):Dot(dir) > 0 then
	-- BUG: particles block raycast
		if not Workspace:FindPartOnRay(Ray.new(Handle.Position,dir*999),Character) then
			return true
		end
	end
	return false
end

local function SwordTouched(hit)
	if not hit:IsDescendantOf(Character) then
		DealDamage(hit,Damage)
	end
end

local toolEquipped = false
local attackEnabled = true
local chargedAttackEnabled = false
local canCharge = true
-- charging sequence
local function Charge(Mouse)
---- READY CHARGE
	attackEnabled = false
	canCharge = false
	WalkSpeed:Set(0)

	-- make shiny handle
	local ShinyHandle
	do
		ShinyHandle = Handle:Clone()
		ShinyHandle.BrickColor = BrickColor.new("Institutional white")
		ShinyHandle.Archivable = false
		ShinyHandle.Parent = Tool
		local mesh = ShinyHandle:FindFirstChild("Mesh")
		if mesh then mesh.TextureId = "" end
		AttemptJoint(ShinyHandle,Handle)
	end
	-- make sphere, if enabled
	local SphereParticle
	if sphere_enabled then
		SphereParticle = SphereParticleTemplate:Clone()
		SphereParticle.Archivable = false
		SphereParticle.Parent = Tool
		AttemptJoint(SphereParticle,Handle)
	end

	local charging = true
	local charge_level = 0	-- main value; determines charge
	Event.MouseCharge = Mouse.Button1Up:connect(function()
		charging = false
	end)

	Animation:StopAnimations(0)
	Animation.Charge:Play()

	local moon_visible = false	
	-- particle thread
	Spawn(function()
		while charging and toolEquipped do
			moon_visible = MoonIsVisible(Character)
			if moon_visible then
				-- spawn particles
				MoonParticle:Spawn()
				SmallParticle:Spawn()
			end
			wait(0.1)
		end
	end)

---- CHARGE
	-- fade in charge sound
	Sound.Charge.Pitch = 0.5
	Sound.Charge:Play()
	coroutine.wrap(function()
		Sound:Fade("Charge",0.8,0.5)
	end)()
	-- charge loop
	while charging and toolEquipped do
		local t = wait()
		if moon_visible then
			charge_level = charge_level + t/charge_time
			ShinyHandle.Reflectance = charge_level
			Sound.Charge.Pitch = 0.5 + charge_level*2

			if sphere_enabled then
				local i = ((sphere_magnitude*math.sin(math.pi*charge_level*sphere_radius*sphere_time))/math.pi + charge_level*sphere_radius*sphere_time)/sphere_time
				SphereParticle.Mesh.Scale = Vector3.new(i,i,i)
			end
		end
		if charge_level >= 1 then
			charging = false
			charge_level = 1
			break
		end
	end

	-- fade out charge sound
	coroutine.wrap(function()
		Sound:Fade("Charge",0,0.5)
		Sound.Charge:Stop()
	end)()

	if sphere_enabled then
		-- shrink sphere
		local s = charge_level
		while s > 0 do
			s = s - wait()/0.25
			local i = (1-math.pow(1-s,2))*sphere_radius
			SphereParticle.Mesh.Scale = Vector3.new(i,i,i)
		end
	end

---- READY CHARGE ATTACK
	Animation:StopAnimations()
	Animation.DualSword:Play(0.2)
	Disconnect("MouseCharge")
	WalkSpeed:Set(WalkSpeed:GetBase()*charge_walk_mult)
	if sphere_enabled then
		SphereParticle:Destroy()
	end

	-- split shiny handle from normal handle; give to left hand
	KillJoint(ShinyHandle,Handle)
	AttemptJoint(ShinyHandle,GetBodyPart("Left Arm"),nil,CFrame.new(0,-1,-2.25)*CFrame.Angles(0,math.pi,math.pi/2))
	ShinyHandle.Touched:connect(SwordTouched)

	Damage = charged_sword_damage
	ArcDamage = charged_arc_damage

---- CHARGE ATTACK
	local attack_level = charge_level
	chargedAttackEnabled = true
	attackEnabled = true
	do -- sword glow indicator
		local i = 1 + (math.pow(1-charge_level,10))
		Handle.Mesh.VertexColor = Vector3.new(i,i,i)
	end

	while attack_level > 0 and toolEquipped do
		attack_level = attack_level - wait()/charge_attack_time
		ShinyHandle.Reflectance = attack_level
		ShinyHandle.Transparency = 1-attack_level
	end

---- CHARGE ATTACK END
	chargedAttackEnabled = false
	Animation.DualSword:Stop(0.2)
	WalkSpeed:Reset()
	Damage = sword_damage
	ArcDamage = arc_damage
	ShinyHandle:Destroy()

---- COOLDOWN
	local cooldown = charge_level
	while cooldown > 0 do
		cooldown = cooldown - wait()/cooldown_time
		local i = 1 + (math.pow(1-cooldown,10))
		Handle.Mesh.VertexColor = Vector3.new(i,i,i)
	end
	canCharge = true
end

local fatigue = 0
Tool.Equipped:connect(function(Mouse)
	toolEquipped = true
	Character,Humanoid = GetCharacter(Tool)
	if not Character then return end
	Animation:LoadHumanoid(Humanoid)
	WalkSpeed:SetHumanoid(Humanoid)

	local Torso = GetBodyPart("Torso")

	-- Slash Sequencer
		-- basic left-right slash
		-- primary attack
	local SlashSeq = CreateSequencer()
	SlashSeq:SetMinInterval(0)
	SlashSeq:SetResetDelay(1.15,0.8)
	local function add_fatigue()
		local inc = fatigue_increment -- may change, so save it for later
		fatigue = fatigue + inc
		SlashSeq:SetMinInterval(fatigue) -- set as amount of time between slashes
		-- recovery time; dependant on current fatigue
		-- therefore, more fatigue causes longer recovery
		wait(fatigue*rest_factor)
		fatigue = fatigue - inc
		SlashSeq:SetMinInterval(fatigue)
	end
	SlashSeq:SetSequenceMap{
		function()
			if fatigue_enabled then Spawn(add_fatigue) end
			Sound.Slash.Pitch = math.random(1000,1020)/1000
			Sound.Slash:Play()

			Animation.SlashRight:Stop(0)
			Animation.SlashLeft:Play()
			wait(0.25)
			MakeMoonArc(
				Torso.CFrame,
				CFrame.Angles(-math.pi/32,-math.pi/4,0),
				CFrame.new(0,0,-5)
			)
		end;
		function()
			if fatigue_enabled then Spawn(add_fatigue) end
			Sound.Slash.Pitch = math.random(1000,1020)/1000
			Sound.Slash:Play()

			Animation.SlashLeft:Stop(0)
			Animation.SlashRight:Play()
			wait(0.25)
			MakeMoonArc(
				Torso.CFrame,
				CFrame.Angles(math.pi/32,math.pi/6,0),
				CFrame.new(0,0,-4)
			)
		end;
	}

	-- Charged Slash Sequencer
		-- dual-sword forward-side slash
		-- secondary attack
	local ChargedSeq = CreateSequencer()
	ChargedSeq:SetMinInterval(0.1)
	ChargedSeq:SetResetDelay(0.6,0.4)
	ChargedSeq:SetSequenceMap{
		function()
			Sound.Slash.Pitch = math.random(900,920)/1000
			Sound.Slash:Play()

			Animation.SlashSides:Stop(0)
			Animation.SlashForward:Play()
			wait(0.25)
			MakeMoonArc(
				Torso.CFrame,
				CFrame.Angles(math.pi/32,0,math.pi/6),
				CFrame.new(0,0,-5)
			)
			MakeMoonArc(
				Torso.CFrame,
				CFrame.Angles(math.pi/32,0,-math.pi/6),
				CFrame.new(0,0,-5)
			)
		end;
		function()
			Sound.Slash.Pitch = math.random(900,920)/1000
			Sound.Slash:Play()

			Animation.SlashForward:Stop(0)
			Animation.SlashSides:Play()
			wait(0.25)
			MakeMoonArc(
				Torso.CFrame,
				CFrame.Angles(-math.pi/32,-math.pi/2,0),
				CFrame.new(0,0,-5)
			)
			MakeMoonArc(
				Torso.CFrame,
				CFrame.Angles(-math.pi/32,math.pi/2,0),
				CFrame.new(0,0,-5)
			)
		end;
	}

	local ClickThread = CreateThreadID()
	local down = false
	Mouse.Button1Down:connect(function()
		if attackEnabled and GetBodyPart("Right Arm") then
			down = true
			if chargedAttackEnabled then
				ChargedSeq:Activate()
			else
				SlashSeq:Activate()
				if canCharge and GetBodyPart("Left Arm") then
					local cid = ClickThread:Request()
					wait(0.5)
					if ClickThread:Assert(cid) and down then
						Charge(Mouse)
					end
				end
			end
		end
	end)

	Mouse.Button1Up:connect(function()
		down = false
	end)

	Event.Touched = Handle.Touched:connect(SwordTouched)
end)

Tool.Unequipped:connect(function()
	toolEquipped = false
	chargedAttackEnabled = false
	attackEnabled = true
	Disconnect("Touched","Lighting")
	Animation:StopAnimations()
	Sound:StopSounds()
	WalkSpeed:Reset()
	Damage = sword_damage
	ArcDamage = arc_damage
end)