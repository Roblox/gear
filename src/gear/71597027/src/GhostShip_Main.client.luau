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









































Tool.AnimationProvider:registerAnimation('summon', 'http://www.roblox.com/asset/?id=71446087')


function CreateShipModel()
local sorcusMagicNumber = 4
return Create'Model'{
	Name = 'ShipModel',
	--main bit
	Create'Part'{
		Name = 'ShipPart_Base',
		FormFactor = 'Custom',
		Size = Vector3.new(1.3, 1.1, 3.2) * sorcusMagicNumber,
		CFrame = CFrame.new(CFrame.new() * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)),
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71385999',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5,1.5,1.5) * sorcusMagicNumber,
		},
	},
	Create'Part'{
		Name = 'ShipPart_Mast1',
		FormFactor = 'Custom',
		Size = Vector3.new(0.2,2.5,0.2) * 2,
		CFrame = CFrame.new(CFrame.new(0,1.4,-0.15) * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)) ,
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71386100',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5,1.5,1.5) * sorcusMagicNumber,
		},
	},
	Create'Part'{
		Name = 'ShipPart_MainSailLower',
		FormFactor = 'Custom',
		Size = Vector3.new(2.3,1.3,0.2) * sorcusMagicNumber,
		CFrame = CFrame.new(CFrame.new(0, 1.0, -0.3) * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)),
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71385951',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5,1.5,1.5) * sorcusMagicNumber,
		},
	},
	Create'Part'{
		Name = 'ShipPart_MainSailUpper',
		FormFactor = 'Custom',
		Size = Vector3.new(1.6,0.7,0.2) * sorcusMagicNumber,
		CFrame = CFrame.new(CFrame.new(0,2.0,-0.3) * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)),
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71386078',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5,1.5,1.5) * sorcusMagicNumber,
		},
	},
	Create'Part'{
		Name = 'ShipPart_Mast2',
		FormFactor = 'Custom',
		Size = Vector3.new(0.2,1.9,0.2) * sorcusMagicNumber,
		CFrame = CFrame.new(CFrame.new(0,1.4,-1.03) * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)),
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71386049',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5,1.5,1.5) * sorcusMagicNumber,
		},
	},
	Create'Part'{
		Name = 'ShipPart_SailLower',
		FormFactor = 'Custom',
		Size = Vector3.new(1.8,1.1,0.2) * sorcusMagicNumber,
		CFrame = CFrame.new(CFrame.new(0,1,-1.17) * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)),
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71386061',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5,1.5,1.5) * sorcusMagicNumber,
		},
	},
	Create'Part'{
		Name = 'ShipPart_SailUpper',
		FormFactor = 'Custom',
		Size = Vector3.new(1.6,0.7,0.2) * sorcusMagicNumber,
		CFrame = CFrame.new(CFrame.new(0,1.84,-1.17) * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)),
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71386078',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5,1.3,1.5) * sorcusMagicNumber,
		},
	},
	Create'Part'{
		Name = 'ShipPart_Base',
		FormFactor = 'Custom',
		Size = Vector3.new(0.3, 0.3, 1.2) * sorcusMagicNumber,
		CFrame = CFrame.new(CFrame.new(0,0.35,-2.3) * Vector3.new(sorcusMagicNumber, sorcusMagicNumber, sorcusMagicNumber)),
		Create'SpecialMesh'{
			MeshId =    'http://www.roblox.com/asset/?id=71386018',
			TextureId = 'http://www.roblox.com/asset/?id=71386126',
			Scale = Vector3.new(1.5, 1.5, 1.5) * sorcusMagicNumber,
		},
	},
}
end


