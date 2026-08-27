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



























function CreateSentry(position)
	local sentry = Create'Model'{
		Name = (Tool.Player.Name.."'s Sentry"),
		Create'Part'{
			Name = "Torso",
			FormFactor = 'Custom',
			Size = Vector3.new(3.8, 1.2, 3.6),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68251550',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',
				Scale = Vector3.new(2,2,2),
			},
			Create'Motor6D'{Name = "Neck",},
		},
		Create'Part'{
			Name = "Head",
			FormFactor = 'Custom',
			Size = Vector3.new(2, 2, 2),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68237468',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',
				Scale = Vector3.new(2,2,2),
			},
			Create'Motor6D'{Name = "RightAttach",},
			Create'Motor6D'{Name = "LeftAttach",},
			Create'Motor6D'{Name = "CannonAttach",},
		},
		Create'Part'{
			Name = "CannonMove",
			FormFactor = 'Custom',
			Size = Vector3.new(0.2, 0.2, 0.2),
			Create'Motor6D'{Name = "Barrel1Attach",},
			Create'Motor6D'{Name = "Barrel2Attach",},
			Create'Sound'{
				Name = "FireSound",
				SoundId = "http://www.roblox.com/asset/?id=68433873",
			},
		},
		Create'Part'{
			Name = "Barrel1",
			FormFactor = 'Custom',
			Size = Vector3.new(0.6, 2, 0.6),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68251580',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',				
				Scale = Vector3.new(2,2,2),
			},
		},
		Create'Part'{
			Name = "Barrel2",
			FormFactor = 'Custom',
			Size = Vector3.new(0.6, 2, 0.6),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68251580',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',				
				Scale = Vector3.new(2,2,2),
			},
		},
		Create'Part'{
			Name = "FlangeLeft",
			FormFactor = 'Custom',
			Size = Vector3.new(1.2, 0.4, 3.6),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68237502',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',
				Scale = Vector3.new(2,2,2),
			},
		},
		Create'Part'{
			Name = "FlangeRight",
			FormFactor = 'Custom',
			Size = Vector3.new(1.2, 0.4, 3.6),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68237527',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',
				Scale = Vector3.new(2,2,2),
			},
		},
		Create'Part'{
			Name = "SideLeft",
			FormFactor = 'Custom',
			Size = Vector3.new(1.4, 2.8, 1.2),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68237451',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',
				Scale = Vector3.new(2,2,2),
			},
			Create'Motor6D'{Name = "FlangeAttach",},
		},
		Create'Part'{
			Name = "SideRight",
			FormFactor = 'Custom',
			Size = Vector3.new(1.4, 2.8, 1.2),
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=68237486',
				TextureId = 'http://www.roblox.com/asset/?id=68237809',
				Scale = Vector3.new(2,2,2),
			},
			Create'Motor6D'{Name = "FlangeAttach",},
		},
		Create'ObjectValue'{
			Name = "TurretOwner",
			Value = Tool.Player,	
		},
	}
	---------------------------
	local neck = sentry.Torso.Neck
	neck.Part0 = sentry.Torso
	neck.Part1 = sentry.Head
	neck.C0 = CFrame.new(0, 0.4, 0.1)*CFrame.Angles(-math.pi/2, 0, 0)
	neck.C1 = CFrame.new(0, 0, -1)
	--
	local cannonm = sentry.Head.CannonAttach
	cannonm.Part0 = sentry.Head
	cannonm.Part1 = sentry.CannonMove
	cannonm.C0 = CFrame.new(0, 0.6, 0.2)*CFrame.Angles(math.pi/2, 0, 0)
	--
	local barrel1 = sentry.CannonMove.Barrel1Attach
	barrel1.Part0 = sentry.CannonMove
	barrel1.Part1 = sentry.Barrel1
	barrel1.C0 = CFrame.new(0, 0.3, -1)*CFrame.Angles(-math.pi/2, 0, 0)
	--
	local barrel2 = sentry.CannonMove.Barrel2Attach
	barrel2.Part0 = sentry.CannonMove
	barrel2.Part1 = sentry.Barrel2
	barrel2.C0 = CFrame.new(0, -0.3, -1)*CFrame.Angles(-math.pi/2, 0, 0)
	--
	local rightm = sentry.Head.RightAttach
	rightm.Part0 = sentry.Head
	rightm.Part1 = sentry.SideRight
	rightm.C0 = CFrame.new(1.7, -0.4, 0.4)
	--
	local leftm = sentry.Head.LeftAttach
	leftm.Part0 = sentry.Head
	leftm.Part1 = sentry.SideLeft
	leftm.C0 = CFrame.new(-1.6, -0.4, 0.4)
	--
	local flangel = sentry.SideLeft.FlangeAttach
	flangel.Part0 = sentry.SideLeft
	flangel.Part1 = sentry.FlangeLeft
	flangel.C0 = CFrame.new(0.7, 1.4, 0.05)
	--
	local flanger = sentry.SideRight.FlangeAttach
	flanger.Part0 = sentry.SideRight
	flanger.Part1 = sentry.FlangeRight
	flanger.C0 = CFrame.new(-0.7, 1.4, 0.05)
	--
	local humanoid = Create'Humanoid'{
		MaxHealth = 200,
		Health = 200,
		Torso = sentry.Torso,
		Parent = sentry,
	}
	--

	--make the main runner script
	local runner = Tool.Tool.SentryTurret_Sentry:Clone()
	local runnerTarget = Create'ObjectValue'{
		Name = 'MyTargetTurret',
		Value = sentry,
		Parent = runner,
	}
	runner.Parent = Tool.Player.Character

	--make the cleaner script
	local cleaner = Tool.Tool.SentryTurret_SentryCleanup:Clone()
	cleaner.Parent = sentry

	--now done, put it in the right place in the workspace
	sentry.Torso.CFrame = CFrame.new(position)
	sentry.Parent = game.Workspace

	runner.Disabled = false
	cleaner.Disabled = false

	return sentry
