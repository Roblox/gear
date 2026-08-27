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
	this.KeyUp = CreateSignal()
	this.KeyState = {}

	local mLastClickTime = 0

	--
	local mCharacterChangedCn = nil
	local mCharacterChildAddedCn = nil
	local function locateAndAssignParts(ch)
		if ch:FindFirstChild('Humanoid') then this.Humanoid = ch.Humanoid end
		if ch:FindFirstChild('Head') then this.HeadPart = ch.Head end
		if ch:FindFirstChild('Torso') then this.TorsoPart = ch.Torso end
		if ch:FindFirstChild('Right Arm') then 	this.RightArmPart = ch['Right Arm'] end
		if ch:FindFirstChild('Left Arm') then 	this.LeftArmPart = 	ch['Left Arm'] end
		if ch:FindFirstChild('Right Leg') then 	this.RightLegPart = ch['Right Leg'] end
		if ch:FindFirstChild('Left Leg') then 	this.LeftLegPart = 	ch['Left Leg'] end
	end
	local function listenForCharacterAndParts(player)
		this.Tool = script.Parent
		this.Player = player
		--
		if mCharacterChangedCn then mCharacterChangedCn:disconnect() end
		mCharacterChangedCn = player.Changed:connect(function(prop)
			if prop == 'Character' and player.Character then
				if mCharacterChildAddedCn then mCharacterChildAddedCn:disconnect() end
				mCharacterChildAddedCn = player.Character.ChildAdded:connect(function(ch)
					locateAndAssignParts(player.Character)
				end)
			end
		end)
		if player.Character then
			if mCharacterChildAddedCn then mCharacterChildAddedCn:disconnect() end
			mCharacterChildAddedCn = player.Character.ChildAdded:connect(function(ch)
				locateAndAssignParts(player.Character)
			end)
		end
	end
	script.Parent.Changed:connect(function(prop)
		if prop == 'Parent' then
			--if it's in a character or backpack, find stuff
			local backpack = script.Parent.Parent
			if backpack and backpack:IsA('Backpack') then
				listenForCharacterAndParts(backpack.Parent)
			end
		end
	end)
	--if I'm allready in the backpack, listen for character
	if script.Parent.Parent:IsA('Backpack') then
		listenForCharacterAndParts(script.Parent.Parent.Parent)
	end
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
		locateAndAssignParts(this.Player.Character)

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
			this.KeyState[key] = true
			this.KeyDown:fire(key)
		end)
		mouse.KeyUp:connect(function(key)
			this.KeyState[key] = false
			this.KeyUp:fire(key)
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


--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

local RECHARGE_TIME = 3.5   --(seconds)
local ATTACK_DURATION = 2   --(seconds)
local STUN_LENGTH = 2       --(seconds)
local STUN_RADIUS = 40      --(studs)
local STUN_EXPAND_RATE = 40 --(studs/second)

Tool.AnimationProvider:registerAnimation('equip', 'http://www.roblox.com/asset/?id=73148224')
Tool.AnimationProvider:registerAnimation('drink', 'http://www.roblox.com/asset/?id=73148207')
Tool.AnimationProvider:registerAnimation('screamer', 'http://www.roblox.com/asset/?id=73137669')
Tool.SoundProvider:registerSound('scream', 'http://www.roblox.com/asset/?id=73137902')

local Selected = false
local Firing = false

Tool.MouseClick:connect(function()
	if tick() < Tool.Tool.NextAttack.Value then return end
	Tool.Tool.NextAttack.Value = tick()+RECHARGE_TIME+ATTACK_DURATION+0.5
	--
	Firing = true
	local shockwaves = {}
	Tool.Bin:add(function()
		--clean up shockwaves
		for s, _ in pairs(shockwaves) do
			s.Part:Destroy()
		end
		Firing = false
		Tool.AnimationProvider:getAnimation('screamer'):Stop()
	end, 'shockwaves')
	--
	Tool.AnimationProvider:getAnimation('drink'):Play(0, 1, 4)
	repeat until Tool.AnimationProvider:getAnimation('drink').KeyframeReached:wait() == 'complete'
	if not Selected then return end
	Tool.AnimationProvider:getAnimation('screamer'):Play(0.1, 1, 4)
	Tool.SoundProvider:getSound('scream'):Play()
	--
	local StartTime = tick()
	local Ticks = 0 
	while true do
		Ticks = Ticks + 1
		if not Selected then break end
		if tick()-StartTime > ATTACK_DURATION then break end
		--
		--crate a new shockwave
		if Ticks % 4 == 0 then
			local shock = {}
			shock.Part = Create'Part'{
				Name = "Scream_Shockwave";
				Anchored = true;
				CanCollide = false;
				FormFactor = 'Custom';
				Parent = Tool.Character;
				Size = Vector3.new(2, 1, 2);
				Transparency = 1;
				--
				Create'Decal'{
					Name = 'TopDecal';
					Texture = 'http://www.roblox.com/asset/?id=11187115';
					Face = 'Top';
				};
				Create'Decal'{
					Name = 'BottomDecal';
					Texture = 'http://www.roblox.com/asset/?id=11187115';
					Face = 'Bottom';
				};
			}
			shock.Part.CFrame = CFrame.new(Tool.HeadPart.Position)*
			                    CFrame.Angles(math.random(-10,10)/30, 0, math.random(-10,10)/30)
			shock.SkewX = math.random(8,12)/10
			shock.SkewZ = math.random(8,12)/10 
			shock.Part.Touched:connect(function(part)
				local hum = part.Parent:FindFirstChild('Humanoid')
				if hum and hum ~= Tool.Humanoid then
					local stunScript = hum.Parent:FindFirstChild('StunScriptRef')
					if not stunScript then
						stunScript = script.Parent.ScreamerScript:Clone()
						stunScript.TargetModel.Value = part.Parent
						local stunScriptRef = Create'ObjectValue'{
							Name = 'StunScriptRef';
							Parent = part.Parent;
							Value = stunScript;
						}
						if game.Players:GetPlayerFromCharacter(part.Parent) then
							stunScript.Parent = hum.Parent
						else
							stunScript.Parent = Tool.Character
						end
						stunScript.Disabled = false
						stunScript = stunScriptRef
					end
					local tm = STUN_LENGTH
					if not stunScript.Value:FindFirstChild('EndTime') then
						while not stunScript.Value:FindFirstChild('EndTime') do
							stunScript.ChildAdded:wait()
						end
					end
					stunScript.Value.EndTime.Value = not stunScript.Value.EndTime.Value
				end
			end)
			shock.Radius = 1
			shockwaves[shock] = true
		end
		--
		--move shockwaves
		for s, _ in pairs(shockwaves) do
			s.Radius = s.Radius + STUN_EXPAND_RATE/30
			s.Part.Parent = nil
			s.Part.Size = Vector3.new(s.Radius*2*s.SkewX, 1, s.Radius*2*s.SkewZ)
			s.Part.Parent = Tool.Character
			--
			local perc = s.Radius / STUN_RADIUS
			if perc > 1 then
				shockwaves[s] = nil
				s.Part:Destroy()
			else
				s.Part.TopDecal.Transparency = perc
				s.Part.BottomDecal.Transparency = perc
			end
		end
		--
		wait()
	end
	--and do cleanup
	Tool.Bin:clean('shockwaves')
end)	

local RechargeGui = Create'ScreenGui'{
	Name = 'DragonHeadGui',
	Create'Frame'{
		Name = 'MainFrame',
		Style = 'RobloxRound',
		Size = UDim2.new(0, 256, 0, 32),
		Position = UDim2.new(0.5, -128, 1, -150),
		Create'Frame'{
			Name = 'ProgressBar',
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 0.2, 0.2),
			Size = UDim2.new(1, 0, 1, 0),
		},
		Create'TextLabel'{
			Name = 'ProgressText',
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Font = 'ArialBold',
			FontSize = 'Size24',
			Text = "~ Ready ~",
			TextColor3 = Color3.new(0.9, 0.9, 0.9),
		},
	}
}

local function SetProgress(frac)
	RechargeGui.MainFrame.ProgressBar.Size = UDim2.new(frac, 0, 1, 0)
	if frac == 1 then
		RechargeGui.MainFrame.ProgressText.Text = "~ Ready ~"
	else
		RechargeGui.MainFrame.ProgressText.Text = "Charging "..math.floor(frac*100).."%"
	end
end

Tool.Equipped:connect(function()
	RechargeGui.Parent = Tool.Player.PlayerGui
	Selected = true
	Tool.AnimationProvider:getAnimation('equip'):Play(0.1, 1, 4)
	--
	while Selected do
		if Firing then
			SetProgress(0)
		else
			local timeLeft = script.Parent.NextAttack.Value-tick()
			local fracLeft = timeLeft/RECHARGE_TIME
			SetProgress(math.max(math.min(1, 1-fracLeft), 0))
		end
		wait()
	end
end)

Tool.Unequipped:connect(function()
	RechargeGui.Parent = nil
	Selected = false
	Tool.AnimationProvider:getAnimation('equip'):Stop()
end)