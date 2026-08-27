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


local CurrentToolMode = nil

local function SetToolMode(mode)
	if CurrentToolMode then
		CurrentToolMode.onDeselect()
	end
	CurrentToolMode = mode
	if mode then
		mode.onSelect()
	end
end
local CreateMode = nil
local TargetMode = nil

-------------------------------------------
---------- interface in player ------------
local TargetValue = nil
local SnowmanListModel = nil
local function SetTarget(humanoid)
	TargetValue.Value = humanoid
end


-------------------------------------------
---------------- settings -----------------
class'ToolSettings'(nil, function(def)
	def.MaxSnowmanCount = 3
	def.CreationTime = 1 --1 second
	def.MaxRange = 30
end)


-------------------------------------------
-- isolated "flash lasso effect" class which
-- can be reused in other gear in the future
-- API:
-- FlashLasso(from, to, brickcolor):
--  Creates a new flashlasso between a |from|
--  and a |to| position with a given |brickcolor|
--
-- setTransparency(factor):
--  Sets the transparency of the effect. Usefull
--  for fading the effect in-out if desired.
--
-- destroy():
--  Cleans up any resources the FlashLasso may
--  have put into the workspace or other 
--  locations.
-------------------------------------------
class'FlashLasso'(function(this, from, to, color)
	local mRunFlag = true
	local mTransparency = 0

	--
	local K = (2*math.pi)/5
	local Omega = (2*math.pi)*6
	local function GetMainBeamDisp(x, t)
		return (math.cos(K*x - Omega*t)+math.cos(K*x - (0.2*Omega)*t))*0.2, 
		       (math.sin(K*x - Omega*t)+math.cos(K*x - (0.2*Omega)*t))*0.2
	end

	--
	local mBeamDir = CFrame.new(from, to)
	local mBeamLength = (to-from).magnitude
	--
	local mMainBeamSegCount = math.ceil(mBeamLength/FlashLasso.DesiredSegSize)
	local mMainBeamSegLen = mBeamLength/mMainBeamSegCount
	local mMainBeamSegs = {}
	for i = 1, mMainBeamSegCount do
		mMainBeamSegs[i] = Create'Part'{
			Name = 'BeamSeg',
			Parent = game.Workspace,
			Anchored = true,
			CanCollide = false,
			Archivable = false,
			FormFactor = 'Custom',
			Transparency = FlashLasso.BeamTransparency,
			BrickColor = color,
			BottomSurface = 'Smooth',
			TopSurface = 'Smooth',
		}
	end

	local function SetMainBeamState(t)
		local xysize = FlashLasso.BeamRadius*2
		for i = 1, mMainBeamSegCount do
			local seg = mMainBeamSegs[i]
			local z1 = (i-1)*mMainBeamSegLen
			local x1, y1 = GetMainBeamDisp(z1, t)
			local z2 = (i)*mMainBeamSegLen
			local x2, y2 = GetMainBeamDisp(z2, t)
			--
			local p1 = (mBeamDir*CFrame.new(x1, y1, -z1)).p
			local p2 = (mBeamDir*CFrame.new(x2, y2, -z2)).p
			--
			seg.Size = Vector3.new(xysize, xysize, (p1-p2).magnitude)
			seg.CFrame = CFrame.new(0.5*(p1+p2), p2)
		end
	end
	SetMainBeamState(tick())

	local mSparkSegs = {}
	local function MoveSparkSegs()
		local xysize = FlashLasso.BeamRadius*1.5
		for seg, _ in pairs(mSparkSegs) do
			if math.random(1, 20) == 20 or seg.Z > mBeamLength then
				mSparkSegs[seg] = nil
				seg.Part.Parent = nil
			else
				local nz = seg.Z+seg.Length
				local nx = (math.random(-5,5)/10)
				local ny = (math.random(-5,5)/10)
				--
				local po = (mBeamDir*CFrame.new(seg.LastX, seg.LastY, -seg.Z)).p
				local pn = (mBeamDir*CFrame.new(nx, ny, -nz)).p
				--
				seg.Z = nz
				seg.LastX = nx
				seg.LastY = ny
				seg.Part.Size = Vector3.new(xysize, xysize, (po-pn).magnitude)
				seg.Part.CFrame = CFrame.new(0.5*(po+pn), pn)
			end
		end
	end

	Spawn(function()
		while mRunFlag do
			SetMainBeamState(tick())

			--make a spark
			local spark = {}
			spark.Z = 0
			spark.LastX = 0
			spark.LastY = 0
			spark.Length = math.random(2, 4)
			spark.Part = Create'Part'{
				Name = 'BeamSeg',
				Parent = game.Workspace,
				Anchored = true,
				CanCollide = false,
				Archivable = false,
				FormFactor = 'Custom',
				Transparency = (1-((1-FlashLasso.SparkTransparency)*(1-mTransparency))),
				BrickColor = color,
				BottomSurface = 'Smooth',
				TopSurface = 'Smooth',	
				Size = Vector3.new(FlashLasso.BeamRadius*2, 
				                   FlashLasso.BeamRadius*2, 
				                   spark.Length),				
			}
			mSparkSegs[spark] = true
			
			MoveSparkSegs()

			wait()
		end
	end)

	function this:destroy()
		mRunFlag = false
		for _, p in pairs(mMainBeamSegs) do
			p.Parent = nil
		end
		for seg, _ in pairs(mSparkSegs) do
			seg.Part.Parent = nil
		end
	end

	function this:setTransparency(f)
		local mainTrans = 1-((1-FlashLasso.BeamTransparency)*(1-f))
		for _, seg in pairs(mMainBeamSegs) do
			seg.Transparency = mainTrans
		end
		local sparkTrans = 1-((1-FlashLasso.SparkTransparency)*(1-f))
		for seg, _ in pairs(mSparkSegs) do
			seg.Part.Transparency = sparkTrans
		end
		mTransparency = f
	end

end, function(def)
	def.DesiredSegSize = 2
	def.BeamTransparency = 0.5
	def.SparkTransparency = 0
	def.BeamRadius = 0.2
end)


