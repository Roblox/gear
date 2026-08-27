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
		game.Debris:AddItem(tag, 1)
	end
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
	this.MouseRelease = CreateSignal()
	this.MouseDoubleClick = CreateSignal()
	this.DoubleClickThreshold = 0.2
	this.MouseDown = false
	this.KeyDown = CreateSignal()

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
			this.MouseDown = true
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
		mouse.Button1Up:connect(function()
			this.MouseDown = false
			this.MouseRelease:fire()
		end)
		mouse.KeyDown:connect(function(key)
			this.KeyDown:fire(key)
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
















































local ChargeTime = 1 --1 second

Tool.AnimationProvider:registerAnimation('charge', 'http://www.roblox.com/asset/?id=69803963')
Tool.AnimationProvider:registerAnimation('check', 'http://www.roblox.com/asset/?id=69803972')
Tool.AnimationProvider:registerAnimation('equip', 'http://www.roblox.com/asset/?id=69803982')
Tool.AnimationProvider:registerAnimation('stab', 'http://www.roblox.com/asset/?id=69803991')


class'WeaponDamage'(nil, function(def)
	local mDamage = 0
	function def:setDamage(n)
		mDamage = n
	end
	function def:getDamage()
		return mDamage
	end
end)


function FindHumanoid(part)
	if not part.Parent then return end
	if part.Parent:FindFirstChild("Humanoid") then
		return part.Parent.Humanoid
	elseif part.Parent.Parent and part.Parent.Parent:FindFirstChild("Humanoid") then
		return part.Parent.Parent.Humanoid
	end
end


local mGui = Create'ScreenGui'{
	Name = "SpearGui",
	Create'Frame'{
		Name = "ChargeFrame",
		Style = 'RobloxRound',
		Size = UDim2.new(0, 256, 0, 32),
		Position = UDim2.new(0.5, -128, 1, -128),
		Create'Frame'{
			Name = "ProgressBar",
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = Color3.new(0.8, 0.2, 0.2),
		},
		Create'TextLabel'{
			Name = "ProgressLabel",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = 'Arial',
			FontSize = 'Size18',
			TextColor3 = Color3.new(0.8, 0.8, 0.8),
			Text = "Click and hold to charge attack!",
		},	
	},
}


function setProgress(frac)
	frac = frac or 0
	if frac == 0 then
		mGui.ChargeFrame.ProgressLabel.Text = "Click and hold to charge attack!"
	else
		mGui.ChargeFrame.ProgressLabel.Text = "Charging "..(math.floor(frac*100)).."%" 
	end
	mGui.ChargeFrame.ProgressBar.Size = UDim2.new(frac, 0, 1, 0)
end


local mDamageCn;
local mCheckHitCn;


local CurrentCharge = 0
local Equipped = false
local ClickNum = 0
local Checking = false
local CheckVelocity = 0


Tool.MouseClick:connect(function()
	ClickNum = ClickNum + 1
	local thisClick = ClickNum
	--
	WeaponDamage:setDamage(25)
	Tool.AnimationProvider:getAnimation('stab'):Play(0, 1, 4)
	Delay(0.3, function()
		if Equipped and Tool.MouseDown and ClickNum == thisClick then
			WeaponDamage:setDamage(0)
			--Imma charjin mah speeaar!!
			Tool.AnimationProvider:getAnimation('charge'):Play(0, 1, 8)
			Tool.Humanoid.WalkSpeed = 0
			--
			CurrentCharge = 0
			local startCharge = tick()
			while Tool.MouseDown do
				CurrentCharge = math.min(1, (tick()-startCharge)/ChargeTime)
				setProgress(CurrentCharge)
				wait()
			end
			setProgress()
			--
			Checking = true
			Tool.Humanoid.WalkSpeed = 16
			Tool.AnimationProvider:getAnimation('charge'):Stop(0)
			Tool.AnimationProvider:getAnimation('check'):Play(0, 1, 8)
			Tool.Humanoid.Jump = true
			--
			local torso = Tool.Character.Torso
			local fly = Create'BodyVelocity'{
				velocity = torso.CFrame.lookVector*CurrentCharge*100,
				maxForce = Vector3.new(1000000, 0, 1000000),
				Parent = torso,
			}
			local forceDown = Create'BodyForce'{
				force = Vector3.new(0, -15000, 0),
				Parent = torso,
			}
			--
			local footHitGroundCn;
			local continueWait = true
			if Tool.Character:FindFirstChild("Right Leg") then
				footHitGroundCn = Tool.Character["Right Leg"].Touched:connect(function(part)
					continueWait = false
				end)
			end
			local startJumpTime = tick()
			while (tick()-startJumpTime) < 1 and continueWait do wait() end
			Tool.AnimationProvider:getAnimation('check'):Stop()
			if footHitGroundCn then
				footHitGroundCn:disconnect()
			end
			fly:Destroy()
			forceDown:Destroy()
			Delay(0.5, function()
				Checking = false
			end)
		else
			wait(0.4)
			if ClickNum == thisClick then
				WeaponDamage:setDamage(0)
			end
		end
	end)
end)


Tool.Equipped:connect(function()
	Tool.Handle = Tool.Tool.Handle
	mGui.Parent = Tool.Player.PlayerGui
	Tool.AnimationProvider:getAnimation('equip'):Play(0.1, 1, 3)
	--
	Equipped = true

	Delay(0, function()
		--make a "tip" for the spear since only it's top should do damage
		local tipPart = Create'Part'{
			Name = "HandleTip",
			Parent = Tool.Tool,
			FormFactor = 'Custom',
			CanCollide = false,
			Transparency = 1,
			Size = Vector3.new(0.7, 1.5, 0.7),
		}
		local tipWeld = Create'Weld'{
			Name = "HandleTipWeld",
			Parent = Tool.Handle,
			Part0 = Tool.Handle,
			C0 = CFrame.new(0, 2.8, 0),
		}
		tipWeld.Part1 = tipPart

		--add handling for damage
		mDamageCn = tipPart.Touched:connect(function(part)
			local hum = FindHumanoid(part)
			if hum then
				TagHumanoid(hum)
				hum:TakeDamage(WeaponDamage:getDamage())
			end
		end)
		mCheckHitCn = Tool.Handle.Touched:connect(function(part)
			if Checking then
				local hum = FindHumanoid(part)
				if hum then
					local torso = hum.Parent:FindFirstChild("Torso")
					if torso then
						hum.Jump = true
						local myTorso = Tool.Character.Torso
						local fly = Create'BodyVelocity'{
							velocity = myTorso.CFrame.lookVector*CurrentCharge*120,
							maxForce = Vector3.new(1000000, 0, 1000000),
							Parent = torso,
						}
						Tool.Bin:add(function()
							fly:Destroy()
						end, 'kill-hit-fly')
						Delay(0.5, function()
							fly:Destroy()
						end)
					end
					TagHumanoid(hum)
					hum:TakeDamage(50*CurrentCharge)
				end
			end
		end)
	end)
end)


Tool.Unequipped:connect(function()
	mGui.Parent = nil
	Tool.AnimationProvider:getAnimation('equip'):Stop(0)
	Tool.AnimationProvider:getAnimation('stab'):Stop(0)
	Tool.AnimationProvider:getAnimation('charge'):Stop(0)
	Tool.AnimationProvider:getAnimation('check'):Stop(0)
	--
	Equipped = false
	if mDamageCn then
		mDamageCn:disconnect()
		mCheckHitCn:disconnect()
		mDamageCn = nil
		mCheckHitCn = nil
	end
end)