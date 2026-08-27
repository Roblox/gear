--local mDebugId = game.Workspace.DebugId.Value
--game.Workspace.DebugId.Value = game.Workspace.DebugId.Value+1
--print("Running swordscript <"..mDebugId..">")

-------------------------------------
-- Makes an RBX::Lua Instance using
-- a table of key-value pairs to
-- initialize it. Values with numeric 
-- keys will be parented to the object
-- and other values will be set
-- as members of the object.
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

---------------------------------------
-- Same as Make, but modifies an existing
-- object rather than creating ones.
function Modify(obj, data)
	for k, v in pairs(data) do
		if type(data) == 'number' then
			data.Parent = obj
		else
			data[k] = v
		end
	end
	return obj
end

-----------------------------------------
-- Creates a class which can be instantiated
-- using `CreateCLASSNAME( ... )`.
---usage:
--class'MyClass'(function(this, arg1)
--	this.ClassMember = value
--	function this.ClassMethod(...) ... end
--end, function(def)
--	def.StaticMember = value
--	 function def.StaticMethod(...) ... end
--end)
--local obj = CreateMyClass(arg1)
------------------------------------------
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


---------------------------------------------
-- Signal class for custom-made events
--API:
-- Signal:connect(callback)
-- Signal:fire(...)
-- Signal:wait()
---------------------------------------------
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
		--print("Fire evt<"..tostring(this).."> from script<"..mDebugId..">")
		for func, conn in pairs(mListeners) do
			--print("-> "..tostring(func).."( ... )")
			func(...)
		end
		mWaitObject.Value = not mWaitObject.Value
	end

	function this:wait()
		mWaitObject.Changed:wait()
	end
end)