-------------------------------------------
---------- listen for events --------------
Tool.Equipped:connect(function(mouse)
	--set up interface
	if not Tool.Player:FindFirstChild('SnowmanGun_Target') then
		Create'ObjectValue'{
			Parent = Tool.Player,
			Name = 'SnowmanGun_Target',
		}
	end
	TargetValue = Tool.Player:FindFirstChild('SnowmanGun_Target')

	if not Tool.Player:FindFirstChild('SnowmanGun_SnowmanList') then
		Create'Model'{
			Parent = Tool.Player,
			Name = 'SnowmanGun_SnowmanList',
		}
	end
	SnowmanListModel = Tool.Player:FindFirstChild('SnowmanGun_SnowmanList')

	--
	SetToolMode(CreateMode)
end)
Tool.Unequipped:connect(function()
	SetToolMode(nil)
end)
Tool.MouseClick:connect(function(mouse)
	CurrentToolMode.onPress(mouse)
end)
Tool.KeyDown:connect(function(key)
	if key:lower() == 'e' then
		SetToolMode(CreateMode)
	elseif key:lower() == 'q' then
		SetToolMode(TargetMode)
	end
end)


-------------------------------------------
--------- shared gui between modes --------
local Gui = Create'ScreenGui'{
	Name = 'SnowmanGunGui',
}
local ModeGui = Create'Frame'{
	Parent = Gui,
	--
	Name = 'ModeSelect',
	Style = 'RobloxRound',
	Size = UDim2.new(0, 128, 0, 256),
	Position = UDim2.new(0, 16, 0.5, -128),
	Create'TextButton'{
		Name = 'SetMode_Create',
		Style = 'RobloxButton',
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(),
		Font = 'Arial',
		TextColor3 = Color3.new(1,1,1),
		FontSize = 'Size18',
		Text = "Create\nMode\n(`E` Key)",
		TextWrap = true,
	},
	Create'TextButton'{
		Name = 'SetMode_Target',
		Style = 'RobloxButton',
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		Font = 'Arial',
		TextColor3 = Color3.new(1,1,1),
		FontSize = 'Size18',
		Text = "Target\nMode\n(`Q` Key)",
		TextWrap = true,
	},
}
ModeGui.SetMode_Create.MouseButton1Down:connect(function()
	SetToolMode(CreateMode)
end)
ModeGui.SetMode_Target.MouseButton1Down:connect(function()
	SetToolMode(TargetMode)
end)

local CreationProgressGui = Create'Frame'{
	Parent = Gui,
	Visible = false,
	--
	Name = 'CreationProgress',
	Style = 'RobloxRound',
	Size = UDim2.new(0, 256, 0, 64),
	Position = UDim2.new(0.5, -128, 0, 16),
	--
	Create'TextLabel'{
		Name = 'ProgressLabel',
		Text = "",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		Font = 'Arial',
		FontSize = 'Size14',
	},
}

