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

class'Signal'(function(this)
	local mListeners = {}
	local mWaitObject = Create'BoolValue'{}

	function this:connect(func)
		local connection = {}
		function connection:disconnect()
			mListeners[func] = nil
		end
		mListeners[func] = connection
		return connection
	end

	function this:fire(...)
		for func, conn in pairs(mListeners) do
			func(...)
		end
		mWaitObject.Value = not mWaitObject.Value
	end

	function this:wait()
		mWaitObject.Changed:wait()
	end
end)

--[[
KeyframeCatcher
	Detects when an AnimationTrack reaches a keyframe, then invokes a specified function corresponding to the keyframe.

	CreateKeyframeCatcher(animation)
		Returns a new KeyframeCatcher connected to `animation`, an AnimtionTrack.
	KeyframeCatcher:SetCallbacks(callbacks)
		`callbacks` can be a table of string/function pairs.
		When the AnimationTrack reaches a keyframe, the function corresponding to the keyframe's name will be called.
		Multiple functions can be invoked if the keyframe has multiple names, delimited by spaces, commas, or semi-colons.
		For example, a keyframe with the name "EndFlip StartKick" will call "EndFlip" and "StartKick" (in that order).
		`callbacks` can also be nil, which will disable the KeyframeCatcher.
]]
class'KeyframeCatcher'(function(def,animation)
	local reach

	function def:SetCallbacks(callbacks)
		if reach then
			reach:disconnect()
			reach = nil
		end
		if type(callbacks) == "table" then
			reach = animation.KeyframeReached:connect(function(keyframe)
				for name in keyframe:gmatch("[^,;%s]+") do
					local callback = callbacks[name]
					if callback then
						callback(animation)
					end
				end
			end)
		end
	end
end)

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
	AnimationProvider:PrepareKeyframeCatcher(identity,callbacks)
		Prepares a KeyframeCatcher to load for `identity` once the hunmanoid loads.
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

	function def:PrepareKeyframeCatcher(name,callbacks)
		catcherCallbacks[name] = callbacks
		if animationTracks[name] then
			local catcher = keyframeCatchers[name]
			if catcher then
				catcher:SetCallbacks(callbacks)
			elseif callbacks then
				catcher = CreateKeyframeCatcher(animationTrack[name])
				keyframeCatchers[name] = catcher
				catcher:SetCallbacks(catcherCallbacks[name])
			end
		end
	end

	-- lazy get
	setmetatable(def,{__index = animationTracks})
