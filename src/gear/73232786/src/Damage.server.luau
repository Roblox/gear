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

local function Create(ty)
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
		for func, conn in pairs(mListeners) do
			func(...)
		end
		mWaitObject.Value = not mWaitObject.Value
	end

	function this:wait()
		mWaitObject.Changed:wait()
	end
end)

--[[
	DamageReducer
		Reduces damage taken to humanoid by a specified percentage.

	CreateDamageReducer()
		Returns a new DamageReducer.
	DamageReducer:SetHumanoid(humanoid)
		Sets the humanoid. `humanoid` can be nil.
	DamageReducer:SetActive(active)
		Sets whether the damage reducer is active.
	DamageReducer:SetReduction(pct)
		Sets the amount of damage reduction as a percentage.
]]
class'DamageReducer'(function(def)
	local reduction = 0
	local active = false
	local humanoid
	local changed

	local function connect_changed()
		if not changed then
			local e = true
			local last_health = humanoid.Health
			changed = humanoid.HealthChanged:connect(function(health)
				if e then
					e = false
					if health < last_health then
						local damage = math.abs(health - last_health)
						humanoid.Health = health + damage*reduction
					end
					e = true
				end
				last_health = humanoid.Health
			end)
		end
	end

	local function disconnect_changed()
		if changed then
			changed:disconnect()
			changed = nil
		end
	end

	function def:SetHumanoid(h)
		if changed then
			disconnect_changed()
		end
		humanoid = h
		if h and active then
			connect_changed()
		end
	end

	function def:SetReduction(pct)
		reduction = pct < 0 and 0 or pct > 1 and 1 or pct
	end

	function def:SetActive(a)
		active = a
		if a then
			connect_changed()
		else
			disconnect_changed()
		end
	end
end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Tiny Event Manager; Add: [[Event.EventName = (event)]]; Remove: [[Disconnect("EventName",...)]]
local Event = {}
local function Disconnect(...)
	for _,name in pairs{...} do
		if Event[name] then
			Event[name]:disconnect()
			Event[name] = nil
		end
	end
end

-- get an object; make it if it doesn't exist
local function GetMake(parent,name,type)
	local object = parent:FindFirstChild(name)
	if not object then
		object = Create(type){Name=name}
		object.Parent = parent
	end
	return object
end

-- wait until child exists; return child
local function WaitForChild(parent,name)
	while not parent:FindFirstChild(name) do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end

-- get a sibling humanoid of object; by humanoid, not by name
local function GetHumanoid(object)
	if object and object.Parent then
		for i,v in pairs(object.Parent:GetChildren()) do
			if v:IsA"Humanoid" then
				return v
			end
		end
	end
	return nil
end

-- get the parent character from an object; verified by GetHumanoid
local function GetCharacter(object)
	local humanoid = GetHumanoid(object)
	if humanoid then
		return object.Parent,humanoid
	end
	return nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Players = Game:GetService("Players")
local Debris = Game:GetService("Debris")

local Tool = script.Parent
local Handle = WaitForChild(Tool,"Handle")
local BurnScript = Tool:FindFirstChild("BurnScript")
local DamageBin = WaitForChild(Tool,"DamageBin")
local Spinning = WaitForChild(Tool,"Spinning")

local DamageReducer = CreateDamageReducer()
DamageReducer:SetReduction(0.25)

Spinning.Changed:connect(function(value)
	DamageReducer:SetActive(value)
end)

Tool.Equipped:connect(function()
	local Character,Humanoid = GetCharacter(Tool)
	local Player = Players:GetPlayerFromCharacter(Character)

	if BurnScript then
		local ctag = GetMake(BurnScript,"creator","ObjectValue")
		ctag.Value = Player
	end

	DamageReducer:SetHumanoid(Humanoid)

	Event.DamageBin = DamageBin.ChildAdded:connect(function(dtag)
		if dtag:IsA"ObjectValue" then
			local humanoid = dtag.Value
			local damage = tonumber(dtag.Name)
			if humanoid and damage then
				local ctag = Create'ObjectValue'{
					Name = "creator";
					Value = Player;
				}
				ctag.Parent = humanoid
				humanoid:TakeDamage(damage)
				Debris:AddItem(ctag,1)
				Debris:AddItem(dtag,1)
			end
		end
	end)
end)

Tool.Unequipped:connect(function()
	DamageReducer:SetHumanoid()
	Disconnect("DamageBin")
end)