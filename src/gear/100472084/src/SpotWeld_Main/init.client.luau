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

local EmitterPart = nil

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
			if EmitterPart then
				EmitterPart:Destroy()
				EmitterPart=nil
			end
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
























local BeamColor = BrickColor.new(Color3.new(255, 0, 0))
local PartModel = Create'Model'{
	Name = 'SpotWeld_Parts',
}
local Failsafe = nil

Tool.AnimationProvider:registerAnimation('equip', 'http://www.roblox.com/asset/?id=69427262')
Tool.AnimationProvider:registerAnimation('fire', 'http://www.roblox.com/asset/?id=69427271')
Tool.AnimationProvider:registerAnimation('hold', 'http://www.roblox.com/asset/?id=69427277')

class'RaycastIgnore'(nil, function(def)
	local mIgnoreMap = setmetatable({}, {__mode='k'})
	function def:addIgnore(obj)
		mIgnoreMap[obj] = true
	end
	function def:genIgnoreList()
		local ignoreList = {}
		for p, _ in pairs(mIgnoreMap) do
			ignoreList[#ignoreList+1] = p
			for _,t in pairs(p:GetChildren()) do
				if t.Name == 'Effect' then
					ignoreList[#ignoreList+1] = t
				end
			end
		end
		for _, ch in pairs(Tool.Character:GetChildren()) do
			if ch:IsA('BasePart') then
				ignoreList[#ignoreList+1] = ch
			end
			for _, handle in pairs(ch:GetChildren()) do
				if handle:IsA('BasePart') then
					ignoreList[#ignoreList+1] = ch
				end
			end
		end
		return ignoreList
	end
end)

class'SpotWeld_Charge'(function(this)
	this.Completed = CreateSignal()
	--
	local mReady = false
	local mSpokeList = {} --[i] = {Direction, Part, Len, Dist}
	local mChargeSphere = nil
	local mFracComplete = 0
	--
	local mLocation;
	--
	local mCurrentRun = 0
	--
	local function genSpokes()
		if mReady then return end
		mReady = true

		--make charge sphere
		mChargeSphere = Create'Part'{
			Name = 'SpotWeld_ChrageSphere',
			FormFactor = 'Custom',
			Anchored = true,
			CanCollide = false,
			Transparency = 0.3,
			BrickColor = BeamColor,
			Create'SpecialMesh'{MeshType='Sphere',},
		}
		RaycastIgnore:addIgnore(mChargeSphere)

		--make new spokes
		for i = 1, 20 do
			local spoke = {}
			spoke.Part = Create'Part'{
				Name = 'SpotWeld_Spoke',
				FormFactor = 'Custom',
				Anchored = true,
				CanCollide = false,
				Transparency = 0.3,
				BrickColor = BeamColor,
			}
			RaycastIgnore:addIgnore(spoke.Part)
			mSpokeList[i] = spoke
		end
	end
	local function randomizeSpokes()
		for _, spoke in pairs(mSpokeList) do
			spoke.Direction = CFrame.new(mLocation)*CFrame.Angles(math.random(-1.14, 1.14), 
			                                                      math.random(-1.14, 1.14),
			                                                      math.random(-1.14, 1.14))
			spoke.Len = math.random()*1+1
			spoke.Dist = math.random()*1+1
			spoke.Part.Size = Vector3.new(0.1, 0.1, spoke.Len)
		end
	end
	local function showSpokes(state)
		if mReady then
			local par = ((state) and PartModel or nil)
			mChargeSphere.Parent = par
			for _, spoke in pairs(mSpokeList) do
				spoke.Part.Parent = par
			end
		end
	end
	local function setSpokes()
		local sphereSz = mFracComplete
		mChargeSphere.Size = Vector3.new(sphereSz, sphereSz, sphereSz)
		mChargeSphere.CFrame = CFrame.new(mLocation)
		--
		for _, spoke in pairs(mSpokeList) do
			local endDistOut = (1-mFracComplete)*spoke.Dist
			local innerDistOut = endDistOut-spoke.Len-sphereSz
			local gotLen;
			if innerDistOut < 0 then
				gotLen = spoke.Len+innerDistOut
			else
				gotLen = spoke.Len
			end
			spoke.Part.Size = Vector3.new(0.1, 0.1, spoke.Len+innerDistOut)
			spoke.Part.CFrame = spoke.Direction*CFrame.new(0, 0, -(endDistOut-gotLen/2))
		end
	end
	--
	function this:run(location)
		mLocation = location
		mCurrentRun = mCurrentRun+1
		local thisRun = mCurrentRun
		mFracComplete = 0
		--
		genSpokes()
		randomizeSpokes()
		showSpokes(true)
		--
		Spawn(function()
			local lastTime = tick()
			while mCurrentRun == thisRun and mFracComplete < 1 do
				local now = tick()
				local dt = now-lastTime
				lastTime = now
				--
				mFracComplete = math.min(1, mFracComplete+dt*2)
				setSpokes()
				--
				wait()
			end
			if mCurrentRun == thisRun then
				showSpokes(false)
				this.Completed:fire()
			end
		end)
	end
	function this:stop()
		showSpokes(false)
		mCurrentRun = mCurrentRun+1
	end
	--
	function this:destroy()
		mReady = false
		mChargeSphere:Destroy()
		for i, spoke in pairs(mSpokeList) do
			mSpokeList[i] = nil
			spoke.Part:Destroy()
		end
	end
end)



--[[
locations:

    C
   /\
  /  \
  A  B 
  locationGetFunc => A, B, C
]]
local function frand(a, b)
	return a+math.random()*(b-a)
end
class'WavyBeam'(function(this, numSegs)
	local mSegList = {}
	for i = 1, numSegs do
		mSegList[i] = Create'Part'{
			Name = 'SpotWeld_BeamBit',
			Anchored = true,
			CanCollide = false,
			FormFactor = 'Custom',	
			BrickColor = BeamColor,
			Transparency = 0.3,
		}
		RaycastIgnore:addIgnore(mSegList[i])
	end
	function this:show(from, to)
		local totalLen = (from-to).magnitude
		local wave = math.min(totalLen/5, 1)/2
		local dirCF = CFrame.new(from, to)
		local lastPos = dirCF.p --(dirCF*CFrame.new(frand(-wave, wave), frand(-wave, wave), 0)).p
		for i = 1, numSegs do
			local p = mSegList[i]
			p.Parent = PartModel
			local distToThisEnd = i*(totalLen/numSegs)
			local newPos;
			if i == numSegs then
				newPos = (dirCF*CFrame.new(0,0,-distToThisEnd)).p
			else
				newPos = (dirCF*CFrame.new(frand(-wave, wave), 
				                           frand(-wave, wave), 
				                           -distToThisEnd)).p
			end
			p.Size = Vector3.new(0.1, 0.1, totalLen/numSegs)
			p.CFrame = CFrame.new(lastPos, newPos)*CFrame.new(0, 0, -(lastPos-newPos).magnitude/2)
			lastPos = newPos
		end
	end
	function this:hide()
		for i = 1, numSegs do
			mSegList[i].Parent = nil
		end
	end
end)
class'SpotWeld_Beam'(function(this)

	
	local mParticleEmitter = Create'Part'{
		Name = 'SpotWeld_ParticleEmitter',
		Anchored = true,
		CanCollide = false,
		Transparency = 1,
		Create'Sound'{
			Name = 'HoldSound1',
			Looped = true,
			SoundId = 'http://www.roblox.com/asset/?id=100429993',
			Volume=1
		},
		Create'Sound'{
			Name = 'HoldSound2',
			Looped = true,
			SoundId = 'http://www.roblox.com/asset/?id=100429993',
			Volume=1
		},
	}
	RaycastIgnore:addIgnore(mParticleEmitter)
	local mBeam_AC = CreateWavyBeam(2)
	local mBeam_BC = CreateWavyBeam(2)
	--
	local mIsShown = false
	function this:show(a, b, c, showBeam)
		if not a then
			this:hide()
			return
		end

		--
		mBeam_AC:show(a, c)
		mBeam_BC:show(b, c)
		--

		--
		if showBeam then
			--
			mParticleEmitter.Parent = PartModel
			mParticleEmitter.CFrame = CFrame.new(c)
			--
			if not mIsShown then
				mParticleEmitter.HoldSound1:Play()
				Delay(0.5, function() mParticleEmitter.HoldSound2:Play() end)
			end
			mIsShown = true
		else
			if EmitterPart then 
				EmitterPart:Destroy()
				EmitterPart=nil
			end
			mParticleEmitter.Parent = nil
			mIsShown = false
		end
		--
	end
	function this:hide()
		mIsShown = false
		--
		mBeam_AC:hide()
		mBeam_BC:hide()
		--
		mParticleEmitter.Parent = nil
	end
end)

--effects
local ChargeEffect = CreateSpotWeld_Charge()
local BeamEffect = CreateSpotWeld_Beam()

--helper to show the beam
function showBeamEffect(target, showBeam)
	local ch = Tool.Character
	local head = ch:FindFirstChild("Head")
	if not (head) then
		BeamEffect:hide()
	end
	--
	local ray = CFrame.new(head.Position, target)*CFrame.new(0, 2, -1)
	local a = (head.CFrame*CFrame.new(-.25, 0, 0)).p
	local b = (head.CFrame*CFrame.new(.25, 0, 0)).p
	local c = target
	--
	--local b = (head.CFrame*CFrame.new(-0.3, 0.15, -0.6)).p
	BeamEffect:show(a, b, c, showBeam)
end


function findFaceFromCoord(size, loc)
	local pa, pb = -size/2, size/2
	local dx = math.min(math.abs(loc.x-pa.x), math.abs(loc.x-pb.x))
	local dy = math.min(math.abs(loc.y-pa.y), math.abs(loc.y-pb.y))
	local dz = math.min(math.abs(loc.z-pa.z), math.abs(loc.z-pb.z))
	--
	if dx < dy and dx < dz then
		if math.abs(loc.x-pa.x) < math.abs(loc.x-pb.x) then
			return Enum.NormalId.Left --'Left'
		else
			return Enum.NormalId.Right --'Right'
		end
	elseif dy < dx and dy < dz then
		if math.abs(loc.y-pa.y) < math.abs(loc.y-pb.y) then
			return Enum.NormalId.Bottom --'Bottom'
		else
			return Enum.NormalId.Top --'Top'
		end
	elseif dz < dx and dz < dy then
		if math.abs(loc.z-pa.z) < math.abs(loc.z-pb.z) then
			return Enum.NormalId.Front --'Front'
		else
			return Enum.NormalId.Back --'Back'
		end	
	end 
end



function createFire(part, hit)
	if (part.Parent or game):FindFirstChild("Humanoid") or
	   ((part.Parent or game).Parent or game):FindFirstChild("Humanoid") then
	   return
	end
	if not EmitterPart then
		EmitterPart = Create'Part'{
			Name = 'EmitPart',
			FormFactor = 'Custom',
			CanCollide = false,
			Anchored = true,
			Size = Vector3.new(.2, .2, .2),
			Transparency = 1,
			Parent = script.Parent,
		}
		RaycastIgnore:addIgnore(EmitterPart)
		local emitScript = script:FindFirstChild('Emitter'):Clone()
		emitScript.Parent=EmitterPart
		emitScript.Disabled = false
	end
	
	
	local hitFace = findFaceFromCoord(part.Size, part.CFrame:toObjectSpace(CFrame.new(hit)))
	local dir = (part.CFrame-part.Position)*Vector3.FromNormalId(hitFace)
	if part:IsA('Terrain') then
		EmitterPart.CFrame = CFrame.new(hit)
	else
		EmitterPart.CFrame = CFrame.new(hit, hit+dir)*CFrame.Angles(-math.pi/2, 0, 0)
	end
	game.Debris:AddItem(scorch, 5)
end


local mClickNum = 0
local mSelected = false
Tool.MouseClick:connect(function()
	mClickNum = mClickNum+1
	local thisClick = mClickNum
	if not Tool.Mouse.Target or not Tool.Character:FindFirstChild("Head") then
		return
	end
	--
	Tool.AnimationProvider:getAnimation('fire'):Play(0, 1, 4)
	Spawn(function()
		repeat until Tool.AnimationProvider:getAnimation('fire').KeyframeReached:wait() == 'complete'
		Tool.AnimationProvider:getAnimation('hold'):Play(0, 1, 1)
	end)
	--
	Tool.Humanoid.WalkSpeed = 0
	--
	local headPos = Tool.Character.Head.Position
	local hit = Tool.Mouse.Hit.p
	ChargeEffect:run((CFrame.new(headPos, hit)*CFrame.new(0, 2, -3)).p)
	ChargeEffect.Completed:wait()
	ChargeEffect:stop()
	--
	local isDamageTick = false
	local timeOfLastScorch = tick()
	local partsToIgnore = RaycastIgnore:genIgnoreList()
	local headPart = Tool.Character:FindFirstChild("Head")
	while mSelected and Tool.MouseDown and mClickNum == thisClick and headPart do
		--first, find the true mouse hit, ignoring my ray parts
		local mouseRay = Tool.Mouse.UnitRay
		local newRay = Ray.new(mouseRay.Origin, mouseRay.Direction.unit*999.9)
		local _, hit = game.Workspace:FindPartOnRayWithIgnoreList(newRay, partsToIgnore)

		--found true hit, now go on to raycast to there from firefrom point
		local headPos = Tool.Character.Head.Position
		local fireFrom = (CFrame.new(headPos, hit)*CFrame.new(0, 2, -1)).p
		local castRay = Ray.new(fireFrom, (hit-fireFrom).unit*999.9)
		local part, target = game.Workspace:FindPartOnRayWithIgnoreList(castRay, partsToIgnore)

		local charHeading = Tool.Character.Torso.CFrame.lookVector
		local outOfFOV = (math.acos((target-fireFrom).unit:Dot(charHeading)) > 1.5)
		if not target or outOfFOV then
			--just shoot arbitrarily ahead
			showBeamEffect((Tool.Character.Head.CFrame*CFrame.new(0, 0, -10)).p, false)

		elseif (target-fireFrom).magnitude > 50 then
			--too far away
			target = fireFrom+(target-fireFrom).unit*50
			showBeamEffect(target, false)

		else
			--mechanism to do more damage every other tick
			isDamageTick = not isDamageTick
			if isDamageTick then
				--see if the target exists and is a humanoid
				local hum = (part.Parent or game):FindFirstChild("Humanoid")
				hum = hum or ((part.Parent or game).Parent or game):FindFirstChild("Humanoid")
				if hum then
					--found a humanoid, do damage
					TagHumanoid(hum)
					hum:TakeDamage(4)
				end
			end

			--make scorch effects
			if (tick()-timeOfLastScorch) > 0.1 then
				timeOfLastScorch = tick()
				createFire(part, target)
			end

			--show the beam
			showBeamEffect(target, true)
		end
		wait()
	end
	if mClickNum == thisClick then
		BeamEffect:hide()
		Tool.Humanoid.WalkSpeed = 16
		Tool.AnimationProvider:getAnimation('hold'):Stop()
	end
end)

local mHatPart = nil
Tool.Equipped:connect(function()
	mSelected = true
	PartModel.Parent = game.Workspace
	Failsafe = Tool.Tool.Failsafe:Clone()
	Failsafe.Disabled = false
	Failsafe.Model.Value = PartModel
	Failsafe.Humanoid.Value = Tool.Humanoid
	Failsafe.Parent = PartModel
	--
	Tool.AnimationProvider:getAnimation('equip'):Play(0.1, 1, 4)
	--Tool.Tool.Grip = CFrame.new()
	Tool.Tool.Handle.Transparency = 1
	--
	Spawn(function()
		--this code causes re-firing of the equipped event fpor some reason?
		--putting it in a new thread fixes this behavior
		mHatPart = Tool.Tool.Handle:Clone()
		mHatPart.Transparency = 0
		mHatPart.Parent = Tool.Character
		local w = Create'Weld'{
			Parent = mHatPart,
			Part0 = mHatPart,
			Part1 = Tool.Character:FindFirstChild('Head'),
			C0 = CFrame.new(0.040000014, 0, 0.0199999996, 1, 0, 0, 0, 1.31134158e-007, 1, 0, -1, 1.31134158e-007),
			C1 = CFrame.new(0, 0.200000003, -0.100000001, 1, 0, 0, 0, -4.37113883e-008, 1, 0, -1, -4.37113883e-008)
		}
	end)
end)

Tool.Unequipped:connect(function()
	mSelected = false
	PartModel.Parent = nil
	Failsafe:Destroy()
	Failsafe = nil

	if EmitterPart then
			EmitterPart:Destroy()
			EmitterPart=nil
	end
	--
	Tool.AnimationProvider:getAnimation('equip'):Stop()
	Tool.AnimationProvider:getAnimation('fire'):Stop()
	Tool.AnimationProvider:getAnimation('hold'):Stop()
	--kill any running effects
	ChargeEffect:stop()
	BeamEffect:hide()
	--
	Tool.Humanoid.WalkSpeed = 16
	--Tool.Handle.Transparency = 0
	--
	if mHatPart then
		mHatPart:Destroy()
		mHatPart = nil
	end
end)
