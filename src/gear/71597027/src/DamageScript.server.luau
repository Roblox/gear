while not script:FindFirstChild("Damage") or not script:FindFirstChild("Owner") do
	script.ChildAdded:wait()
end
local DamageToDo = script.Damage.Value
local HumToDamage = script.Parent.Humanoid
local OwnerToTagAs = script.Owner.Value

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

local tag = Create'ObjectValue'{
	Name = "creator", 
	Value = OwnerToTagAs,
	Parent = HumToDamage,
}
game.Debris:AddItem(tag, 1)

HumToDamage:TakeDamage(DamageToDo)