local TargetGui = Create'BillboardGui'{
	Name = 'SnowmanGun_Targeter',
	--
	Create'ImageLabel'{
		Visible = false,
		Name = 'TrackerImage',
		Image = 'http://www.roblox.com/asset/?id=66740738',
		Size = UDim2.new(9, 0, 9, 0),
		Position = UDim2.new(-4, 0, -4, 0),
		BackgroundTransparency = 1,
	},
	--
	Size = UDim2.new(1, 0, 1, 0),
	AlwaysOnTop = true,
}

local LabelMessageUid = 0
local function UnsetCreationProgressLabel()
	CreationProgressGui.ProgressLabel.Text = "Click and hold to create snowman turrets!"
end
local function SetCreationProgressLabel(frac)
	LabelMessageUid = LabelMessageUid + 1
	local muid = LabelMessageUid
	--
	if type(frac) == 'number' then
		local perc = tostring(frac*100):sub(1,3).."%"
		CreationProgressGui.ProgressLabel.Text = "Creating... "..perc
	elseif type(frac) == 'string' then
		CreationProgressGui.ProgressLabel.Text = frac
	end
	--
	return function()
		if LabelMessageUid == muid then
			UnsetCreationProgressLabel()
		end
	end
end


-------------------------------------------
----------- utility functions -------------
local function GetFireFrom() --get the position of the tip of the weapon
	return (Tool.Tool.Handle.CFrame * CFrame.new(-0.2, 1.8, 0.05)).p
end

local function ClassifySurface(part, point)
	local psize = part.Size
	local reldif = part.CFrame:toObjectSpace(CFrame.new(point)).p - psize/2
	local xdif = math.min(math.abs(reldif.x - psize.x), math.abs(reldif.x))
	local ydif = math.min(math.abs(reldif.y - psize.y), math.abs(reldif.y))
	local zdif = math.min(math.abs(reldif.z - psize.z), math.abs(reldif.z))
	if xdif < math.min(ydif, zdif) then
		if math.abs(reldif.x - psize.x) < reldif.x then
			return Enum.NormalId.Left
		else
			return Enum.NormalId.Right
		end
	elseif ydif < math.min(xdif, zdif) then
		if math.abs(reldif.y - psize.y) < reldif.y then
			return Enum.NormalId.Bottom
		else
			return Enum.NormalId.Top
		end
	elseif zdif < math.min(xdif, ydif) then
		if math.abs(reldif.z - psize.z) < psize.z then
			return Enum.NormalId.Front
		else
			return Enum.NormalId.Back
		end
	end
end

local function IsAbove(part, point)
	local normal = ClassifySurface(part, point)
	return ((part.CFrame-part.CFrame.p)*Vector3.FromNormalId(normal)).y > 0
end

