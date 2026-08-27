--[[
	Generic property interpolator.  Runs on RenderStepped on the client, runs at 20 Hz on the server.
	Bug reports go to ekoester@roblox.com
	
	Usage:
		interpolate = require(this)
		interpolate(object, property, valueType, startingValue, endingValue, time, easingMode, ...)
		
		- If startingValue is nil it will use the current value (object[property])
		- If endingValue is nil it will cancel the existing interpolation for that object's property instead of starting a new one
		- easingMode should be a string that corresponds with an entry in the "EasingModes" table.  It defaults to "Linear"
		- ... will be passed as extra arguments to the easingMode function.  Useful if your easingMode depends on specific information.
		- Starting an interpolation will cancel any existing interpolations
		- Supported value types are Number, Vector3, Vector2, UDim2, UDim, Color3, BrickColor
		
	Additions:
		Easing modes: Add a function to the "EasingModes" table.  You can use that mode by providing its name as the easingMode argument
			- Easing functions will never be called with a number higher than 1 though they are allowed to return any number
		Value types: Add a function to the "ValueTypes" table.  It should accept a starting value, ending value, and alpha value
--]]

local EasingModes = {
	Linear = function(a) -- Linear interpolation
		return a
	end,
	Sine = function(a) -- Interpolates on a sine wave
		return math.sin(a*math.pi/2)
	end,
	Bounce = function(a) -- Bounces
		return math.sin(a*math.pi/2) + math.sin(a*math.pi) * (math.cos(a*math.pi)+1)/2
	end,
	RevBounce = function(a) -- Reverse of Bounce
		a = 1-a
		a = math.sin(a*math.pi/2) + math.sin(a*math.pi) * (math.cos(a*math.pi)+1)/2
		a = 1-a
		return a
	end,
	Burst = function(a) -- Explodes
		return math.sin(a*math.pi/2)^0.2
	end,
	RidiculousWiggle = function(a, wiggles) -- Wiggles around
		local wiggles = wiggles or 1
		local f = math.sin(a*math.pi*wiggles)
		return f
	end,
	RidiculousWiggleSine = function(a, wiggles) -- Wiggles around, smoother
		local wiggles = wiggles or 1
		local f = math.sin(a*math.pi*wiggles)
		local s = math.sin(f*math.pi/2)
		return s
	end,
	SineArc = function(a) -- Full arc
		return math.sin(a*math.pi)
	end,
	Extrapolate = function(a, m) -- Extrapolates
		return a*m
	end,
	BendingSineArc = function(a, m)
		return math.sin(a*math.pi)^m
	end
}

local ValueTypes = {
	Number = function(a, b, alpha)
		return (b-a)*alpha+a
	end,
	Vector3 = function(a, b, alpha)
		return (b-a)*alpha+a
	end,
	Vector2 = function(a, b, alpha)
		return (b-a)*alpha+a
	end,
	UDim2 = function(a, b, alpha)
		return UDim2.new(
			(b.X.Scale-a.X.Scale)*alpha+a.X.Scale,
			(b.X.Offset-a.X.Offset)*alpha+a.X.Offset,
			(b.Y.Scale-a.Y.Scale)*alpha+a.Y.Scale,
			(b.Y.Offset-a.Y.Offset)*alpha+a.Y.Offset
		)
	end,
	UDim = function(a, b, alpha)
		return UDim.new(
			(b.Scale-a.Scale)*alpha+a.Scale,
			(b.Offset-a.Offset)*alpha+a.Offset
		)
	end,
	Color3 = function(a, b, alpha)
		return Color3.new(
			(b.r-a.r)*alpha + a.r,
			(b.g-a.g)*alpha + a.g,
			(b.b-a.b)*alpha + a.b
		)
	end,
	BrickColor = function(a, b, alpha)
		return BrickColor.new(
			(b.Color.r-a.Color.r)*alpha + a.Color.r,
			(b.Color.g-a.Color.g)*alpha + a.Color.g,
			(b.Color.b-a.Color.b)*alpha + a.Color.b
		)
	end,
	Function = function(a, b, alpha, obj)
		return b(alpha, obj)
	end,
	ColorSequence = function(a, b, alpha)
		if #b.Keypoints ~= #a.Keypoints then error('ColorSequenceKeypoint count does not match (a:'..#a.Keypoints..' b:'..#b.Keypoints..')') end
		local colors = {}
		for i=1, #a.Keypoints do
			local color = Color3.new(
				(b[i].r-a[i].r)*alpha + a[i].r,
				(b[i].g-a[i].g)*alpha + a[i].g,
				(b[i].b-a[i].b)*alpha + a[i].b
			)
			colors[i] = color
		end
		return ColorSequence.new(unpack(colors))
	end,
	CFrame = function(a, b, alpha)
		local ar = {a:toEulerAnglesXYZ()}
		local br = {b:toEulerAnglesXYZ()}
		return CFrame.new((b.p-a.p)*alpha+a.p) * CFrame.Angles(
			(br[1]+ar[1])*alpha+ar[1],
			(br[2]+ar[2])*alpha+ar[2],
			(br[3]+ar[3])*alpha+ar[3]
		)
	end,
	CFrameLerp = function(a, b, alpha)
		return a:lerp(b, alpha)
	end
}

