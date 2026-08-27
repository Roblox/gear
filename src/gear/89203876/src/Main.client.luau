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
		May only be called after LoadHumanoid.
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

	function def:StopAnimations()
		for name,track in pairs(animationTracks) do
			track:Stop()
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

	local CP = Game:GetService("ContentProvider")

	for name,id in pairs(sound_ids) do
		sounds[name] = Create'Sound'{
			Name = name;
			SoundId = type(id) == "number" and ("rbxassetid://"..id) or id;
			Archivable = false;
		}
		CP:Preload(sounds[name].SoundId)
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
LightingTime
	Manages lighting transition.

	CreateLightingTime ( number `acceleration`, number `deceleration`, number `max_velocity` )
		All three arguments measure in hours.
	:Start ( ThreadID `thread`, number `currentID` )
		Starts up the transition with `thread` and `currentID` to determine whether to accelerate or decelerate.
	:Stop ( )
		Immediately stops the transition.
	:GetExternalCount ( )
		Returns the amount of times the TimeOfDay has been changed externally.
	:ResetExternalCount ( )
		Reset external change count.
		
]]
class'LightingTime'(function(def,accel,decel,max)
	-- convert number (in hours) to TimeOfDay string
	-- because TimeOfDay doesn't cast numbers as expected (3.7 -> 03:07:00 instead of 3:42:00)
	local function ToTimeOfDay(n)
		n = n % 24
		local i,f = math.modf(n)
		local m = f*60
		local mi,mf = math.modf(m)
		m = tostring(math.abs(math.floor(m)))
		local s = tostring(math.abs(math.floor(mf*60)))
		return i..":"..string.rep("0",2-#m)..m..":"..string.rep("0",2-#s)..s
	end

	-- convert TimeOfDay string to number (in hours)
	local function FromTimeOfDay(t)
		local signed,h,m,s = t:match("^(%-?)(%d+):(%d+):(%d+)$")
		s = tonumber(s)/60
		m = tonumber(m + s)/60
		h = tonumber(h) + m
		return h * (#signed > 0 and -1 or 1)
	end

	local Lighting = Game:GetService("Lighting")
	local threadRunning = false
	local setInternal = false
	local time = FromTimeOfDay(Lighting.TimeOfDay)
	local velocity = 0
	local exCount = 0
	local threadID
	local cID

	max = max * 0.03

	local con = Lighting.Changed:connect(function(p)
		if p == "TimeOfDay" then
			if not setInternal then
				exCount = exCount + 1
				threadRunning = false
			end
		end
	end)
	
	function def:Reset()
		setInternal = false
		velocity = 0
	end

	function def:ResetExternalCount()
		exCount = 0
	end

	function def:GetExternalCount()
		return exCount
	end

	local function NewThread()
		coroutine.wrap(function()
			threadRunning = true
			time = FromTimeOfDay(Lighting.TimeOfDay)
			while threadRunning do
				local t = wait()
				if threadID:Assert(cID) then
					velocity = velocity + accel*t
				else
					velocity = velocity - accel*t
				end
				if velocity > max then
					velocity = max
				elseif velocity < 0 then
					threadRunning = false
					break
				end

				time = time + velocity

				setInternal = true
				Lighting.TimeOfDay = ToTimeOfDay(time)
				setInternal = false
			end
			def:Reset()
		end)()
	end

	function def:Start(thread,cid)
		threadID = thread
		cID = cid
		if not threadRunning then
			NewThread()
		end
	end

	function def:Stop()
		threadRunning = false
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
--SETTINGS----------------------------------------------------------------------

-- Time velocity when transitioning
local time_acceleration	= ( 1/2 )*1/60	-- minutes per second
local time_deceleration	= ( 1 )*1/60	-- minutes per second
local max_time_velocity	= ( 1/2 )		-- hours per second

-- Magic circle shield
local charge_time	= 1		-- amount of time before circle is fully charged
local decharge_time	= 0.5	-- amount of time before circle is completely decharged
local spin_velocity	= 90	-- degrees per second
local circle_size	= 24	-- max diameter of circle

-- Missiles
local missile_range	= 48	-- range in which humanoids will be detected
							-- size == [n, volume_limit/(n*n), n]/2
local missile_delay	= 0.5	-- the amount of time (in seconds) between each missile
local missile_speed	= 24

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Tool = script.Parent
local Handle = WaitForChild(Tool,"Handle")
local Character,Humanoid

local magicEnabled = true
local canMagic = true

local BurnScript = WaitForChild(Tool,"BurnScript")
local BindScript = WaitForChild(Tool,"BindScript")

local ShieldActive = GetMake(Tool,"ShieldActive","BoolValue")
ShieldActive.Value = false

local WalkSpeed = CreateWalkSpeedManager()

local Animation = CreateAnimationProvider{
	Wave	= "http://www.roblox.com/asset/?id=83994332";
	Raised	= "http://www.roblox.com/asset/?id=83994319";
}                   

local Sound = CreateSoundProvider{
	SunBurst	= "http://www.roblox.com/asset/?id=16433289";
	MoonBurst	= "http://www.roblox.com/asset/?id=84005018";
}

local CircleTemplate = Create'Part'{
	Name = "CelestialCircle";
	Anchored = true;
	CanCollide = false;
	Transparency = 1;
	FormFactor = Enum.FormFactor.Custom;
	TopSurface = Enum.SurfaceType.Smooth;
	BottomSurface = Enum.SurfaceType.Smooth;
	Create'Decal'{
		Name = "DecalTop";
		Face = Enum.NormalId.Top;
		Texture = "http://www.roblox.com/asset/?id=78036587";
	};
	Create'Decal'{
		Name = "DecalBottom";
		Face = Enum.NormalId.Bottom;
		Texture = "http://www.roblox.com/asset/?id=78036587";
	};
	Create'BlockMesh'{
		Scale = Vector3.new(1,0,1);
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

local LightingTime = CreateLightingTime(time_acceleration,time_deceleration,max_time_velocity)

local Missiles = {
	{	-- moon
		is_active = function()
			return Game:GetService("Lighting"):GetMoonDirection():Dot(Vector3.new(0,1,0)) > 0;
		end;
		fire = function(origin,target)
			local missile = Create'Part'{
				Name = "CelestialMissile";
				FormFactor = 0;
				TopSurface = 0;
				BottomSurface = 0;
				Reflectance = 0.5;
				BrickColor = BrickColor.new("Bright yellow");
				CanCollide = false;
				Locked = true;
				Size = Vector3.new(4,4,1);
				Create'SpecialMesh'{
					MeshId = "http://www.roblox.com/asset/?id=3270017";
					Scale = Vector3.new(4,4,4);
				};
				Create'Sparkles'{
					SparkleColor = Color3.new(1,1,0);
				};
				Create'BodyVelocity'{
					maxForce = Vector3.new(math.huge,math.huge,math.huge);
					velocity = Vector3.new(0,0,0);
				};
				Create'Sound'{
					SoundId = Sound.MoonBurst.SoundId;
				};
			}
			local bv = missile.BodyVelocity
			local particle = missile.Sparkles
			missile.CFrame = CFrame.new(origin,target) --* CFrame.Angles(-math.pi/2,0,0)
			bv.velocity = (target-origin).unit*missile_speed
			local con;con = missile.Touched:connect(function(hit)
				if not hit:IsDescendantOf(Character) and hit.Name ~= "CelestialMissile" then
					local h = GetHumanoid(hit)
					if h and h.Health > 0 and h.Torso then
						local bind = BindScript:Clone()
						bind.Disabled = false
						bind.Parent = h.Torso
					end
					con:disconnect()
					missile.Anchored = true
					missile.Transparency = 1
					particle.Enabled = false
					wait(1) -- particles cut off if Fire object is removed, which looks ugly
					missile:Destroy()
				end
			end)
			local sound = missile.Sound
			missile.Parent = Workspace
			sound:Play()
			Game:GetService("Debris"):AddItem(missile,5)
		end;
	};
	{	-- sun
		is_active = function()
			return Game:GetService("Lighting"):GetSunDirection():Dot(Vector3.new(0,1,0)) > 0;
		end;
		fire = function(origin,target)
			local missile = Create'Part'{
				Name = "CelestialMissile";
				FormFactor = 0;
				Shape = 0;
				TopSurface = 0;
				BottomSurface = 0;
				Transparency = 0.5;
				BrickColor = BrickColor.new("Deep orange");
				CanCollide = false;
				Locked = true;
				Size = Vector3.new(3,3,3);
				Create'Fire'{};
				Create'BodyVelocity'{
					maxForce = Vector3.new(math.huge,math.huge,math.huge);
					velocity = Vector3.new(0,0,0);
				};
				Create'Sound'{
					SoundId = Sound.SunBurst.SoundId;
				};
			}
			local bv = missile.BodyVelocity
			local particle = missile.Fire
			missile.CFrame = CFrame.new(origin,target) * CFrame.Angles(-math.pi/2,0,0)
			bv.velocity = (target-origin).unit*missile_speed
			local con;con = missile.Touched:connect(function(hit)
				if not hit:IsDescendantOf(Character) and hit.Name ~= "CelestialMissile" then
					if GetHumanoid(hit) then
						local burn = BurnScript:Clone()
						burn.Disabled = false
						burn.Parent = hit
					end
					con:disconnect()
					missile.Anchored = true
					missile.Transparency = 1
					particle.Enabled = false
					wait(1) -- particles cut off if Fire object is removed, which looks ugly
					missile:Destroy()
				end
			end)
			local sound = missile.Sound
			missile.Parent = Workspace
			sound:Play()
			Game:GetService("Debris"):AddItem(missile,5)
		end;
	};
}

local function FireMissiles(origin)

	-- get missiles that are active
	local activeMissiles = {}
	for i = 1,#Missiles do
		local missile = Missiles[i]
		if missile.is_active() then
			activeMissiles[#activeMissiles+1] = missile.fire
		end
	end
	if #activeMissiles == 0 then return end

	local humanoidList = {}
	do	-- get a list of humanoids within a region
		local region_vec = Vector3.new(missile_range,math.floor(10^5/(missile_range*missile_range)),missile_range)/2
		local missile_region = Region3.new(origin-region_vec,origin+region_vec)
		local partsList = Workspace:FindPartsInRegion3(missile_region,Character,100)
		local parentCache = {}
		for i,part in pairs(partsList) do
			local parent = part.Parent
			if not parentCache[parent] then
				parentCache[parent] = true
				local h = GetHumanoid(part)
				if h and h.Health > 0 then
					humanoidList[#humanoidList+1] = h
				end
			end
		end
	end
	if #humanoidList == 0 then return end

	-- randomize humanoid list
	for i = 1,#humanoidList do
		local r = math.random(1,#humanoidList)
		humanoidList[i],humanoidList[r] = humanoidList[r],humanoidList[i]
	end

	-- fire random missile in each humanoid's direction
	for i = 1,#humanoidList do
		local humanoid = humanoidList[i]
		local pos
		do
			local target = humanoid.Torso
			if target then
				pos = target.Position
			end
		end
		if pos then
			local missile = activeMissiles[math.random(1,#activeMissiles)]
			coroutine.wrap(missile)(origin,pos)
			wait(missile_delay)
		end
	end
end

local ClickThread = CreateThreadID()
Tool.Equipped:connect(function(Mouse)
	Character,Humanoid = GetCharacter(Tool)
	if not Character then return end
	Animation:LoadHumanoid(Humanoid)
	WalkSpeed:SetHumanoid(Humanoid)

	local Torso = GetBodyPart("Torso")

	do	-- replace the interfering RightGrip joint
		local RightArm = GetBodyPart("Right Arm")
		if RightArm then
			local grip = WaitForChild(RightArm,"RightGrip")
			local C0,C1 = grip.C0,grip.C1
			wait()
			AttemptJoint(RightArm,Handle,C0,C1)
		end
	end

	local down = false
	Mouse.Button1Down:connect(function()
		if canMagic and GetBodyPart("Right Arm") then
---- READY MAGIC
			local cid = ClickThread:Request()

			LightingTime:ResetExternalCount()

			Animation.Raised:Play(0.25)
			wait(0.25)
			if not ClickThread:Assert(cid) then return end
			Animation.Wave:Play()
			wait(0.2)
			if not ClickThread:Assert(cid) then return end

---- DO MAGIC
			canMagic = false
			WalkSpeed:Set(0)

			if LightingTime:GetExternalCount() == 0 then
				LightingTime:Start(ClickThread,cid)
			end

			local Circle = CircleTemplate:Clone()
			Circle.Size = Vector3.new(circle_size,16,circle_size)
			Circle.Parent = Character
			local top = Circle.DecalTop
			local bottom = Circle.DecalBottom
			local pos = Circle.Position
			local charge,spin = 0,0
			while ClickThread:Assert(cid) do
				local t = wait()
				charge = charge + t/charge_time
				if charge >= 1 then
					charge = 1
					ShieldActive.Value = true
				else
					ShieldActive.Value = false
				end
				spin = spin + spin_velocity*t
				local c = 1-math.pow(1-charge,2)
				Circle.Mesh.Scale = Vector3.new(c,0,c)
				top.Transparency = 1-c
				bottom.Transparency = 1-c
				Circle.CFrame = CFrame.new(Torso.Position+Vector3.new(0,-2,0)) * CFrame.Angles(0,-math.rad(spin),0)
			end

---- FIRE MISSILES
			if charge >= 1 then
				Spawn(function()
					FireMissiles(Torso.Position)
					WalkSpeed:Reset()
					canMagic = true
				end)
			else
				WalkSpeed:Reset()
				canMagic = true
			end

---- CLEANUP MAGIC
			ShieldActive.Value = false

			local pos = Circle.Position
			local size = Circle.Mesh.Scale.x
			local opac = 1-top.Transparency
			charge = 1
			ShieldActive.Value = false
			while charge > 0 do
				local t = wait()
				charge = charge - t/decharge_time
				spin = spin + spin_velocity*t
				local c = (1-math.pow(1-charge,2))*size
				Circle.Mesh.Scale = Vector3.new(c,0,c)
				top.Transparency = 1-charge*opac
				bottom.Transparency = 1-charge*opac
				Circle.CFrame = CFrame.new(pos) * CFrame.Angles(0,-math.rad(spin),0)
			end
			Circle:Destroy()
		end
	end)

	Mouse.Button1Up:connect(function()
		local cid = ClickThread:Request()
		Animation.Wave:Stop(0.1)
		wait(0.1)
		if not ClickThread:Assert(cid) then return end
		Animation.Raised:Stop()
	end)
end)

Tool.Unequipped:connect(function()
	ShieldActive.Value = false
	KillJoint(GetBodyPart("Right Arm"),Handle)
	ClickThread:Reset()
	Animation:StopAnimations()
	Sound:StopSounds()
	WalkSpeed:Reset()
end)