end)

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
BodyControl
	Non-Anchored control over a part.

	CreateBodyControl(part)
		Returns a new BodyControl wrapped around `part`, a BasePart.
	BodyControl:SetEnabled(enabled)
		Sets whether the BodyControl is enabled.
	BodyControl:SetCFrame(cframe)
		Sets the CFrame of the BodyControl (position and orientation).
]]
class'BodyControl'(function(def,object)
	local force_on = Vector3.new(math.huge,math.huge,math.huge)
	local force_off = Vector3.new()

	local BG = Instance.new("BodyGyro",object)
	BG.Archivable = false
	BG.D = 500
	BG.P = 100000
	BG.maxTorque = force_off

	local BP = Instance.new("BodyPosition",object)
	BP.Archivable = false
	BP.D = 500
	BP.P = 100000
	BP.maxForce = force_off

	function def:SetEnabled(enabled)
		BP.maxForce = enabled and force_on or force_off
		BG.maxTorque = enabled and force_on or force_off
	end

	function def:SetCFrame(cf)
		BP.position = cf.p
		BG.cframe = cf
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
	
	function def:Disconnect()
		if changed then changed:disconnect() changed=nil end
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
	DamageManager
		Manages damage using a queue or something.

	CreateDamageManager()
		Returns a new DamageManager.
	DamageManager:SetDamageTable(table)
		Sets a table of name/damage pairs to use.
		The field [false] (as a bool) is the default damage if no damage is active.
		`damage` can be a number or a function that returns the damage.
	DamageManager:SetActive(name,active)
		Sets whether `name` is active.
	DamageManager:DeactivateAll()
		Deactivates all damage.
	DamageManager:GetDamage(...)
		Returns the current damage.
		If the current damage is a function, then received arguments are passed to that function.
]]
class'DamageManager'(function(def)
	local damageTable = {}
	local activeDamage = {false}	-- a table of damage fields that are active
	local damage = 0	-- the current active damage

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

	function def:SetDamageTable(dt)
		damageTable = dt
		for i in pairs(activeDamage) do
			activeDamage[i] = nil
		end
		activeDamage[1] = false
		if not damageTable[false] then
			damageTable[false] = 0
		end
		damage = damageTable[false]
	end

	function def:SetActive(name,active)
		search_remove(activeDamage,name)
		if active then
			table.insert(activeDamage,1,name)
		end
		damage = damageTable[activeDamage[1]]
	end

	function def:DeactivateAll()
		for i in pairs(activeDamage) do
			activeDamage[i] = nil
		end
		activeDamage[1] = false
		damage = damageTable[false]
	end

	function def:GetDamage(...)
		if type(damage) == "function" then
			return damage(...)
		else
			return damage
		end
	end
end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Tiny Event Manager; Add: [[Event.EventName = (event)]]; Remove: [[Disconnect("EventName",...)]]
local clicktime = 0
local Torso
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
local PLEASE_STOP_EXISTING
local function AttemptJoint(x,y,c0,c1)
	if x and y then
		local weld = Instance.new("Motor6D")
		weld.Part0 = x
		weld.Part1 = y
		if c0 then weld.C0 = c0 end
		if c1 then weld.C1 = c1 end
		weld.Parent = x
		
		if x.Name == 'Right Arm' then
			PLEASE_STOP_EXISTING = weld
		end
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
--------------------------------------------------------------------------------

local Tool = script.Parent
local Handle = WaitForChild(Tool,"Handle")
local Character,Humanoid

local BurnScript = Tool:FindFirstChild("BurnScript")

local Damage = CreateDamageManager(Tool)
Damage:SetDamageTable{
	[false]			= 1;
	["Attack"]		= 20;
	["Spinning"]	= 0;
}

local spin_angle = 0.8
local max_spin_time = ( 3 )*30*spin_angle
local spin_slowdown = 1/4
local burn_ray_length = 8
local burn_chance = 1/6

local HandleControl = CreateBodyControl(Handle)
local WalkSpeed = CreateWalkSpeedManager()

local Animation = CreateAnimationProvider{
	Standing = "http://www.roblox.com/asset/?id=73177713";
	Swing = "http://www.roblox.com/asset/?id=73184276";
	Spin = "http://www.roblox.com/asset/?id=73177702";
}

local Sound = CreateSoundProvider{
	Swoosh = "http://www.roblox.com/asset/?id=46760716";
}
Sound:SetParent(Handle)
Sound.Swoosh.Volume = 0.25

local debugKeyframeReached = true

local Swinging = false
Animation:PrepareKeyframeCatcher("Swing",{
	AnimationStart = function() -- never fires
		debugKeyframeReached = false
		Swinging = true
	end;
	AnimationEnd = function()
		Swinging = false
	end;
	AttackStart = function()
		if Swinging then
			Damage:SetActive("Attack",true)
		end
	end;
	AttackEnd = function()
		Damage:SetActive("Attack",false)
	end;
	Swoosh = function()
		if Swinging then
			Sound.Swoosh.Pitch = math.random(120,123)/100
			Sound.Swoosh:Play()
		end
	end;
})

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

-- sets fire on Handle to center or ends
local function SwitchFire(name,mult,active)
	local HandleFire = Tool:FindFirstChild(name)
	if HandleFire then
		local Fire = HandleFire:FindFirstChild("Fire")
		if Fire then
			if active then
				AttemptJoint(Handle,HandleFire,nil,CFrame.Angles(math.pi,0,0))
				Fire.Heat = 25
				Fire.Size = 10
			else
				AttemptJoint(Handle,HandleFire,nil,CFrame.Angles(math.pi/2*mult,0,0)*CFrame.new(0,0,3.5*mult))
				Fire.Heat = 9
				Fire.Size = 4
			end
		end
	end
end

-- casts a ray that will burn a player if it hits
local function CastBurnRay()
	if BurnScript then
		local HandleFire = Tool:FindFirstChild("HandleFireTop")
		if not HandleFire then
			HandleFire = Tool:FindFirstChild("HandleFireBottom")
		end
		if HandleFire then
			local cf = HandleFire.CFrame * CFrame.Angles(math.pi/2,0,0)
			local ch = GetCharacter(Tool)
			local Hit = Workspace:FindPartOnRay(Ray.new(cf.p,cf.lookVector*burn_ray_length),ch)
			if GetHumanoid(Hit) then
				local burn = BurnScript:Clone()
				burn.Disabled = false
				burn.Parent = Hit
			end
		end
	end
end

-- does the spinning animation
local SpinThread = CreateThreadID()
local function StartSpin(Torso)
	local id = SpinThread:Request()
	Animation.Spin:Play(0.25,1,1.5)
	Handle.CanCollide = false
	wait(0.25) -- eww
	if SpinThread:Assert(id) then
		Animation.Spin:Play(0,1,1.5) -- fixes bug
		Damage:SetActive("Spinning",true)
		Spinning.Value = true
		WalkSpeed:Set(WalkSpeed:GetBase()*spin_slowdown)
		KillJoint(GetBodyPart("Right Arm"),Handle)
		HandleControl:SetEnabled(true)
		SwitchFire("HandleFireTop",1,true)
		SwitchFire("HandleFireBottom",-1,true)
		local a = 0
		local s = 0
		local off = CFrame.new(0,0.5,-2) * CFrame.Angles(math.pi/2,0,0)
		while SpinThread:Assert(id) do
			HandleControl:SetCFrame(Torso.CFrame * off * CFrame.Angles(0,a,0))
			a = a + spin_angle
			s = s - 1
			if a > max_spin_time then break end
			if s <= 0 then
				s = 5
				Sound.Swoosh.Pitch = math.random(125,128)/100
				Sound.Swoosh:Play()
			end
			if math.random() < burn_chance then
				CastBurnRay()
			end
			wait()
		end
	end
	Animation.Spin:Stop(0.25)
	SwitchFire("HandleFireTop",1,false)
	SwitchFire("HandleFireBottom",-1,false)
	HandleControl:SetEnabled(false)
	AttemptJoint(GetBodyPart("Right Arm"),Handle,CFrame.new(0,-1,0))
	WalkSpeed:Reset()
	Damage:SetActive("Spinning",false)
	Spinning.Value = false
	wait(0.25) -- eww
	Handle.CanCollide = true
end

Tool.Remote.OnServerEvent:connect(function(client, command, ...)
	if client.Character == Tool.Parent then
		if command == 'MB1Down' then
			local t = tick()
			if t-clicktime < 0.2 then	-- double-click
				clicktime = t
				Animation.Swing:Stop(0)
				Swinging = false
				Damage:SetActive("Attack",false)
				StartSpin(Torso)
			else						-- single-click
				clicktime = t
				Swinging = true
				Animation.Swing:Play(0.1,1,1.25)
				if debugKeyframeReached then
					Sound.Swoosh.Pitch = math.random(120,123)/100
					Sound.Swoosh:Play()
				end
			end
		elseif command == 'MB1Up' then
			SpinThread:Request() --sloppy
			Animation.Swing:Stop(0.25)
			Swinging = false
			Damage:SetActive("Attack",false)
		end
	end
end)

local equipping = false
local unequipping = false
local unequippedCon
local unequippedFunc
Tool.Equipped:connect(function(Mouse) if equipping then return end equipping = true if unequipping then Tool.Parent = workspace end
	if not unequippedCon then
		unequippedCon = Tool.Unequipped:connect(unequippedFunc)
	end
	
	DamageBin = GetMake(Tool,"DamageBin","Configuration")
	Spinning = GetMake(Tool,"Spinning","BoolValue")
	
	if not Tool:FindFirstChild("HandleFireTop") then
		local HandleFire = Create'Part'{
			Name = "HandleFireTop";
			Parent = Tool;
			Archivable = false;
			Anchored = false;
			CanCollide = false;
			Locked = true;
			Transparency = 1;
			FormFactor = 0;
			Size = Vector3.new(1,1,1);
			TopSurface = 0;
			BottomSurface = 0;
			Create'Fire'{
				Color = Color3.new(246/255,69/255,0);
				SecondaryColor = Color3.new(102/255,0,102/255);
				Heat = 9;
				Size = 4;
			}
		}
		AttemptJoint(Handle,HandleFire,nil,CFrame.Angles(math.pi/2,0,0)*CFrame.new(0,0,3.5))
	end
	
	if not Tool:FindFirstChild("HandleFireBottom") then
		local HandleFire = Create'Part'{
			Name = "HandleFireBottom";
			Archivable = false;
			Parent = Tool;
			Anchored = false;
			CanCollide = false;
			Locked = true;
			Transparency = 1;
			FormFactor = 0;
			Size = Vector3.new(1,1,1);
			TopSurface = 0;
			BottomSurface = 0;
			Create'Fire'{
				Color = Color3.new(1,0,0);
				SecondaryColor = Color3.new(179/255,0,182/255);
				Heat = 9;
				Size = 4;
			}
		}
		AttemptJoint(Handle,HandleFire,nil,CFrame.Angles(-math.pi/2,0,0)*CFrame.new(0,0,-3.5))
	end
	
	
	Character,Humanoid = GetCharacter(Tool)
	if not Character then return end
	Animation:LoadHumanoid(Humanoid)
	WalkSpeed:SetHumanoid(Humanoid)
	clicktime = 0

	do	-- replace the interfering RightGrip joint
		local RightArm = GetBodyPart("Right Arm")
		if RightArm then
			WaitForChild(RightArm,"RightGrip")
			wait()
			AttemptJoint(RightArm,Handle,CFrame.new(0,-1,0))
		end
	end

	Animation.Standing:Play()

	Torso = GetBodyPart("Torso")

	Event.Died = Humanoid.Died:connect(function()
		SpinThread:Reset()
		Swinging = false
		Damage:SetActive("Attack",false)
	end)

	Event.Touched = Handle.Touched:connect(function(hit)
		if not hit:IsDescendantOf(Character) then
			local humanoid = GetHumanoid(hit)
			if humanoid then
				local dtag = Create'ObjectValue'{
					Name = tostring(Damage:GetDamage());
					Value = humanoid;
				}
				dtag.Parent = DamageBin
			end
		end
	end)

	wait(0.25) --ewww
	Handle.CanCollide = true
	
	equipping = false
end)

local lastTorsoCF
spawn(function()
	while true do
		if Character and Character:FindFirstChild'Torso' and not unequipping then
			lastTorsoCF = Character.Torso.CFrame
		end
		
		wait()
	end
end)

unequippedFunc = function() print'-a' if unequipping then return end unequipping = true if Tool.Parent:IsA'Workspace' then unequippedCon:disconnect() unequippedCon=nil end print'a'
	if Character and Character:FindFirstChild'Torso' then
		Character.Torso.CFrame = lastTorsoCF or (Character.Torso.CFrame - Vector3.new(0, 19202, 0))
	end
	
	local h2 = Handle:Clone()
	Handle:Destroy()
	Handle = h2
	Handle.Name = 'Handle'
	Handle.Velocity = Vector3.new()
	Handle.RotVelocity = Vector3.new()
	Handle.CFrame = CFrame.new(Character.Torso.CFrame * Vector3.new(0, 0, -8)) * CFrame.Angles(Handle.CFrame:toEulerAnglesXYZ())
	Handle.Parent = Tool
	print'b'
	if Tool:FindFirstChild'HandleFireTop' then Tool.HandleFireTop:Destroy() end
	if Tool:FindFirstChild'HandleFireBottom' then Tool.HandleFireBottom:Destroy() end
	if Tool:FindFirstChild'DamageBin' then Tool.DamageBin:Destroy() end
	if Tool:FindFirstChild'Spinning' then Tool.Spinning:Destroy() end

	WalkSpeed:Disconnect()
	
	Disconnect("Died","Touched")
	Animation:StopAnimations()
	KillJoint(Character and Character:FindFirstChild'Right Arm', Handle)
	Swinging = false
	Spinning.Value = false
	Damage:DeactivateAll()
	SpinThread:Reset()
	WalkSpeed:Reset()
	WalkSpeed:SetHumanoid()
	HandleControl:SetEnabled(false)
	print'c'
	delay(.5, function()
		Handle.Name = 'Handle'
		
		if Tool.Parent == workspace then
			local t2 = Tool:Clone()
			t2.Parent = workspace
			Tool:Destroy()
		end
	end)
	unequipping = false
end

unequippedCon = Tool.Unequipped:connect(unequippedFunc)