---------------
-- CONSTANTS --
---------------
local runService = game:GetService'RunService'
local isServer = game:FindService'NetworkServer' ~= nil

---------------
-- VARIABLES --
---------------
local activeInterpolations = {}

---------------
-- FUNCTIONS --
---------------
function updateInterpolation(info)
	local alpha = (tick()-info.StartedAt)/info.Time
	local finished = false
	if alpha >= 1 then
		alpha = 1
		finished = true
	end
	if info.EasingMode ~= nil then
		alpha = EasingModes[info.EasingMode](alpha, info.Extra and unpack(info.Extra) or nil)
		if type(alpha) ~= 'number' then
			error('Easing mode '..tostring(info.EasingMode)..' did not return a number.')
		end
	end
	
	local new = ValueTypes[info.Type](info.A, info.B, alpha, info.Object)
	info.Object[info.Property] = new
	
	return finished
end

function updateInterpolations()
	for object, propertyList in next, activeInterpolations do
		local removed = false
		for property, info in next, propertyList do
			local remove = updateInterpolation(info)
			if remove then
				propertyList[property] = nil
				removed = true
				info.Event:Fire(object, true)
				info.Event:Destroy()
			end
		end
		if removed and next(propertyList)==nil then
			activeInterpolations[object] = nil
		end
	end
end

function startInterpolation(object, property, type, a, b, time, mode, ...)
	if b == nil then
		if activeInterpolations[object] ~= nil then
			activeInterpolations[object][property].Event:Fire(object, false)
			activeInterpolations[object][property].Event:Destroy()
			activeInterpolations[object][property] = nil
			if next(activeInterpolations[object])==nil then
				activeInterpolations[object] = nil
			end
		end
	else
		if ValueTypes[type] == nil then
			error('Failed to interpolate object '..tostring(object)..'.'..tostring(property)..' because '..tostring(type)..' is not a supported value type.')
		elseif mode ~= nil and EasingModes[mode] == nil then
			error('Failed to interpolate object '..tostring(object)..'.'..tostring(property)..' because '..tostring(mode)..' is not a valid easing mode.')
		end
		
		local info = {
			Object = object,
			Property = property,
			Type = type,
			A = a or object[property],
			B = b,
			Time = time,
			EasingMode = mode,
			Extra = ...~=nil and {...},
			StartedAt = tick(),
			Event = Instance.new'BindableEvent'
		}
		
		if activeInterpolations[object] == nil then
			activeInterpolations[object] = {}
		end
		if activeInterpolations[object][property] ~= nil then
			activeInterpolations[object][property].Event:Fire(object, false)
			activeInterpolations[object][property].Event:Destroy()
		end
		activeInterpolations[object][property] = info
		
		updateInterpolation(info)
		
		return info.Event.Event
	end
end

----------
-- MAIN --
----------
function main()
	if isServer then
		spawn(function()
			while true do
				updateInterpolations()
				wait(1/20)
			end
		end)
	else
		runService:BindToRenderStep('Interpolator', 1, updateInterpolations)
	end
end

----------
-- INIT --
----------
main()

------------
-- RETURN --
------------
return startInterpolation