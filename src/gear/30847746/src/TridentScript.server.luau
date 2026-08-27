local trident = script.Parent
local debris = game:GetService("Debris")
local impaled = false

function onTouched(part)

	if not impaled then
		
		impaled = true
		debris:AddItem(trident, 5)

		local weld = Instance.new("Weld")
		weld.Part0 = trident
		weld.Parent = trident

		local h = part.Parent:FindFirstChild("Humanoid")
		if h ~= nil then
			h:TakeDamage(21)
			weld.Part1 = h.Parent.Torso
		else	
			weld.Part1 = part
			weld.C0 = CFrame.new(trident.Position - part.Position)
		end

	end

end

trident.Touched:connect(onTouched)

wait(10)

trident:remove()
