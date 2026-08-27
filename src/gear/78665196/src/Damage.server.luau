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
local DamageBin = WaitForChild(Tool,"DamageBin")

Tool.Equipped:connect(function()
	local Character,Humanoid = GetCharacter(Tool)
	local Player = Players:GetPlayerFromCharacter(Character)

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
	Disconnect("DamageBin")
end)