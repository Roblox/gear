function CreateSignal()
	local this = {}
	local mListeners = {}
	local mListenerCount = 0
	local mWaitProxy = nil
	local mWaitReturns = nil
	local mHasWaiters = false
	function this:connect(func)
		if self ~= this then error("connect must be called with `:`, not `.`", 2) end
		if type(func) ~= 'function' then
			error("Argument #1 of connect must be a function, got a "..type(func), 2)
		end
		mListenerCount = mListenerCount + 1
		local conn = {}
		function conn:disconnect()
			if mListeners[conn] then
				mListeners[conn] = nil
				mListenerCount = mListenerCount - 1
			end
		end
		mListeners[conn] = func
		return conn
	end
	function this:disconnect()
		if self ~= this then error("disconnect must be called with `:`, not `.`", 2) end
		for k, v in pairs(mListeners) do
			mListeners[k] = nil
		end
		mListenerCount = 0
	end
	function this:wait()
		if self ~= this then error("wait must be called with `:`, not `.`", 2) end
		if not mWaitProxy then
			mWaitProxy = Instance.new('BoolValue')
		end
		mHasWaiters = true
		mWaitProxy.Changed:wait()
		return unpack(mWaitReturns)
	end
	function this:fire(...)
		if self ~= this then error("fire must be called with `:`, not `.`", 2) end
		local arguments;
		if mListenerCount > 0 or mHasWaiters then
			arguments = {...}
		end
		if mHasWaiters then
			mHasWaiters = false
			mWaitReturns = arguments
			mWaitProxy.Value = not mWaitProxy.Value
			mWaitReturns = nil
		end
		if mListenerCount > 0 then
			for _, handlerFunc in pairs(mListeners) do
				Spawn(function()
					handlerFunc(unpack(arguments))
				end)
			end
		end
	end
	function this:fireSync(...)
		if self ~= this then error("fire must be called with `:`, not `.`", 2) end
		local arguments;
		if mListenerCount > 0 or mHasWaiters then
			arguments = {...}
		end
		if mHasWaiters then
			mHasWaiters = false
			mWaitReturns = arguments
			mWaitProxy.Value = not mWaitProxy.Value
			mWaitReturns = nil
		end
		if mListenerCount > 0 then
			for _, handlerFunc in pairs(mListeners) do
				handlerFunc(unpack(arguments))
			end
		end		
	end
	return this
end
local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	return function(dat)
		dat = dat or {}
		local obj = Instance.new(objectType)
		local ctor = nil
		for k, v in pairs(dat) do
			if type(k) == 'string' then
				obj[k] = v
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
					       got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)
			elseif k == Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
					       got: "..tostring(v), 2)
				elseif ctor then
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v
			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end
		if ctor then
			ctor(obj)
		end
		return obj
	end
end
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})
Create.E = function(eventName)
	return {__eventname = eventName}