function GetPartsRecursive(obj, tb)
	tb = tb or {}
	if obj:IsA('BasePart') then
		tb[#tb+1] = obj
	end
	for _, ch in pairs(obj:GetChildren()) do
		GetPartsRecursive(ch, tb)
	end
	return tb
end


local RechargeGui = Create'ScreenGui'{
	Name = 'GhostShipGui',
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


local function InflictDamage(hum, damage)
	local damager = script.Parent.DamageScript:Clone()
	Create'ObjectValue'{
		Name = 'Owner',
		Parent = damager,
		Value = Tool.Player,
	}
	Create'IntValue'{
		Name = 'Damage',
		Parent = damager,
		Value = damage,
	}
	damager.Parent = hum.Parent
	damager.Disabled = false
end

local Equipped = false

local LastFire = 0
local Firing = false
local Ship;
Tool.MouseClick:connect(function()
	--do some preliminary checks to bail out on
	if not Tool.Mouse.Target or Firing then return end
	if (Tool.HeadPart.Position - Tool.Mouse.Hit.p).magnitude > 100 then return end
	if (tick() - LastFire) < 2 then return end

	Firing = true
	LastFire = tick()

	--all good, create the ship
	local ship = CreateShipModel()
	Ship = ship

	--make a failsafe to clean up the ship
	Tool.Bin:add(function()
		ship:Destroy()
	end)

	local baseAnimCF = CFrame.new((Tool.HeadPart.CFrame*CFrame.new(0, 4, 0)).p, Tool.Mouse.Hit.p)
	local hitPos = Tool.Mouse.Hit.p

	local partData = {}
	local partSet = {}

	--add the character's parts to the 
	for _, p in pairs(GetPartsRecursive(Tool.Character)) do
		partSet[p] = true
	end

	local numColliding = 0
	local hitHumanoid = nil
	--create data for parts and edit their stats
	for _, p in pairs(ship:GetChildren()) do
		if p:IsA('BasePart') then
			partSet[p] = true
			--anchor / cancollide off all the stuff
			p.Anchored = true
			p.CanCollide = falsew
			p.Mesh.VertexColor = Vector3.new(0.2,1,0.2)

			--add data for it
			local pDat = {}
			pDat.Part = p
			pDat.RelCF = p.CFrame
			pDat.BaseAnimCF = baseAnimCF*p.CFrame
			pDat.AnimAngleModX = math.random(-8,8)/10
			pDat.AnimAngleModY = math.random(-8,8)/10
			pDat.Dist = math.random(5, 20)

			p.Touched:connect(function(otherP)
				p.CanCollide = true 
				if not partSet[otherP] then
					numColliding = numColliding + 1
				end
				if (otherP.Parent or game):FindFirstChild('Humanoid') and 
					otherP.Parent.Humanoid ~= Tool.Humanoid then
					print("Hit Humanoid")
					hitHumanoid = otherP.Parent.Humanoid

					--also do some damage to players hit with shrapnel
					InflictDamage(hitHumanoid, 13)
				end
			end)
			p.TouchEnded:connect(function(otherP)
				if not partSet[otherP] then
					numColliding = numColliding - 1
				end
			end)

			partData[#partData+1] = pDat
		end
	end

	ship.Parent = Tool.Character

	Tool.AnimationProvider:getAnimation('summon'):Play(0.1, 1, 4)

	--now, do animation
	for i = 0, 1, 0.1 do
		local baseKeyframeOffset = Vector3.new(0, (1-math.sqrt(i)), 0)
		--
		for _, pDat in pairs(partData) do
			pDat.Part.Transparency = (1-0.6*i)
			local angleMod = CFrame.Angles(pDat.AnimAngleModX*(1-i), pDat.AnimAngleModY*(1-i), 0)
			pDat.Part.CFrame = pDat.BaseAnimCF - (angleMod*baseKeyframeOffset)*pDat.Dist
		end
		--
		wait()
		if not Equipped then return end
	end
	for _, pDat in pairs(partData) do
		--also fix up the rotations after animating
		pDat.Part.CFrame = pDat.BaseAnimCF
	end

	--see if we're all clear to fire
	if numColliding > 0 then
		ship:Destroy()
		LastFire = 0
		Firing = false
		return
	end

	--weld the parts to the ship's main part
	for _, ch in pairs(ship:GetChildren()) do
		if ch:IsA('BasePart') and ch ~= ship.ShipPart_Base then
			local w = Create'Weld'{
				Part0 = ship.ShipPart_Base,
				Part1 = ch,
				C0 = ship.ShipPart_Base.CFrame:inverse()*ch.CFrame,
				C1 = CFrame.new(),
			}
			w.Parent = ship.ShipPart_Base
			ch.Anchored = false
		end
	end

	--unanchor the body to prepare for throw
	ship.ShipPart_Base.Anchored = false
	Create'BodyPosition'{
		Name = 'Mover',
		Parent = ship.ShipPart_Base,
		maxForce = Vector3.new(100000, 100000, 100000),
		position = ship.ShipPart_Base.Position,
	}

	--now, throw the ship at them
	local throwDist = ((Tool.HeadPart.CFrame*CFrame.new(0, 4, 0)).p - hitPos).magnitude + 1
	for i = 0, 1, 1/(30*throwDist/60) do --60 = velocity in studs / second
		if hitHumanoid then
			--shut.. down.. everything!! We hit a humanoid, so stop here
			break
		end
		ship.ShipPart_Base.Mover.position = (baseAnimCF*CFrame.new(0, 0, -throwDist*i*i)).p
		wait()
		if not Equipped then return end
	end
	ship.ShipPart_Base.Mover.position = (baseAnimCF*CFrame.new(0, 0, -throwDist)).p
	wait()
	if not Equipped then return end

	--do the initial damage to the hit humanoid
	if hitHumanoid then
		InflictDamage(hitHumanoid, 100)
	end

	--shatter the ship
	--breakjoints it and then give the pieces some initial velocity
	--to get a nice parabolic motion away from the point of detonation
	ship:BreakJoints()
	for _, ch in pairs(ship:GetChildren()) do
		if ch:IsA('BasePart') and ch ~= ship.ShipPart_Base then
			ch.Velocity = ch.Velocity + Vector3.new(math.random(-15,15), math.random(40,65), math.random(-15, 15))
		end
	end

	--throw some smoke into the ship's base
	Create'Smoke'{
		Parent = ship.ShipPart_Base,
		Color = Color3.new(0,0.5,0),
		Size = 10,
	}
	ship.ShipPart_Base.Transparency = 1

	--now also stun the things near me
	local stunnedHumanoidMap = {}
	for _, p in pairs(game.Players:GetChildren()) do
		if p:IsA('Player') and p ~= Tool.Player and p.Character and p.Character:FindFirstChild('Torso') then
			local hum = p.Character.Humanoid
			local tor = p.Character.Torso
			if (tor.Position - ship.ShipPart_Base.Position).magnitude < 15 then
				local stun = script.Parent.StunnerScript:Clone()
				stun.Disabled = false
				stun.Parent = p.Character
				stunnedHumanoidMap[hum] = true
			end
		end
	end

	--show a stun area effect
	local stunAreaPart = Create'Part'{
		Name = 'StunAreaEffect',
		FormFactor = 'Custom',
		Parent = Tool.Character,
		BrickColor = BrickColor.new(1022),
		Shape = 'Ball',
		Anchored = true,
		CanCollide = false,
		Transparency = 0,
		Size = Vector3.new(0.1,0.1,0.1),
	}
	Spawn(function()
		stunAreaPart.CFrame = ship.ShipPart_Base.CFrame
		for i = 0, 1, 0.06 do
			local par = stunAreaPart.Parent
			stunAreaPart.Parent = nil
			--
			stunAreaPart.Transparency = i^1.5
			local sz = 15 * i^3
			stunAreaPart.Size = Vector3.new(sz, sz, sz)
			--
			stunAreaPart.Parent = par
			wait()
		end
		stunAreaPart:Destroy()
	end)
	Tool.Bin:add(function()
		stunAreaPart:Destroy()
	end)

	--now invisible-ify the parts gradually over 2 seconds before stopping the smoke anim
	--and removing the last remnants of the ship
	for i = 0, 1, (1/30)/2 do
		for _, pDat in pairs(partData) do
			if pDat.Part ~= ship.ShipPart_Base then
				pDat.Part.Transparency = i
			end
		end
		wait()
		if not Equipped then return end
	end

	--wait an extra couple seconds
	wait(2)
	if not Equipped then return end

	--finally, destroy the ship (Note: This kills the ship)
	ship:Destroy()
	Ship = nil
	Firing = false
	LastFire = tick()
end)


local function SetProgress(frac)
	RechargeGui.MainFrame.ProgressBar.Size = UDim2.new(frac, 0, 1, 0)
	if frac == 1 then
		RechargeGui.MainFrame.ProgressText.Text = "~ Ghost Ship Ready ~"
	else
		RechargeGui.MainFrame.ProgressText.Text = "Charging "..math.floor(frac*100).."%"
	end
end

Tool.Equipped:connect(function()
	RechargeGui.Parent = Tool.Player.PlayerGui
	Equipped = true
	while Equipped do
		if (Tool.HeadPart.Position - Tool.Mouse.Hit.p).magnitude > 150 then
			Tool.Mouse.Icon = 'http://www.roblox.com/asset/?id=71445795'
		else
			Tool.Mouse.Icon = 'http://www.roblox.com/asset/?id=71445802'
		end
		if Firing then
			SetProgress(0)
		else
			SetProgress(math.min(1, (tick()-LastFire)/2))
		end
		wait()
	end
end)


Tool.Unequipped:connect(function()
	Firing = false
	LastFire = tick()
	Equipped = false
	if Ship then
		Ship:Destroy()
		Ship = nil
	end
	RechargeGui.Parent = nil
end)

