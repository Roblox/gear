local FIRE_DAMAGE = 5

local hitCharacter = script.Parent
local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")
local hitTorso = hitCharacter:FindFirstChild("Torso")

local Fire = Instance.new("Fire")
Fire.Size = 5
if hitTorso then Fire.Parent = hitTorso end


for i = 1, 5 do
	wait(1)
	if hitHumanoid then hitHumanoid:TakeDamage(FIRE_DAMAGE) end
end

Fire:Remove()
script:Remove()