end
function class(classname)
	local classDef = {}
	local mPublicMethods = {}
	local mAllMethods = {}
	local mGetters = {__ClassName = true}
	local mSetters = {}
	local mEvents = {}
	local function fmtKey(key)
		if type(key) == 'string' then
			return '.'..key
		else
			return '['..tostring(key)..']'
		end
	end
	return function(implementer)
		if type(implementer) ~= 'function' then
			error("Only functions ay be used as a class body definition, got a "..type(implementer), 2)
		end
		local setProxy = setmetatable({}, {
			__index = function(tb, key)
				return setmetatable({}, {
					__call = function(tb, ...)
						if #{...} > 0 then
							error('Passing arguments to classdef.set'..fmtKey(key)..'() has no meaning, \
							       see documentation for correct usage.', 2)
						end
						if mSetters[key] then
							error('Redefinition of setter for '..tostring(key), 2)
						end
						mSetters[key] = true
					end;
				})
			end;
			__newindex = function(tb, key, val)
				if type(key) == 'string' and type(val) == 'function' then
					if mSetters[key] then
						error('Redefinition of setter for '..tostring(key), 2)
					end
					mSetters[key] = val
				else
					error('Can\'t set classdef.set'..fmtKey(key)..' = '..tostring(val), 2)
				end
			end;
		})
		local getProxy = setmetatable({}, {
			__index = function(tb, key)
				return setmetatable({}, {
					__call = function(tb, ...)
						if #{...} > 0 then
							error('Passing arguments to classdef.get'..fmtKey(key)..'() has no meaning, \
							       see documentation for correct usage.', 2)
						end
						if mGetters[key] then
							error('Redefinition of getter for '..tostring(key), 2)
						end
						mGetters[key] = true
					end;
				})
			end;
			__newindex = function(tb, key, val)
				if type(key) == 'string' and type(val) == 'function' then
					if mGetters[key] then
						error('Redefinition of getter for '..tostring(key), 2)
					end
					mGetters[key] = val
				else
					error('Can\'t set classdef.get'..fmtKey(key)..' = '..tostring(val), 2)
				end
			end;
		})
		local getsetProxy = setmetatable({}, {
			__index = function(tb, key)
				return setmetatable({}, {
					__call = function(tb, ...)
						if #{...} > 0 then
							error('Passing arguments to classdef.getset'..fmtKey(key)..'() has no meaning, \
							       see documentation for correct usage.', 2)
						end
						if mSetters[key] then
							error('Redefinition of setter for '..tostring(key), 2)
						end
						if mGetters[key] then
							error('Redefinition of getter for '..tostring(key), 2)
						end
						mSetters[key] = true
						mGetters[key] = true
					end;
				})
			end;
			__newindex = function(tb, key, val)
				error('Can\'t set classdef.set'..fmtKey(key)..' = '..tostring(val), 2)
			end;
		})
		local eventProxy = setmetatable({}, {
			__index = function(tb, key)
				return setmetatable({}, {
					__call = function(tb, ...)
						if #{...} > 0 then
							error("Passing arguments to clasdef.event"..fmtKey(key).."() has no meaning, \
							       see documentation for correct usage.", 2)
						end
						if type(key) ~= 'string' then
							error("Can't create event `"..tostring(key).."` event names must be strings", 2)
						end
						if mEvents[key] then
							error("Redefinition of event `"..key.."`", 2)
						end
						mEvents[key] = true
						mGetters[key] = true
					end;
					__index = function()
						error("classdef.event"..fmtKey(key).." can only be called, not indexed", 2)
					end;
					__newindex = function()
						error("classdef.event"..fmtKey(key).." can only be called, not assigned to", 2)
					end;
				})
			end;
			__newindex = function(tb, key, val)
				error("Can't set classdef.event"..fmtKey(key).." = "..tostring(val), 2)
			end;
		})
		local staticProxy = setmetatable({}, {
			__index = classDef,
			__newindex = classDef,
		})
		local privateProxy = setmetatable({}, {
			__newindex = function(tb, key, val)
				if type(key) == 'string' and type(val) == 'function' then
					mAllMethods[key] = val
				else
					error("Can't set classdef.private"..fmtKey(key).." = "..tostring(val), 2)
				end
			end;
			__index = function(tb, key)
				error("Can't get classdef.private"..fmtKey(key), 2)
			end;
		})
		local mainImplProxy = {}
		mainImplProxy.get = getProxy
		mainImplProxy.set = setProxy
		mainImplProxy.getset = getsetProxy
		mainImplProxy.event = eventProxy
		mainImplProxy.private = privateProxy
		mainImplProxy.static = staticProxy
		setmetatable(mainImplProxy, {
			__index = function(tb, key)
				error('Can\'t get classdef'..fmtKey(key), 2)
			end; 
			__newindex = function(tb, key, val)
				if type(key) == 'string' and type(val) == 'function' then
					mPublicMethods[key] = val
					mAllMethods[key] = val
					mGetters[key] = true
				else
					error('Can\'t set classdef'..fmtKey(key)..' = '..tostring(val), 2)
				end
			end;
		})
		implementer(mainImplProxy)
		for k, f in pairs(mAllMethods) do
			if k ~= 'Create' then
				mAllMethods[k] = function(self, ...)
					if type(self) ~= 'table' or self.__ClassName ~= classname then
						error("Methods must be called with a ':', not a '.'")
					end
					return f(rawget(self, '__internal'), ...)
				end
				if mPublicMethods[k] then
					mPublicMethods[k] = mAllMethods[k]
				end
			end
		end
		for k, f in pairs(mGetters) do
			if type(f) == 'function' then
				mGetters[k] = function(self, ...)
					return f(rawget(self, '__internal'), ...)
				end
			end
		end
		for k, f in pairs(mSetters) do
			if type(f) == 'function' then
				mSetters[k] = function(self, ...)
					return f(rawget(self, '__internal'), ...)
				end
			end
		end
		local internalMT = {
			__index = mAllMethods;
		}
		local rawget = rawget 
		local externalMT = {
			__index = function(obj, key)
				local method = mPublicMethods[key]
				if method then
					return method
				elseif mGetters[key] == true then
					return rawget(obj, '__internal')[key]
				elseif mGetters[key] then
					return mGetters[key](obj)
				else
					error("Can't get "..classname.."::"..key, 2)
				end
			end;
			__newindex = function(obj, key, val)
				if mSetters[key] == true then
					rawget(obj, '__internal')[key] = val
				elseif mSetters[key] then
					mSetters[key](obj, val)
				else
					error("Can't set "..classname.."::"..key, 2)
				end
			end;
		}
		local constructor = function(...)
			local internalThis = {__ClassName = classname}
			internalThis.__internal = internalThis
			setmetatable(internalThis, internalMT)
			local externalThis = {__internal = internalThis}
			setmetatable(externalThis, externalMT)
			for eventName, _ in pairs(mEvents) do
				internalThis[eventName] = CreateSignal()
			end
			if mAllMethods.Create then
				mAllMethods.Create(internalThis, ...)
			end
			return externalThis
		end
		classDef.Create = constructor
		getfenv(0)['Create'..classname] = constructor
		getfenv(0)[classname] = classDef
	end
end


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

--===============================================================================
-- A tree object for quick verification of the object hierarchy that a game or
-- gear may need to be present. The tree returns a "filter" function which can
-- be called on an instance to flatten it into a tag map, so that in the future
-- the objects in the hierarchy can safely be accessed through the tag map
-- without need for extra checks of existance. If the hierarchy is not valid
-- then nothing is returned from the call to the filter.
--
-- Below some common examples of how to construct a tree are given, and the
-- Gearlib includes the most common examples which veryify various parts of
-- the character depending on the needs of the gear.
--
--===============================================================================
function tree(name)
	if type(name) == 'string' then
		return function(dat)
			return function(instance, ctx)
				local child = instance:FindFirstChild(name)
				if not child then return false end 
				if dat.IsA and not child:IsA(dat.IsA) then return false end
				if dat.Tag then
					ctx[dat.Tag] = child
				end
				for i = 1, #dat do
					if not dat[i](child, ctx) then return false end
				end
				return true
			end
		end
	else
		return function(dat)
			return function(instance)
				local ctx = {}
				if dat.IsA and not instance:IsA(dat.IsA) then return nil end
				if dat.Tag then ctx[dat.Tag] = instance end
				for i = 1, #dat do
					if not dat[i](instance, ctx) then return nil end
				end
				return ctx
			end
		end
	end
end

