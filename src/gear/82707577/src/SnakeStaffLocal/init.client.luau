do
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
					Parent = self.Model;
				}
				if speed then
					Create'NumberValue'{
						Name = 'speed';
						Value = speed;
						Parent = obj;
					}
				end
				if fadeTime then
					Create'NumberValue'{
						Name = 'fadeTime';
						Value = fadeTime;
						Parent = obj;
					}
				end
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
			for _, anim in pairs(self.Model:GetChildren()) do
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
					function proxy:Stop(fadeTime)
						track:Stop(fadeTime or defaultFade or 0.1)
					end
					proxy.KeyframeReached = track.KeyframeReached
					--
					anims[anim.Name] = proxy
				end
			end
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
			if type(id) == 'string' then
				return id
			elseif type(id) == 'number' then
				return 'http://www.roblox.com/asset/?id='..id
			end
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
end
local Tool = CreateTool()

--====================================================================================--
--                                 asset setup code
--====================================================================================--

--animations
Tool.Asset:RegisterAnim('equip', 82272273, 4, 0.1)
Tool.Asset:RegisterAnim('fire',  82272303, 4, 0.0)
Tool.Asset:RegisterAnim('slash', 82272327, 3, 0.0)

--sounds
Tool.Asset:RegisterSound('slashsharp',  45885030)

--settings
local DoubleClickThreshold = 0.1

local Reloading = false

local function SingleClick()
	if Reloading then return end
	Reloading = true
	Tool.Mouse.Icon = 'rbxasset://textures\\advCursor-default.png'

	--fire a shot
	Tool.Handle.FireSound:Play()
	Tool.Animator.fire:Play()

	--get the heading
	local fireFrom = (Tool.RightArm.CFrame*CFrame.new(0,-2,0)).p
	local fireTo = Tool.Mouse.Hit.p

	--put in the script
	local sc = script.Parent.ShotScript:Clone()
	sc.cframe.Value = CFrame.new(fireFrom, fireTo)
	sc.creator.Value = Tool.Player
	sc.Disabled = false
	sc.Parent = game.Workspace

	wait(1.8)
	Reloading = false
	Tool.Mouse.Icon = 'rbxasset://textures\\advCursor-white.png'
end

local ClickId = 0
local function DoubleClick()
	if Reloading then return end
	Reloading = true
	ClickId = ClickId+1
	local ThisClickId = ClickId
	Tool.Mouse.Icon = 'rbxasset://textures\\advCursor-default.png'

	--slash
	Tool.Handle.SlashSound:Play()
	Tool.Animator.slash:Play()

	--put in the script
	local sc = script.Parent.SlashScript:Clone()
	sc.position.Value = Tool.Torso.Position
	sc.creator.Value = Tool.Player
	sc.Disabled = false
	sc.Parent = game.Workspace

	wait(0.2)
	Tool.Handle.FieldSound.Volume = 1
	Tool.Handle.FieldSound:Play()
	Spawn(function()
		for i = 1, 0, -0.03 do
			wait(0.03)
			if ClickId ~= ThisClickId then return end
			Tool.Handle.FieldSound.Volume = i
		end
	end)

	wait(1.2)
	Reloading = false
	Tool.Mouse.Icon = 'rbxasset://textures\\advCursor-white.png'
end

--handlers
local LastClickTime = 0
local DiddoubleClick = false

--the main handler
Tool.Button1Down:connect(function()
	local t = tick()
	if (t-LastClickTime) < 0.25 then
		LastClickTime = 0
		DiddoubleClick = true
		print("Double")
		DoubleClick()
	else
		LastClickTime = t
		wait(0.25)
		if DiddoubleClick then
			DiddoubleClick = false
		else
			print("Single")
			SingleClick()
		end
	end
end)

Tool.Equipped:connect(function()
	Tool.Mouse.Icon = 'rbxasset://textures\\advCursor-white.png'
	Tool.Animator.equip:Play()
end)

Tool.Unequipped:connect(function()
	Tool.Animator.equip:Stop()
end)