local function GetSnowmanList()
	local snowmen = {}
	for _, sn in pairs(SnowmanListModel:GetChildren()) do
		snowmen[#snowmen+1] = sn.Value
	end
	return snowmen
end


-------------------------------------------
----------- create snowmen mode -----------
CreateMode = {}
function CreateMode.onPress(mouse)
	--do a raycast to find the true hit position of the shot
	local dirray = Ray.new(GetFireFrom(), (mouse.Hit.p-GetFireFrom()).unit*10000)
	local obj, pos = game.Workspace:FindPartOnRay(dirray, Tool.Character)

	--no hit object? Just bail out
	if not obj then return end

	--if the hit isn't close enough then bail out
	if (pos-GetFireFrom()).magnitude > ToolSettings.MaxRange then
		--show a failed message
		local unsetLabel = SetCreationProgressLabel("Target not in range!")
		Delay(1, unsetLabel)

		--show a failed shot thing to show the range
		local failedFlash = CreateFlashLasso(GetFireFrom(), 
		                                     GetFireFrom()+(pos-GetFireFrom()).unit*ToolSettings.MaxRange, 
		                                     BrickColor.new(23))
		--add it to the bin to make sure it gets removed
		Tool.Bin:add(function()
			failedFlash:destroy()
		end, 'kill_failed_shot_effect')

		--now, fade it out
		for i = 0, 1, 0.1 do
			failedFlash:setTransparency(i)
			wait()
		end

		--and clean up
		Tool.Bin:clean('kill_failed_shot_effect')
		return
	end

	--I hit something
	if obj.Parent and obj.Parent:FindFirstChild('SnowmanOwner') then
		--fired at a snowman
		if obj.Parent.SnowmanOwner.Value == Tool.Player then
			local snowman_hum = obj.Parent.Humanoid
			--fired at one of my own snowmen, delete it
			SetCreationProgressLabel("Deleting...")

			--effect for a glow where the snowman is being created
			local deletionGlow = Create'Part'{
				Parent = game.Workspace,
				--
				Name = 'DeleteSnowmanGlow',
				Transparency = 1,
				Anchored = true,
				Archivable = false,
				CFrame = CFrame.new(pos),
				--
				Create'Fire'{
					Name = 'GlowEffect',
					Color = Color3.new(1, 0.2, 0.2),
					Size = 3,	
				},
			}
			local deletionFlash = CreateFlashLasso(GetFireFrom(), pos, BrickColor.new(21))

			--slow down the character
			Tool.Humanoid.WalkSpeed = 0

			--set up clean-up
			Tool.Bin:add(function()
				deletionFlash:destroy()
				deletionGlow.Parent = nil
				UnsetCreationProgressLabel()
				Tool.Humanoid.WalkSpeed = 16
			end, 'destroy_deletion_effects')

			--kill
			while Tool.MouseDown and snowman_hum.Health > 0 do
				snowman_hum:TakeDamage(2)
				wait()
			end
			UnsetCreationProgressLabel()

			--done, fade out effects
			deletionGlow.Parent = nil
			for i = 0, 1, 0.1 do
				deletionFlash:setTransparency(i)
				wait()
			end

			--clean up
			Tool.Bin:clean('destroy_deletion_effects')
		end
	else
		--check that there aren't too many snowmen
		if #GetSnowmanList() >= ToolSettings.MaxSnowmanCount then
			local unsetLabel = SetCreationProgressLabel("You have too many snowmen currently created!")
			Delay(1, unsetLabel)
			return
		end

		--fired somewhere else, see if I hit a relatively horizontal surface
		--that a snowman can be placed on. Surface could also be a terrain, and
		--unfortunately there's no sane way to check if that's a relatively
		--horisontal surface, so don't.
		if obj:IsA('Terrain') or IsAbove(obj, pos) then
			--all good, go to create a snowman.

			--effect for a glow where the snowman is being created
			local creationGlow = Create'Part'{
				Parent = game.Workspace,
				--
				Name = 'CreateSnowmanGlow',
				Transparency = 1,
				Anchored = true,
				Archivable = false,
				CFrame = CFrame.new(pos),
				--
				Create'Fire'{
					Name = 'GlowEffect',
					Color = Color3.new(0.2, 0.2, 1),
					Size = 3,	
				},
			}

			--effect for a line going from the gun to the snowman
			local creationLasso = CreateFlashLasso(GetFireFrom(), pos, BrickColor.new(23))

			--slow down the character
			Tool.Humanoid.WalkSpeed = 0

			--clean them up if all else fails
			Tool.Bin:add(function()
				creationGlow.Parent = nil
				creationLasso:destroy()
				UnsetCreationProgressLabel()
				Tool.Humanoid.WalkSpeed = 16
			end, 'destroy_creation_effects')

			SetCreationProgressLabel(0)
			for t = 0, ToolSettings.CreationTime, 0.1 do
				wait(0.1)
				if Tool.MouseDown then
					SetCreationProgressLabel(t/ToolSettings.CreationTime)
				else
					--if they released the mouse then bail out
					UnsetCreationProgressLabel()
					Tool.Bin:clean('destroy_creation_effects')
					return
				end
			end

			--finished the wait, do the creation
			local snowMan = Create'Model'{
				Name = Tool.Player.Name..'\'s Snowman',
				Create'Part'{
					Name = 'Head',
					FormFactor = 'Custom',
					Size = Vector3.new(1.2, 1.1, 1.2),
					BrickColor = BrickColor.new(1002), --`Mid gray`
					Create'SpecialMesh'{}, --The headmesh, defaults are correct
				},
				Create'Part'{
					Name = 'Mid',
					FormFactor = 'Custom',
					Size = Vector3.new(1.4, 1.2, 1.4),
					BrickColor = BrickColor.new(1002),
					Create'SpecialMesh'{},
					Create'Motor6D'{Name='RightGun'},
					Create'Motor6D'{Name='LeftGun'},
				},
				Create'Part'{
					Name = 'Torso',
					FormFactor = 'Custom',
					Size = Vector3.new(1.6, 1.3, 1.6),
					BrickColor = BrickColor.new(1002),
					Create'SpecialMesh'{},
					Create'Motor6D'{
						Name = 'Neck',
					},
					Create'Motor6D'{
						Name = 'Hip',
					},
					Create'Sound'{
						Name = 'FireSnowball',
						SoundId = 'rbxasset://sounds//paintball.wav',
					},
				},
				Create'Part'{
					Name = 'RightGun',
					FormFactor = 'Custom',
					Size = Vector3.new(0.4, 0.6, 1.5),
					BrickColor = BrickColor.new(1003), --`Really black`
				},
				Create'Part'{
					Name = 'LeftGun',
					FormFactor = 'Custom',
					Size = Vector3.new(0.4, 0.6, 1.5),
					BrickColor = BrickColor.new(1003), --`Really black`
				},
				Create'ObjectValue'{
					Name = 'SnowmanOwner',
					Value = Tool.Player,
				}
			}
			snowMan.Torso.Neck.Part0 = snowMan.Torso
			snowMan.Torso.Neck.Part1 = snowMan.Head
			snowMan.Torso.Neck.C0 = CFrame.new(0, 2.2, 0)
			snowMan.Torso.Hip.Part0 = snowMan.Torso
			snowMan.Torso.Hip.Part1 = snowMan.Mid
			snowMan.Torso.Hip.C0 = CFrame.new(0, 1.2, 0)
			--
			snowMan.Mid.RightGun.Part0 = snowMan.Mid
			snowMan.Mid.RightGun.Part1 = snowMan.RightGun
			snowMan.Mid.RightGun.C0 = CFrame.new(0.8, 0, 0)
			snowMan.Mid.LeftGun.Part0 = snowMan.Mid
			snowMan.Mid.LeftGun.Part1 = snowMan.LeftGun
			snowMan.Mid.LeftGun.C0 = CFrame.new(-0.8, 0, 0)
		
			--now that the thing is aset up for a humanoid, make it
			Create'Humanoid'{Parent = snowMan,}

			--put it where it need to be and register to to the player
			snowMan.Parent = game.Workspace
			snowMan.Torso.Anchored = true
			snowMan.Torso.CFrame = CFrame.new(pos + Vector3.new(0, 0.7, 0))
			Create'ObjectValue'{
				Parent = SnowmanListModel,
				Value = snowMan,
			}

			--finally, activate the snowman with a script, also put a copy of the
			--bulletdamage script into it that it can use to put into bullets
			local sc = Tool.Tool.SnowmanScript:Clone()
			sc.Parent = snowMan
			sc.Disabled = false
			local dmg = Tool.Tool.BulletDamage:Clone()
			dmg.Parent = snowMan

			--fade out the effect
			creationGlow.Parent = nil
			for i = 0, 1, 0.1 do
				creationLasso:setTransparency(i)
				wait()
			end

			--clean up
			Tool.Bin:clean('destroy_creation_effects')
		end
	end
end
function CreateMode.onSelect()
	Gui.Parent = Tool.Player.PlayerGui
	CreationProgressGui.Visible = true
	UnsetCreationProgressLabel()
end
function CreateMode.onDeselect()
	CreationProgressGui.Visible = false
	Gui.Parent = nil
end


-------------------------------------------
-----------  set target mode    -----------
TargetMode = {}
local ToolSelected = false
function TargetMode.onPress()
	local t = Tool.Mouse.Target
	local hum = (t.Parent or game):FindFirstChild('Humanoid')
	if hum then
		--clicked a humanoid, target it and show the target gui
		TargetValue.Value = hum

		--find a part in the humanoid to attach the gui to
		local partToAttachTo = (hum.Parent or game):FindFirstChild('Torso')
		if not partToAttachTo and hum.Parent then
			local largestPart = nil
			for _, p in pairs(hum.Parent:GetChildren()) do
				if p:IsA('BasePart') then
					if not largestPart or p.Size.magnitude > largestPart.Size.magnitude then
						largestPart = p
					end
				end
			end
			partToAttachTo = largestPart
		end
		if partToAttachTo then
			TargetGui.TrackerImage.Visible = true
			TargetGui.Adornee = partToAttachTo
		else
			TargetGui.TrackerImage.Visible = false
		end
	end
end
function TargetMode.onSelect()
	ToolSelected = true
	Gui.Parent = Tool.Player.PlayerGui
	--
	TargetGui.TrackerImage.Visible = true
	TargetGui.Parent = Tool.Player.PlayerGui
	--
	while ToolSelected do
		local t = Tool.Mouse.Target
		if t then
			local hum = (t.Parent or game):FindFirstChild('Humanoid')
			hum = hum or ((t.Parent or game).Parent or game):FindFirstChild('Humanoid')
			if hum then
				Tool.Mouse.Icon = 'http://www.roblox.com/asset/?id=66740738'
			else
				Tool.Mouse.Icon = 'http://www.roblox.com/asset/?id=66740715'
			end
		else
			Tool.Mouse.Icon = 'http://www.roblox.com/asset/?id=66740715'
		end
		wait()
	end
end
function TargetMode.onDeselect()
	TargetGui.TrackerImage.Visible = false
	TargetGui.Parent = nil
	--
	ToolSelected = false
	Tool.Mouse.Icon = ''
	Gui.Parent = nil
end