--===============================================================================
-- A tree which verifys all parts of a character including legs.
-- Tags Declared:
--  Character: the root character model
--  LeftArm, RightArm, LeftLeg, RightLeg, Head: The appendages
--  Humanoid: The humanoid
--  
local CharacterFullTree = tree{
	IsA = 'Model';
	Tag = 'Character';
	--
	tree'Left Arm'{
		IsA = 'BasePart';
		Tag = 'LeftArm';
	};
	tree'Right Arm'{
		IsA = 'BasePart';
		Tag = 'RightArm';
	};
	tree'Left Arm'{
		IsA = 'BasePart';
		Tag = 'LeftArm';
	};
	tree'Right Arm'{
		IsA = 'BasePart';
		Tag = 'RightArm';
	};
	tree'Head'{
		IsA = 'BasePart';
		Tag = 'Head';
	};
	tree'Humanoid'{
		IsA = 'Humanoid';
		Tag = 'Humanoid';
	};
}

--===============================================================================
-- A tree with just the parts for a basic gear.
-- Tags Declared:
--  Character: The root character object
--  RightArm
--  Torso
--  Humanoid
local CharacterRightArmTree = tree{
	IsA = 'Model';
	Tag = 'Character';
	--
	tree'Right Arm'{
		IsA = 'BasePart';
		Tag = 'RightArm';
	};
	tree'Torso'{
		IsA = 'BasePart';
		Tag = 'Torso';
	};
	tree'Humanoid'{
		IsA = 'BasePart';
		Tag = 'Humanoid';
	};
}


--===============================================================================
-- A class for maintaining a list of assets that the gear uses. The assets can
-- be added as a list or one by one, and then requested as for various purposes,
-- such as as individual sounds or meshes, or more specifically such as for a set
-- of animations on a given humanoid.
class'AssetProvider'(function(def)
	function def:Create()
		self.Model = script.Parent:FindFirstChild('assets')
		if not self.Model then
			self.Model = Create'Model'{
				Name = "assets";
				Parent = script.Parent;
			}
		end
	end



	--functionality to register various types of asset
	function def:RegisterMesh(tag, id, scale)
		if not self.Model:FindFirstChild(tag) then
			local mesh = Create'SpecialMesh'{
				Name = tag;
				MeshId = self:ToAssetId(id);
				Parent = self.Model;
			}
			if scale then
				mesh.Scale = scale
			end
		end
	end

	function def:RegisterAnim(tag, id, speed, fadeTime)
		if not self.Model:FindFirstChild(tag) then
			local obj = Create'Animation'{
				Name = tag;
				AnimationId = self:ToAssetId(id);
			}
			if speed then
				local speedObj = Create'NumberValue'{
					Name = 'speed';
					Value = speed;
				}
				speedObj.Parent = obj
			end
			if fadeTime then
				local fadeTimeObj = Create'NumberValue'{
					Name = 'fadeTime';
					Value = fadeTime;
				}
				fadeTimeObj.Parent = obj
			end
			obj.Parent = self.Model;
		end
	end

	function def:RegisterSound(tag, id, volume, pitch)
		if not self.Model:FindFirstChild(tag) then
			local sound = Create'Sound'{
				Name = tag;
				SoundId = self:ToAssetId(id);
				Parent = self.Model;
			}
			if volume then
				sound.Volume = volume
			end
			if pitch then
				sound.Pitch = pitch
			end
		end
	end



	--functionality to create instances of various asset types
	function def:CreateSound(tag, volume, pitch)
		if self.Model:FindFirstChild(tag) then
			local obj = self.Model:FindFirstChild(tag):Clone()
			if volume then
				obj.Volume = volume
			end
			if pitch then
				obj.Pitch = pitch
			end
			return obj
		end
	end
	
	function def:PlaySound(tag)
		Spawn(function()
			local handle = script.Parent:WaitForChild('Handle')
			if not handle:FindFirstChild(tag) and self.Model:FindFirstChild(tag) then
				self.Model:FindFirstChild(tag):Clone().Parent = handle
			end
			if handle:FindFirstChild(tag) then
				handle:FindFirstChild(tag):Play()
			end
		end)
	end

	function def:CreateMesh(tag, scale)
		if self.Model:FindFirstChild(tag) then
			local obj = self.Model:FindFirstChild(tag):Clone()
			if scale then
				obj.Scale = scale
			end
			return obj
		end
	end

	function def:CreateAnimator(humanoid)
		local anims = {}
		local function HandleChild(anim)
			if anim:IsA('Animation') then
				local track = humanoid:LoadAnimation(anim)
				--
				local proxy = {}
				local defaultSpeed, defaultFade;
				if anim:FindFirstChild('speed') then
					defaultSpeed = anim:FindFirstChild('speed').Value
				end
				if anim:FindFirstChild('fadeTime') then
					defaultFade = anim:FindFirstChild('fadeTime').Value
				end
				function proxy:Play(speed, fadeTime)
					track:Play(fadeTime or defaultFade or 0.1, 1, speed or defaultSpeed or 1)
				end
				function proxy:AdjustSpeed(speedFrac)
					track:AdjustSpeed((speed or defaultSpeed or 1)*speedFrac)
				end
				function proxy:Stop(fadeTime)
					track:Stop(fadeTime or defaultFade or 0.1)
				end
				proxy.KeyframeReached = track.KeyframeReached
				--
				anims[anim.Name] = proxy
			end
		end
		for _, anim in pairs(self.Model:GetChildren()) do
			HandleChild(anim)
		end
		self.Model.ChildAdded:connect(HandleChild)
		--
		local animator = setmetatable({}, {__index=anims})
		function animator:StopAll(fadeTime)
			for _, anim in pairs(anims) do
				anim:Stop(fadeTime)
			end
		end
		return animator
	end

	function def.private:ToAssetId(id)
		local res;
		if type(id) == 'string' then
			res = id
		elseif type(id) == 'number' then
			res = 'http://www.roblox.com/asset/?id='..id
		end
		game:GetService('ContentProvider'):Preload(res)
		return res
	end
end)


function CreateMutexFunction(task)
	local running = false
	return function(...)
		if not running then
			return task(...)
		end
	end
