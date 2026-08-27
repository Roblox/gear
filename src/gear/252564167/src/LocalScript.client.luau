--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
local function Create_PrivImpl(objectType)
	if type(objectType) ~= 'string' then
		error("Argument of Create must be a string", 2)
	end
	--return the proxy function that gives us the nice Create'string'{data} syntax
	--The first function call is a function call using Lua's single-string-argument syntax
	--The second function call is using Lua's single-table-argument syntax
	--Both can be chained together for the nice effect.
	return function(dat)
		--default to nothing, to handle the no argument given case
		dat = dat or {}

		--make the object to mutate
		local obj = Instance.new(objectType)
		local parent = nil

		--stored constructor function to be called after other initialization
		local ctor = nil

		for k, v in pairs(dat) do
			--add property
			if type(k) == 'string' then
				if k == 'Parent' then
					-- Parent should always be set last, setting the Parent of a new object
					-- immediately makes performance worse for all subsequent property updates.
					parent = v
				else
					obj[k] = v
				end


			--add child
			elseif type(k) == 'number' then
				if type(v) ~= 'userdata' then
					error("Bad entry in Create body: Numeric keys must be paired with children, got a: "..type(v), 2)
				end
				v.Parent = obj


			--event connect
			elseif type(k) == 'table' and k.__eventname then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create.E\'"..k.__eventname.."\']` must have a function value\
							got: "..tostring(v), 2)
				end
				obj[k.__eventname]:connect(v)


			--define constructor function
			elseif k == t.Create then
				if type(v) ~= 'function' then
					error("Bad entry in Create body: Key `[Create]` should be paired with a constructor function, \
							got: "..tostring(v), 2)
				elseif ctor then
					--ctor already exists, only one allowed
					error("Bad entry in Create body: Only one constructor function is allowed", 2)
				end
				ctor = v


			else
				error("Bad entry ("..tostring(k).." => "..tostring(v)..") in Create body", 2)
			end
		end

		--apply constructor function if it exists
		if ctor then
			ctor(obj)
		end

		if parent then
			obj.Parent = parent
		end

		--return the completed object
		return obj
	end
end

--now, create the functor:
Create = setmetatable({}, {__call = function(tb, ...) return Create_PrivImpl(...) end})

--and create the "Event.E" syntax stub. Really it's just a stub to construct a table which our Create
--function can recognize as special.
Create.E = function(eventName)
	return {__eventname = eventName}
end


Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
}

AnimationTracks = {}

ToolEquipped = false

function SetAnimation(mode, value)
	local function StopAnimation(Animation, Fade)
		for i, v in pairs(AnimationTracks) do
			if v.Animation == Animation then
				v.AnimationTrack:Stop((Fade and value.FadeTime) or nil)
				if v.TrackStopped then
					v.TrackStopped:disconnect()
				end
				table.remove(AnimationTracks, i)
			end
		end
	end
	if mode == "PlayAnimation" then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				if value.Speed then
					v.AnimationTrack:AdjustSpeed(value.Speed)
					return
				elseif value.Weight or value.FadeTime then
					v.AnimationTrack:AdjustWeight(value.Weight, value.FadeTime)
					return
				else
					StopAnimation(value.Animation, false)
				end
			end
		end
		local AnimationMonitor = Create("Model"){}
		local TrackEnded = Create("StringValue"){Name = "Ended"}
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		local TrackStopped
		TrackStopped = AnimationTrack.Stopped:connect(function()
			if TrackStopped then
				TrackStopped:disconnect()
			end
			StopAnimation(value.Animation, true)
			TrackEnded.Parent = AnimationMonitor
		end)
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack, TrackStopped = TrackStopped})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
		AnimationMonitor:WaitForChild(TrackEnded.Name)
		return TrackEnded.Name
	elseif mode == "StopAnimation" and value then
		StopAnimation(value.Animation, true)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		SetAnimation("PlayAnimation", Animations.Hold)
	end)
end

function Unequipped()
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	AnimationTracks = {}
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)