--------------------------------------------------
-- Bin class for cleaning up assets
--API: 
-- Bin:add(func: Function, ident: String)
-- Bin:clean(ident: String)
-- Bin:cleanAll()
--------------------------------------------------
class'Bin'(function(this)
	local mGarbage = {}

	function this:add(func, ident)
		ident = ident or '__unnamed'
		if not mGarbage[ident] then
			mGarbage[ident] = {}
		end
		mGarbage[ident][#mGarbage[ident]+1] = func
	end

	function this:clean(ident)
		local listToCall = mGarbage[ident]
		if listToCall then
			for _, func in pairs(listToCall) do
				func()
			end
			mGarbage[ident] = nil
		end
	end

	function this:cleanAll()
		for ident, list in pairs(mGarbage) do
			for _, func in pairs(list) do
				func()
			end
			mGarbage[ident] = nil
		end
	end
end)


-----------------------------------------------------
-- AnimationProvider class for easy loading of
-- animation assets into animationtracks once 
-- a humanoid is available.
--API:
-- AnimationProvider:registerAnimation(ident, assetid)
-- AnimationProvider:setHumanoid(humanoid)
-- AnimationProvider:setTool(tool)
-- AnimationProvider:getAnimation(ident)
-----------------------------------------------------
class'AnimationProvider'(function(this)
	local mAnimations = {--[[ident => {AnimationId, CurrentTrack, CurrentAnim} ]]}
	local mCurrentHumanoid = nil

	function this:registerAnimation(ident, assetid)
		--check for an existing copy of the anim
		local existingAnim = Tool.Tool:FindFirstChild('ANIM_'..ident)
			
		--make the data for this anim
		local animdat = {
			AnimationId = assetid, 
			CurrentAnim = existingAnim or Create'Animation'{
				Name = "ANIM_"..ident,
				AnimationId = assetid,	
			},
		}
		mAnimations[ident] = animdat

		--if there's a current tool, put it in there
		if Tool.Tool then
			Tool.HUGE_EQUIP_HACK = true
			animdat.CurrentAnim.Parent = Tool.Tool
			Tool.HUGE_EQUIP_HACK = false
		end
		
		--if there's a humanoid load the animation track
		if mCurrentHumanoid then
			animdat.CurrentTrack = mCurrentHumanoid:LoadAnimation(animdat.CurrentAnim)
		end
	end

	function this:setHumanoid(humanoid)
		mCurrentHumanoid = humanoid
		for _, anim in pairs(mAnimations) do
			anim.CurrentTrack = humanoid:LoadAnimation(anim.CurrentAnim)
		end
	end

	function this:getAnimation(ident)
		local dat = mAnimations[ident]
		if not dat then error("Gear Fatal Error: Animation `"..ident.."` not found") end
		if not dat.CurrentTrack then 
			error("Gear Fatal Error: No Humanoid for animation `"..ident.."` to run in") 
		end
		return dat.CurrentTrack
	end
end)


----------------------------------------------
-- SoundProvider class
-- functions similarily to the animationprovider
----------------------------------------------
class'SoundProvider'(function(this)
	local mSounds = {}

	function this:registerSound(ident, assetid, inpart)
		inpart = inpart or Tool.Tool:FindFirstChild('Handle')
		if not inpart then
			repeat
				inpart = Tool.Tool.ChildAdded:wait()
			until inpart.Name == 'Handle'
		end
		local existingSound = inpart:FindFirstChild('SOUND_'..ident)
		local sounddat = {
			SoundId = assetid,
			CurrentSound = existingSound or Create'Sound'{
				Name = 'SOUND_'..ident,
				SoundId = assetid,
				Parent = inpart,
			},
		}
		mSounds[ident] = sounddat
	end

	function this:getSound(ident)
		local dat = mSounds[ident]
		if dat then
			return dat.CurrentSound
		end
	end
end)


----------------------------------------------
-- DebounceProvider class -- Prevent events
-- from happening in too rapid succession
----------------------------------------------
class'DebounceProvider'(function(this)
	local mFlagNameToLastTime = {}

	function this:test(ident, delta)
		local t = tick()
		local lastTime = mFlagNameToLastTime[ident] or 0
		if delta then
			return (t-lastTime) > delta
		else
			return mFlagNameToLastTime[ident]
		end
	end
	function this:set(ident, state)
		if state then
			mFlagNameToLastTime[ident] = state
		elseif state == false then
			mFlagNameToLastTime[ident] = false
		else
			mFlagNameToLastTime[ident] = tick()
		end
	end
end)


function TagHumanoid(humanoid)
	if Tool.Player then
		local tag = Create'ObjectValue'{
			Name = "creator", 
			Value = Tool.Player,
			Parent = humanoid,
		}
		Tool.Bin:add(function()
			tag:Remove()
		end, 'HumanoidTag')
	end
end
function UntagHumanoid()
	Tool.Bin:clean('HumanoidTag')
end


------- wait for any event in a set of events  to fire ------
function WaitForAny(tb)
	local evt = tb
	local conn = {}
	local eventargs = nil
	local waitProxy = Create'BoolValue'{}
	for _, e in pairs(evt) do
		local c = e:connect(function(...)
			for _, c in pairs(conn) do
				c:disconnect()
			end
			eventargs = {...}
			waitProxy.Value = not waitProxy.Value
		end)
		conn[#conn+1] = c
	end
	--
	waitProxy.Changed:wait()
	--
	return unpack(eventargs)
end


----------------------------------------------
-- Tool singleton class
--API:
-- ...
class'Tool'(nil, function(this)
	--need this here for the animationprovider to use
	this.HUGE_EQUIP_HACK = false

	this.Bin = CreateBin()
	this.AnimationProvider = CreateAnimationProvider()
	this.DebounceProvider = CreateDebounceProvider()
	this.SoundProvider = CreateSoundProvider()

	--general values
	this.Tool = script.Parent
	this.Player = nil
	this.Humanoid = nil
	this.Character = nil

	--============ several flags for the gear
	--nothing

	--some events
	this.Equipped = CreateSignal()
	this.Unequipped = CreateSignal()
	this.OwnerChange = CreateSignal()

	--mouse utility events
	this.MouseClick = CreateSignal()
	this.MouseDoubleClick = CreateSignal()
	this.DoubleClickThreshold = 0.2

	local mLastClickTime = 0

	script.Parent.Equipped:connect(function(mouse)
		--print("Internal Equipped: Time b: "..time())
		--set up general values in the tool
		this.Mouse = mouse
		local curOwner = game.Players:GetPlayerFromCharacter(script.Parent.Parent)
		if curOwner ~= this.Player then
			this.Player = curOwner
			this.OwnerChange:fire(this.Player)
		end
		this.Character = this.Player.Character
		this.Humanoid = this.Character.Humanoid
		this.AnimationProvider:setHumanoid(this.Humanoid)

		--set up the mouse events
		mouse.Button1Down:connect(function()
			local t = tick()
			if (t-mLastClickTime) < this.DoubleClickThreshold then
				--prvent multiple double-clicks in a row
				mLastClickTime = 0
				this.MouseDoubleClick:fire(mouse)
			else
				mLastClickTime = t
				this.MouseClick:fire(mouse)
			end
		end)

		--done setup, call the equipped function
		if this.HUGE_EQUIP_HACK then
			--the HUGE_EQUIP_HACK flags tells the tool that the equip is a synchronous
			--call as a result of parenting an animation to the character, which happens 
			--when the tool is picked up from the workspace, but not during normal equips 
			--(Why does this happen???), if this is the case, the call should be rederrred 
			--one tick to ensure that all of the gear's loading can complete before it's 
			--equipped event is called.
			--TODO: Blame John for this.
			Delay(0, function()
				this.Equipped:fire(mouse)
			end)
		else
			--otherwise, proceed as normal
			this.Equipped:fire(mouse)
		end
	end)

	script.Parent.Unequipped:connect(function()
		--before my teardown, fire the event
		this.Unequipped:fire()

		--delete all my garbage
		this.Bin:cleanAll()
	end)
end)



---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--                                                                                               --
--                               Specific Gear code starts Here                                  -- 
--                                                                                               --
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--register my stuff
Tool.AnimationProvider:registerAnimation('equip', 'http://www.roblox.com/asset/?id=66702743')
Tool.AnimationProvider:registerAnimation('slash', 'http://www.roblox.com/asset/?id=66702758')
Tool.AnimationProvider:registerAnimation('critup', 'http://www.roblox.com/asset/?id=66703957')
Tool.AnimationProvider:registerAnimation('critdown', 'http://www.roblox.com/asset/?id=66703954')
Tool.SoundProvider:registerSound('slash', 'rbxasset://sounds\\swordslash.wav')
Tool.SoundProvider:registerSound('equip', 'rbxasset://sounds\\unsheath.wav')
Tool.SoundProvider:registerSound('down', 'rbxasset://sounds\\swordlunge.wav')
Tool.SoundProvider:registerSound('hitground', 'rbxasset://sounds\\snap.wav')

local DamageEnbled = false
local DamageToDo = 20
local SparkleParts = {}
local SparkleAttach = {}

Tool.Equipped:connect(function()
	print("Equipped")
	Tool.AnimationProvider:getAnimation('equip'):Play(0, 1, 3)
	Tool.SoundProvider:getSound('equip'):Play()
	local handleTouchedConn = Tool.Tool.Handle.Touched:connect(function(part)
		local humanoid = (part.Parent or game):FindFirstChild("Humanoid")
		if DamageEnbled and humanoid then
			TagHumanoid(humanoid)
			humanoid:TakeDamage(DamageToDo)
			wait(1)
			UntagHumanoid()
		end
	end)
	Tool.Bin:add(function() 
		handleTouchedConn:disconnect() 
	end, 'disconnect_handle_ontouched')

	local color = true
	for i = -3, 3, 1.5 do
		color = not color
		local p = Create'Part'{
			Name = 'EffectPart',
			FormFactor = 'Custom',
			Size = Vector3.new(0.1, 0.1, 0.1),
			Parent = Tool.Tool.Handle,
			Transparency = 1,
			CanCollide = false,
			Create'Fire'{
				Name = 'Effect',
				Enabled = false,
				Color = (color and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)),
				Size = 2,
			},
		}
		--[[SparkleParts[#SparkleParts+1] = p
		local motor = Create'Motor6D'{
			Name = 'EffectAttach',
			Parent = Tool.Tool.Handle,
			Part0 = Tool.Tool.Handle,
			Part1 = p,
			C1 = CFrame.new(i, 0, 0),
		}
		SparkleAttach[#SparkleAttach+1] = motor]]
	end
	Tool.Bin:add(function()
		for _, effectPart in pairs(SparkleParts) do
			effectPart.Parent = nil
		end
		for _, p in pairs(SparkleAttach) do
			p.Parent = nil
		end
		SparkleParts = {}
		SparkleAttach = {}
	end, 'kill_particle_effect')
end)

Tool.Unequipped:connect(function()
	Tool.AnimationProvider:getAnimation('equip'):Stop()
end)

--utility to enable / disable damage. Makes sure that enable-disable
--pairs don't ever interfear with one and other. 
local damageEnabledLevel = 0
local function EnableDamage(damage)
	DamageEnbled = true
	DamageToDo = damage
	damageEnabledLevel = damageEnabledLevel + 1
end
local function DisableDamage()
	damageEnabledLevel = damageEnabledLevel - 1
	if damageEnabledLevel <= 0 then
		DamageEnbled = false
	end
end


--set particles enabled
local function SetBladeEffectEnabled(state)
	for _, effectPart in pairs(SparkleParts) do
		effectPart.Effect.Enabled = state
	end
end

local function frand(low, high)
	return low + math.random()*(high-low)
end

--make the hitting ground effect
local PossibleSplashColors = {Color3.new(1, 0, 0), Color3.new(1, 1, 1)}
local function CreateSplashEffect(pos)
	local splashParts = {}
	for i = 1, 20 do
		local part = Create'Part'{
			FormFactor = 'Custom',
			Name = 'SlashParticle',
			Transparency = 1,
			CanCollide = false,
			Size = Vector3.new(0.5, 0.5, 0.5),
			CFrame = CFrame.new(pos),
			Create'Fire'{
				Name = 'Effect',
				Size = 2,
				Color = PossibleSplashColors[math.random(1, #PossibleSplashColors)],
			},
			Create'BodyVelocity'{
				Name = 'Fly',
				P = 100000,
				maxForce = Vector3.new(0, 0, 0),
				velocity = Vector3.new(frand(-1, 1), 
				                       frand(0.5,1), 
				                       frand(-1, 1)).unit * frand(20, 80),
			},
		}
		splashParts[#splashParts+1] = part
		part.Parent = game.Workspace
		part.Velocity = part.Fly.velocity
		Delay(frand(0.1, 0.4), function()
			part.Parent = nil
		end)
	end
	Tool.Bin:add(function()
		for _, p in pairs(splashParts) do
			p.Parent = nil
		end
	end, 'remove_splash_effect')
end

--====== main action code

Tool.MouseClick:connect(function()
	if Tool.DebounceProvider:test('slash', 0.5) then
		Tool.DebounceProvider:set('slash')
		Tool.AnimationProvider:getAnimation('slash'):Play(0, 1, 4)
		Tool.SoundProvider:getSound('slash'):Play()
		EnableDamage(20)
		wait(0.7)
		DisableDamage()
	end
end)

Tool.MouseDoubleClick:connect(function()
	if not Tool.DebounceProvider:test('doubleclick') then
		Tool.DebounceProvider:set('doubleclick', true)
		--
		Tool.AnimationProvider:getAnimation('slash'):Stop(0)
		Tool.AnimationProvider:getAnimation('critup'):Play(0, 1, 8)
		local torso = Tool.Character:FindFirstChild("Torso")
		if torso then
			--jump high
			Tool.Humanoid.Jump = true
			torso.Velocity = torso.Velocity + Vector3.new(0, 100, 0)

			--wait for the character to reach the top of their jump
			while torso.Velocity.y > 0 do
				wait()
			end

			--now, switch to the critdown anim / sound, activate the damage, 
			--and wait for the player to hit something on their way down.
			--also, speed up their descent
			EnableDamage(40)
			Tool.AnimationProvider:getAnimation('critup'):Stop(0)
			Tool.AnimationProvider:getAnimation('critdown'):Play(0, 1, 10)
			Tool.SoundProvider:getSound('down'):Play()
			torso.Velocity = torso.Velocity - Vector3.new(0, 10, 0)

			SetBladeEffectEnabled(true) --show some particles on the way down
			
			local rightLeg = Tool.Character:FindFirstChild('Right Leg')
			local leftLeg = Tool.Character:FindFirstChild('Left Leg')
			WaitForAny{rightLeg.Touched, leftLeg.Touched}

			SetBladeEffectEnabled(false) --get rid of the particles, we've leanded

			--play the hit gound sound
			Tool.SoundProvider:getSound('hitground'):Play()

			--generate a splash effect where the collision occurred
			local handle = Tool.Tool:FindFirstChild('Handle')
			if handle then
				CreateSplashEffect((handle.CFrame*CFrame.new(2.5, 0, 0)).p)
			end

			--now, we touched down, so halt the player for a cooldown, and
			--wait a bit for the cooldown to expire
			Tool.Humanoid.WalkSpeed = 0
			wait(0.6)

			--unfreeze them and stop the anim, also, disable the damage
			Tool.Humanoid.WalkSpeed = 16
			Tool.AnimationProvider:getAnimation('critdown'):Stop()
			DisableDamage()
		else
			--no torso? Something is wrong, stop the anim
			Tool.AnimationProvider:getAnimation('critup'):Stop(0)
		end
		--
		Tool.DebounceProvider:set('doubleclick', false)
	end
end)

--print("Done Running swordscript <"..mDebugId..">")