end


function CreateGlobalVarList()
	local this = {}
	local waitingOn = {}
	--
	local data = script.Parent:FindFirstChild('data')
	if not data then
		if script:IsA('LocalScript') then
			data = Create'Model'{
				Name = 'data';
				Parent = script.Parent;
			}	
		else
			repeat wait() until script.Parent:FindFirstChild('data')
			data = script.Parent:FindFirstChild('data')			
		end
	end
	--
	function this:Create(tag, type, default)
		if not data:FindFirstChild(tag) then
			if script:IsA('LocalScript') then
				Create(type..'Value'){
					Name = tag;
					Parent = data;
					Value = default;
				}
			else
				waitingOn[tag] = true
				repeat wait() until data:FindFirstChild(tag)
				waitingOn[tag] = nil
			end
		end
	end
	--
	setmetatable(this, {
		__index = function(tb, inx)
			if inx == 'Create' then
				return this.Create
			else
				local val = data:FindFirstChild(inx)
				if val then
					return val.Value
				elseif waitingOn[inx] then
					repeat wait() until not waitingOn[inx]
					return data[inx].Value
				else
					error('Can\'t set global `'..inx..'`, does not exist.')
				end
			end
		end;
		__newindex = function(tb, inx, val)
			local obj = data:FindFirstChild(inx)
			if obj then
				obj.Value = val
			elseif waitingOn[inx] then
				repeat wait() until not waitingOn[inx]
				data:FindFirstChild(inx).Value = val
			else
				error('Can\'t get global `'..inx..'`, does not exist.')
			end
		end;
	})
	return this
end


class'Tool'(function(def)
	function def:Create()
		self.Tool = script.Parent
		local tool = script.Parent
		self.Handle = tool:FindFirstChild('Handle')
		if not self.Handle then
			if script:IsA('LocalScript') then
				repeat wait() until tool:FindFirstChild('Handle')
				self.Handle = tool.Handle
			else
				error("Tool has no `Handle`, did you forget to add one?")
			end
		end

		--see which side we're on, localscript or normal script:
		local IsLocal = script:IsA('LocalScript')

		--set up the damage bin in the tool, so that damage can be inflicted
		--from a localscript. The global script side has to create a "damagebin"
		--in the tool, and the local side of the tool then puts notifications
		--into that madel.
		if IsLocal then
			Spawn(function()
				while not tool:FindFirstChild('damagebin') do
					tool.ChildAdded:wait()
				end
				self.DamageBin = tool:FindFirstChild('damagebin')
			end)
		else
			self.DamageBin = tool:FindFirstChild('damagebin')
			if not self.DamageBin then
				self.DamageBin = Create'Model'{
					Name = 'damagebin';
					Parent = tool;
				}
			end
			--and listen on the damage bin
			self.DamageBin.ChildAdded:connect(function(ch)
				local dmg = tonumber(ch.Name)
				--tag the humanoid
				local creator = Create'ObjectValue'{
					Name = 'creator';
					Value = self.Player;
					Parent = ch.Value;
				}
				wait()
				ch.Value:TakeDamage(dmg)
				game.Debris:AddItem(ch, 2)
				game.Debris:AddItem(creator, 2)
			end)
		end

		--create the asset manager
		self.Asset = CreateAssetProvider()

		--create the global var list
		self.Var = CreateGlobalVarList()

		--
		tool.Equipped:connect(function(mouse)
			--main properties set on selection
			self.Mouse = mouse
			self.MouseDown = false
			self.Selected = true
			
			--set up convinience properties
			self.Character = tool.Parent
			self.Player = game.Players:GetPlayerFromCharacter(self.Character)
			self.Head = self.Character:FindFirstChild('Head')
			self.Torso = self.Character:FindFirstChild('Torso')
			self.Humanoid = self.Character:FindFirstChild('Humanoid')
			self.LeftLeg = self.Character:FindFirstChild('Left Leg')
			self.RightLeg = self.Character:FindFirstChild('Right Leg')
			self.LeftArm = self.Character:FindFirstChild('Left Arm')
			self.RightArm = self.Character:FindFirstChild('Right Arm')

			--create main the animator for this instance. It won't be usefull from the
			--global side right now, but it may be in the future, and it is an abstraction
			--so it is possible to make it work even from the global side.
			self.Animator = self.Asset:CreateAnimator(self.Humanoid)
			
			--if local, set up the mouse events
			if IsLocal then
				mouse.Button1Down:connect(function()
					self.MouseDown = true
					self.Button1Down:fire()
				end)	
				mouse.Button1Up:connect(function()
					self.MouseDown = false
					self.Button1Up:fire()
				end)
				mouse.KeyDown:connect(function(key)
					self.KeyDown:fire(key)
				end)
				mouse.KeyUp:connect(function(key)
					self.KeyUp:fire(key)
				end)
			end
			
			--finally, pass off to the user
			Spawn(function()
				self.Equipped:fire()
			end)
		end)
		tool.Unequipped:connect(function()
			-- FIRST give the tool a chance to do stuff with these properties
			-- before we kill them. That is, the unequipped event fires before
			-- the thing is really unequipped.
			self.Unequipped:fireSync()

			--unset convinience properties
			self.Selected = false
			self.MouseDown = false
			self.Mouse = nil
			self.Character = nil
			--
			self.Head = nil
			self.Torso = nil
			self.Humanoid = nil
			self.LeftArm = nil
			self.RightArm = nil
			self.LeftLeg = nil
			self.RightLeg = nil
			
			--kill the old animator. We may be able to reuse it some of the time
			--but the most common use cases are ones where it's not possible to save, so
			--it's not worth the extra code comlexity to figure out when we can save it.
			self.Animator = nil
		end)
	end

	function def:DamageHumanoid(humanoid, damage)
		if self.DamageBin then
			(Create'ObjectValue'{
				Name = tostring(damage);
				Value = humanoid;
			}).Parent = self.DamageBin
		else
			Spawn(function()
				repeat wait() until self.DamageBin
				Create'ObjectValue'{
					Name = tostring(damage);
					Value = humanoid;
				}.Parent = self.DamageBin
			end)
		end
	end

	--============================
	def.get.Tool()
	def.get.Player()
	def.get.Mouse()
	def.get.MouseDown()
	def.get.Selected()
	function def.get:MouseTarget()
		if self.Mouse then
			return self.Mouse.Target
		end
	end
	function def.get:MouseHit()
		if self.Mouse then
			return self.Mouse.Hit
		end
	end
	function def.get:MouseIcon()
		if self.Mouse then
			return self.Mouse.Icon
		end
	end
	function def.set:MouseIcon(icon)
		if not self.Mouse then
			error("Error, Can't set MouseIcon from a global script!")
		end
		self.Mouse.Icon = icon
	end
	--
	def.get.Character()
	def.get.Humanoid()
	def.get.LeftArm()
	def.get.RightArm()
	def.get.LeftLeg()
	def.get.RightLeg()
	def.get.Head()
	def.get.Torso()
	def.get.Handle()
	--
	def.get.Asset()
	def.get.Animator()
	def.get.Var()

	--=============================
	def.event.Equipped()
	def.event.Unequipped()
	--
	def.event.Button1Down()
	def.event.Button1Up()
	def.event.KeyDown()
	def.event.KeyUp()
end)