end


--gui
local Gui = Create'ScreenGui'{
	Name = "SentryTurret_Gui",
	Create'TextButton'{
		Name = "DestroyButton",
		Style = 'RobloxButton',
		Font = 'Arial',
		FontSize = 'Size24',
		Text = "Destroy Current Turret\n(Press `Q`)",
		Position = UDim2.new(0, 0, 0.5, -128),
		Size = UDim2.new(0, 128, 0, 128),
		TextWrap = true,
		TextColor3 = Color3.new(1,1,1),
	},
}


--create or get the value to track the current sentry (deffered to on equip)
local SentryValue
local SentryTargetValue


--utility check
function HasSentry()
	return (SentryValue.Value ~= nil) and 
	       (SentryValue.Value:FindFirstChild("Humanoid")) and
	       (SentryValue.Value.Humanoid.Health > 0)
end


--create a sentry at a position and register it to this tool
function BuildSentry(position)
	--remove any old sentry
	if SentryValue.Value ~= nil then
		local humanoid = SentryValue.Value:FindFirstChild("Humanoid")
		if humanoid then
			--kill the turret
			humanoid.Health = 0
		else
			--something terrible happened, just delete it
			SentryValue.Value:Destroy()
			SentryValue.Value = nil
		end
	end

	--now create a new one
	local new = CreateSentry(position)
	SentryValue.Value = new
end


function DestroySentry()
	if SentryValue.Value then
		local hum = SentryValue.Value:FindFirstChild("Humanoid")
		if hum then
			hum.Health = 0
		else
			SentryValue.Value:Destroy()
		end
		SentryValue.Value = nil
	end
end


--call on destroying code
Gui.DestroyButton.MouseButton1Down:connect(function()
	DestroySentry()
end)
Tool.KeyDown:connect(function(key)
	if key:lower() == "q" then
		DestroySentry()
	end
end)


local Equipped = false

Tool.Equipped:connect(function()
	Gui.Parent = Tool.Player.PlayerGui
	Equipped = true
	if not Tool.Player:FindFirstChild("SentryValue") then
		Create'ObjectValue'{
			Name = "SentryValue",
			Parent = Tool.Player,
		}
	end
	if not Tool.Player:FindFirstChild("SentryTargetValue") then
		Create'ObjectValue'{
			Name = "SentryTargetValue",
			Parent = Tool.Player,
		}
	end
	SentryTargetValue = Tool.Player.SentryTargetValue
	SentryValue = Tool.Player.SentryValue

	while Equipped do
		wait()
		if SentryValue.Value then
			local trg = Tool.Mouse.Target
			local foundHum = false
			if trg and trg.Parent and trg.Parent.Parent then
				local hum = trg.Parent:FindFirstChild("Humanoid")
				hum = hum or trg.Parent.Parent:FindFirstChild("Humanoid")
				--
				if hum then
					foundHum = true
				end
			end
			if foundHum then
				--found target
				Tool.Mouse.Icon = "http://www.roblox.com/asset/?id=68414013"
			else
				--no target
				Tool.Mouse.Icon = "http://www.roblox.com/asset/?id=68414005"
			end
		else
			if (Tool.Mouse.Hit.p-Tool.Character.Torso.Position).magnitude > 20 then
				--out of range
				Tool.Mouse.Icon = "http://www.roblox.com/asset/?id=68415132"
			else
				--build icon
				Tool.Mouse.Icon = "http://www.roblox.com/asset/?id=68413998"
			end
		end
	end
end)
Tool.Unequipped:connect(function()
	Gui.Parent = nil
	Equipped = false
end)


Tool.MouseClick:connect(function()
	if SentryValue.Value then
		local trg = Tool.Mouse.Target
		if trg and trg.Parent and trg.Parent.Parent then
			local hum = trg.Parent:FindFirstChild("Humanoid")
			hum = hum or trg.Parent.Parent:FindFirstChild("Humanoid")
			--
			if hum then
				SentryTargetValue.Value = hum
			end
		end
	else
		if (Tool.Mouse.Hit.p-Tool.Character.Torso.Position).magnitude < 20 then
			BuildSentry(Tool.Mouse.Hit.p)
		end
	end
end)


script.Parent.Grip = CFrame.Angles(math.pi/2, 0, 0)*CFrame.new(-0.1, -0.7, 0.1)
while not script.Parent:FindFirstChild("Handle") do
	script.Parent.ChildAdded:wait()
end
--edit handle
local Handle = script.Parent.Handle
Handle.Mesh.TextureId = "http://www.roblox.com/asset/?id=16884673"
Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=16884681"
Handle.Mesh.Scale = Vector3.new(1, 1, 1)
Handle.Size = Vector3.new(1, 1, 4)