local Tool = CreateTool()

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------


--====================================================================================--
--                                 asset setup code
--====================================================================================--

--meshes
Tool.Asset:RegisterMesh('swordmesh',    127402519)
Tool.Asset:RegisterMesh('shieldmesh',   127402561)


--animations
Tool.Asset:RegisterAnim('firstequip',   79155144, 6, 0)
Tool.Asset:RegisterAnim('slash',        79155154, 3, 0)
--
Tool.Asset:RegisterAnim('entershield',  79155126, 6, 0)
Tool.Asset:RegisterAnim('walkshield',   79155174, 4, 0)
Tool.Asset:RegisterAnim('exitshield',   79155149, 6, 0)
--
Tool.Asset:RegisterAnim('begincharge',  79155105, 4, 0)
Tool.Asset:RegisterAnim('charge',       79155114, 4, 0)
Tool.Asset:RegisterAnim('endcharge',    79155124, 6, 0)
--
Tool.Asset:RegisterAnim('stash',        79155162, 6, 0)
Tool.Asset:RegisterAnim('equip2',       79155042, 6, 0)
Tool.Asset:RegisterAnim('hold2',        79155055, 1, 0)
Tool.Asset:RegisterAnim('slash2',       79155062, 2, 0)
Tool.Asset:RegisterAnim('taunt2',       79155095, 2, 0)
Tool.Asset:RegisterAnim('stash2',       79155073, 6, 0)
Tool.Asset:RegisterAnim('equip1',       79155032, 6, 0)


--sounds
Tool.Asset:RegisterSound('slashsharp',  45885030)
Tool.Asset:RegisterSound('swoosh2',     'SOUND_doubleswoosh')
Tool.Asset:RegisterSound('swoosh',      'SOUND_swoosh')
Tool.Asset:RegisterSound('equipsound',  'SOUND_equip')
Tool.Asset:RegisterSound('shieldstow',  'SOUND_shieldstow')

Tool.Asset:RegisterSound('chargesound', 116048294)
Tool.Asset:RegisterSound('deepswish',   120766256, 0.8, 0.5)
Tool.Asset:RegisterSound('charged',     127416781)
Tool.Asset:RegisterSound('swing',       120766256, 0.5, 1.0)


--global variables
Tool.Var:Create('shield',     'Int',  350)
Tool.Var:Create('shieldmode', 'Bool', false)
Tool.Var:Create('special',    'Bool', false)




--====================================================================================--
--                                 weapon holding code
--====================================================================================--

--create a handle for the shield
local Shield = Create'Part'{
	Name = 'Shield';
	FormFactor = 'Custom';
	Size = Vector3.new(2.5, 3.0, 0.6);
	CanCollide = false;
	Create'SpecialMesh'{
		MeshId = 'http://www.roblox.com/asset/?id=127402561';
		TextureId = 'http://www.roblox.com/asset/?id=127402402';
		Scale = Vector3.new(1.5, 1.5, 1.5);
		Name = 'Mesh';
	}
}
local ShieldAttach = Create'Motor6D'{
	Name = 'ShieldAttach';
	C0 = CFrame.new(-0.3,0,0); 
	C1 = CFrame.Angles(0, 0, 0);
}

--set the shield to be attached to the back for 1-handed mode
function AttachShieldToBack()
	ShieldAttach.Parent = Tool.Torso
	ShieldAttach.Part1 = Shield
	ShieldAttach.Part0 = Tool.Torso
	Shield.Parent = Tool.Character
end

--set the shield to be attached to the arm for 1handed mode
function AttachShieldToArm()
	ShieldAttach.Parent = Tool.LeftArm
	ShieldAttach.Part1 = Shield
	ShieldAttach.Part0 = Tool.LeftArm
	Shield.Parent = Tool.Character
end



--====================================================================================--
--                                 GUI setup code
--====================================================================================--

local ShieldScreenGui = Create'ScreenGui'{
	Name = 'AngelSword_Gui';
}

local BarGui = Create'Frame'{
	Style = 'RobloxRound';
	Position = UDim2.new(0.5, -128, 1, -210);
	Size = UDim2.new(0, 256, 0, 40);
	Name = 'BarGui';
	--
	Parent = ShieldScreenGui;
	--
	Create'Frame'{
		Name = 'Bar';
		Size = UDim2.new(1, 0, 1, 0);
		BackgroundColor3 = Color3.new(0.2, 0.2, 1.0);
	};
	Create'TextLabel'{
		Name = 'Label';
		Size = UDim2.new(1, 0, 1, 0);
		BackgroundTransparency = 1.0;
		Text = 'Shield Health: 400/400';
		Font = 'ArialBold';
		FontSize = 'Size14';
		TextColor3 = Color3.new(0.3, 0.3, 0.8);
		TextStrokeTransparency = 0;
		TextStrokeColor3 = Color3.new(1,1,1);
	};
}

local ReadyMessage = "Hold Q to protect yourself from damage.\n"..
                     "Doubleclick and hold to charge special!"
local ShieldMessage = "(Protecting From Damage)"
local ChargingMessage = "Imma chargin mah special attack!"
local SpecialMessage = "Hold the mouse button down to unleash the fury!!!\n"..
                       "Press Q while looking at someone to taunt"

local MessageGui = Create'Frame'{
	Style = 'RobloxRound';
	Position = UDim2.new(0.5, -128, 1, -160);
	Size = UDim2.new(0, 256, 0, 60);
	Name = 'UsageMessage';
	--
	Parent = ShieldScreenGui;
	--
	Create'TextLabel'{
		Name = 'Label';
		Size = UDim2.new(1, 0, 1, 0);
		BackgroundTransparency = 1.0;
		Text = 'Hold Q to protect\nyourself from damage\n';
		Font = 'Arial';
		FontSize = 'Size14';
		TextWrapped = true;
		TextColor3 = Color3.new(1, 1, 1);
		--TextStrokeTransparency = 0;
		--TextStrokeColor3 = Color3.new(1,1,1);
	};
}



--====================================================================================--
--                          settings for main functionality
--====================================================================================--
local GearMode = 'Ready' -- Ready | Shield | Charging | Special
local TimerStart = 0     --when charging or special started
local ShieldMax = 350    --how wuch shields
--
local ChargeTime = 6     --how long to charge
local SpecialTime = 20   --how long for the special
--
local UsingSword = false --anything that would block a state change from being done at
                         --a given time sets this to true: A 1hand slash, 2hand slash
                         --or a 2hand taunt
local IsWalking = false

local CurrentDamage = 0

--====================================================================================--
--                         main functionality implementation
--====================================================================================--

function HSVtoRGB(h, s, v)
	local hi = math.floor(h / 60) % 6
	local f = (h/60) - math.floor(h/60)
	local p = v*(1-s)
	local q = v*(1-f*s)
	local t = v*(1-(1-f)*s)
	if hi == 0 then
		return v, t, p
	elseif hi == 1 then
		return q, v, p
	elseif hi == 2 then
		return p, v, t
	elseif hi == 3 then
		return p, q, v
	elseif hi == 4 then
		return t, p, v
	elseif hi == 5 then
		return v, p, q
	end
end

--A generic update function which is called every frame. Performs both physical and 
--GUI changes
function Update()
	if GearMode == 'Shield' then
		--we have to update the shield UI for changes in the shield global
		--we could do this with an event, but the complexity isn't worth it.
		BarGui.Bar.Size = UDim2.new(Tool.Var.shield / ShieldMax, 0, 1, 0)
		BarGui.Label.Text = "Shield Health: "..Tool.Var.shield.." / "..ShieldMax

	elseif GearMode == 'Ready' then
		--in geady mode we don't have anything to do at all every frame

	elseif GearMode == 'Charging' then
		--in charging we need to update the amount of charge
		BarGui.Bar.Size = UDim2.new((tick()-TimerStart)/ChargeTime, 0, 1, 0)
		BarGui.Label.Text = "Charging Special: "..math.floor((tick()-TimerStart)/ChargeTime*100).."%"

	elseif GearMode == 'Special' then
		--lots of stuff. We need to update the charge left in our special,
		--make the sword to pretty flashing things, and make the charge bar
		--do pretty flashing things too.

		--set the bar position
		local fracLeft = 1-(tick()-TimerStart)/SpecialTime
		if fracLeft < 0 then fracLeft = 0 end
		BarGui.Bar.Size = UDim2.new(fracLeft, 0, 1, 0)
		local timeLeft = SpecialTime-(tick()-TimerStart)
		if timeLeft < 0 then timeLeft = 0 end
		BarGui.Label.Text = "Special Left: "..math.floor(timeLeft).."s"

		--calculate some pretty color based on time
		local t = tick()
		local h = (math.sin(t*10)+t*15)*10
		local s = 1
		local v = 1-math.sin(t*t - 5*h - t*t*t)^3
		local r, g, b = math.abs(math.sin(5*t)), math.abs(math.cos(7*t)), math.abs(math.cos(4*t))

		--calculate a scale modifier for the sword
		local smodlen = math.abs((0.5*(math.sin(3*t)+math.cos(4*t)))/5)
		local smodw = math.abs(math.sin(t*10))
		--
		Tool.Handle.Mesh.Scale = Vector3.new(1.5, 1.5+smodlen, 1.5+smodw)
		Tool.Handle.Mesh.VertexColor = Vector3.new(r, g, b)
		Shield.Mesh.VertexColor = Vector3.new(r, g, b)
		--
		BarGui.Bar.BackgroundColor3 = Color3.new(r, g, b)
		BarGui.Label.TextColor3 = Color3.new(r, g, b)
		BarGui.Label.TextStrokeColor3 = Color3.new(1-r, 1-g, 1-b)
	end
end

--set the bar to show how much shield are left when shields are active
function SetModeShield()
	GearMode = 'Shield'
	Tool.Var.shieldmode = true
	--
	BarGui.Bar.BackgroundColor3 = Color3.new(0.2, 0.2, 1.0)
	BarGui.Label.TextColor3 = Color3.new(0.2, 0.2, 1.0)
	BarGui.Label.TextStrokeColor3 = Color3.new(1.0, 1.0, 1.0)
	BarGui.Bar.Size = UDim2.new(Tool.Var.shield / ShieldMax, 0, 1, 0)
	BarGui.Label.Text = "Shield Health: "..Tool.Var.shield.." / "..ShieldMax
	MessageGui.Label.Text = ShieldMessage
	--
	Tool.Humanoid.WalkSpeed = 10
	--
	Spawn(function()
		UsingSword = true
		Tool.Animator.entershield:Play()
		--we have a special walking anim for the shielded player, use it
		local walkingCn = Tool.Humanoid.Running:connect(function(speed)
			if speed > 0 then
				Tool.Animator.walkshield:Play()
			else
				Tool.Animator.walkshield:Stop()
			end
		end)
		--start them walking te begin with if they already are
		if IsWalking then
			Tool.Animator.walkshield:Play()
		end
		--
		repeat wait() until GearMode ~= 'Shield'
		walkingCn:disconnect()
		--
		Tool.Animator.walkshield:Stop()
		Tool.Animator.entershield:Stop()
		Tool.Animator.exitshield:Play()
		UsingSword = false
		Tool.Var.shieldmode = false
	end)
end

--set the GUI to be doing nothing special
function SetModeReady()
	GearMode = 'Ready'
	Tool.Var.shieldmode = false
	--
	BarGui.Bar.BackgroundColor3 = Color3.new(0.2, 0.2, 1.0)
	BarGui.Label.TextColor3 = Color3.new(0.2, 0.2, 1.0)
	BarGui.Label.TextStrokeColor3 = Color3.new(1.0, 1.0, 1.0)
	BarGui.Bar.Size = UDim2.new(Tool.Var.shield / ShieldMax, 0, 1, 0)
	BarGui.Label.Text = "Shield Health: "..Tool.Var.shield.." / "..ShieldMax
	MessageGui.Label.Text = ReadyMessage
	--
	Tool.Humanoid.WalkSpeed = 16
end

--set GUI for charging special
function SetModeCharging()
	GearMode = 'Charging'
	Tool.Var.shieldmode = false
	--
	BarGui.Bar.BackgroundColor3 = Color3.new(1.0, 0.2, 0.2)
	BarGui.Label.TextColor3 = Color3.new(1.0, 0.2, 0.2)
	BarGui.Label.TextStrokeColor3 = Color3.new(1.0, 1.0, 1.0)
	BarGui.Bar.Size = UDim2.new(0, 1, 1, 0)
	BarGui.Label.Text = "Charging Special: 0%"
	MessageGui.Label.Text = ChargingMessage
	--
	Tool.Humanoid.WalkSpeed = 0
	--
	local id = ModeId
	local charging = false
	TimerStart = tick()
	Spawn(function()
		local lastSound = 0
		while GearMode == 'Charging' do
			local elapsed = tick()-TimerStart
			local frac = elapsed / ChargeTime
			--
			if charging and id == ModeId then
				Tool.Animator.charge:AdjustSpeed(0.8+frac*1.8)
			end
			--
			local deltaNow = (1-frac)*0.5 + 0.1
			if tick()-lastSound > deltaNow then
				lastSound = tick()
				Tool.Asset:PlaySound('chargesound')
			end
			--	
			wait()
		end
	end)
	Spawn(function()
		--
		Tool.Animator.begincharge:Play()
		repeat until    Tool.Animator.begincharge.KeyframeReached:wait() == 'complete' 
			         or not Tool.MouseDown
		Tool.Animator.begincharge:Stop()
		if not Tool.MouseDown then
			SetModeReady()
			return
		end
		--
		Tool.Animator.charge:Play(0.8, 0)
		Tool.Animator.charge:AdjustSpeed(0.8)
		charging = true
		repeat wait() until    not Tool.MouseDown 
			                or ((tick()-TimerStart) > ChargeTime)
		charging = false
		Tool.Animator.charge:Stop(0) --is looping, we need to stop it no matter how we
		                             --broke out of the loop.
		if Tool.MouseDown then --only if the mouse is still down should we go to special mode
			SetModeSpecial()
		else
			SetModeReady()
		end

		--and we need to end the charge, make sure we occupy the sword durring this time
		--so that the Ready mode can't slash yet.
		--UsingSword = true
		--Tool.Animator.endcharge:Play()
		--repeat until Tool.Animator.endcharge.KeyframeReached:wait() == 'complete'
		--UsingSword = false
	end)
end

--set the GUI for the special enabled mode
function SetModeSpecial()
	GearMode = 'Special'
	Tool.Var.shieldmode = false
	--
	Tool.Asset:PlaySound('charged')
	--
	--(color3 set in loop, is dynamic)
	BarGui.Bar.Size = UDim2.new(0, 1, 1, 0)
	BarGui.Label.Text = "Charging Special: 0%"
	MessageGui.Label.Text = SpecialMessage
	--
	Tool.Humanoid.WalkSpeed = 22
	--
	TimerStart = tick()
	Spawn(function()
		Tool.Var.special = true
		Tool.Animator.stash:Play()
		repeat until Tool.Animator.stash.KeyframeReached:wait() == 'complete'
		AttachShieldToBack()
		Tool.Animator.equip2:Play()
		repeat until Tool.Animator.equip2.KeyframeReached:wait() == 'complete'
		Tool.Animator.hold2:Play()
		--
		-- now, any time the mouse is held and something is not playing (a-la 
		-- UsingSword = true), we start a 2hand sword swing.
		while GearMode == 'Special' and (tick()-TimerStart) < SpecialTime do
			while 
				GearMode == 'Special'             and 
				Tool.MouseDown                    and 
				not UsingSword                    and 
				(tick()-TimerStart) < SpecialTime 
			do
				Tool.Asset:PlaySound('deepswish')
				CurrentDamage = 35
				UsingSword = true
				Tool.Animator.slash2:Play()
				repeat until Tool.Animator.slash2.KeyframeReached:wait() == 'complete'
				UsingSword = false
				CurrentDamage = 0
			end
			wait()
		end

		-- done this mode now, stop the hold anim and unstash the shield.
		Tool.Animator.hold2:Stop()
		--
		UsingSword = true
		Tool.Animator.stash2:Play()
		repeat until Tool.Animator.stash2.KeyframeReached:wait() == 'complete'
		AttachShieldToArm()
		Tool.Animator.equip1:Play()
		repeat until Tool.Animator.equip1.KeyframeReached:wait() == 'complete'
		UsingSword = false

		--fix the sword
		Tool.Handle.Mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
		Tool.Handle.Mesh.VertexColor = Vector3.new(1, 1, 1)
		Shield.Mesh.VertexColor = Vector3.new(1, 1, 1)

		--change the special flag
		Tool.Var.special = false

		--change modes
		SetModeReady()
	end)
end


--====================================================================================--
--                              main event handling code
--====================================================================================-- 

Tool.Handle.Touched:connect(function(part)
	--only damage player parts, not also player weapons + hats
	local hum = (part.Parent or game):FindFirstChild('Humanoid')
	if hum and CurrentDamage > 0 then
		Tool:DamageHumanoid(hum, CurrentDamage)
	end
end)



local LastClick = 0
Tool.Button1Down:connect(function()
	local t = tick()
	if (t-LastClick) > 0.3 then
		LastClick = t
		--do a single click
		if GearMode == 'Ready' then
			if not UsingSword then
				--we need rather special handling for a normal 1hand slash, since the
				--code which switches to charging mode may start playing if this is
				--really a doubleclick, not a single one. We have to keep checking if
				--we are still in Ready mode to handle this, which is a bit cumbersome
				--but the best solution to the problem as the starting part of the
				--slash anim is a bit slow, and there won't be any noticable ugliness
				--as a result of stopping it to play the stash anim on a double click.
				UsingSword = true
				Tool.Asset:PlaySound('swing')
				Tool.Animator.slash:Play()
				CurrentDamage = 30
				repeat until Tool.Animator.slash.KeyframeReached:wait() == 'complete'
					         or GearMode ~= 'Ready'
				CurrentDamage = 0
				Tool.Animator.slash:Stop() --in case we broke out before it was done
				UsingSword = false
			end
		end
	elseif GearMode == 'Ready' then
		--do a doubleclick. We want to enter the charging mode in this case

		LastClick = 0 --don't treat triple click as a double click

		SetModeCharging() --note, this will immediately change the GearMode, so we don't
		                  --have to worry about the user doing a slash or something.
	end
end)


function Taunt()
	--gather all of the humanoids in a 30stud radius
	local torsos = {}
	for _, p in pairs(game.Players:GetChildren()) do
		if p ~= Tool.Player then
			if p.Character and p.Character:FindFirstChild('Torso') then
				torsos[#torsos+1] = p.Character.Torso
			end
		end
	end

	--now pull them in towards us
	local mpos = Tool.Torso.Position
	for _, torso in pairs(torsos) do
		if (mpos-torso.Position).magnitude < 40 then
			local dir = (mpos-torso.Position).unit
			------------ stolen from dagger of time to make a character "fly" in some direction
				local force = Instance.new("BodyVelocity")
				force.velocity = Vector3.new(0,1,0)
				force.Parent = torso
				torso.Velocity = dir*250
				game.Debris:AddItem(force, 0.5)
			------------
		end
	end
end


Tool.KeyDown:connect(function(key)
	if key:lower() == 'q' then
		if GearMode == 'Ready' and not UsingSword then
			--enter shield mode
			SetModeShield()
		elseif GearMode == 'Special' and not UsingSword then
			--do a taunt
			UsingSword = true
			--
			Tool.Animator.taunt2:Play()
			--todo: tauntey things
			Taunt()
			repeat until Tool.Animator.taunt2.KeyframeReached:wait() == 'complete'
			--
			UsingSword = false
		end
	end
end)

Tool.KeyUp:connect(function(key)
	if key:lower() == 'q' then
		if GearMode == 'Shield' then
			--leave shield mode
			SetModeReady()
		end
	end
end)


local WalkingCn = nil
Tool.Equipped:connect(function()
	--play sound
	Tool.Asset:PlaySound('slashsharp')	
	
	--put the GUI in the user's playerGUI
	ShieldScreenGui.Parent = Tool.Player.PlayerGui

	--equip the shield
	AttachShieldToArm()

	--play the initial anim
	Tool.Animator.firstequip:Play()

	--fix stuff that may be stuck from us stopping abruptly before:
	--fix the sword
	Tool.Handle.Mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
	Tool.Handle.Mesh.VertexColor = Vector3.new(1, 1, 1)
	Shield.Mesh.VertexColor = Vector3.new(1, 1, 1)
	--fix other vars
	UsingSword = false
	IsWalking = false
	CurrentDamage = 0

	--set up tracking of when the player is walking
	WalkingCn = Tool.Humanoid.Running:connect(function(speed)
		if speed > 0 then
			IsWalking = true
		else
			IsWalking = false
		end
	end)

	--go into ready mode
	SetModeReady()

	--start the Updater Daemon
	while Tool.Selected do
		Update()
		wait()
	end
end)



Tool.Unequipped:connect(function()
	if WalkingCn then
		WalkingCn:disconnect()
		WalkingCn = nil
	end
	Walking = false

	--kill the GUI and extra handle
	ShieldScreenGui.Parent = nil
	Shield.Parent = nil
	ShieldAttach.Parent = nil
	
	if Tool.Humanoid then
		Tool.Humanoid.WalkSpeed = 16
	end

	--kill all the anims
	Tool.Animator:StopAll()
end)