local monkey = script.Parent
local connections = {}
local touched = nil

function onTouched(part)

	local human = part.Parent:FindFirstChild("Humanoid")
	if human ~= nil then
		
		monkey.CanCollide = false
		local torso =  human.Parent:FindFirstChild("Torso") or human.Parent:FindFirstChild("UpperTorso")
		local weld = Instance.new("Weld")
		weld.Parent = monkey
		weld.Part0 = monkey
		weld.Part1 = torso
		weld.C0 = CFrame.new(math.random(-1,1),math.random(-0.5,0.5),-0.7)
		local con = human.Jumping:connect(function()
			local force = Instance.new("BodyForce")
			force.force = Vector3.new(0,-10000,0)
			force.Parent = part
			game:GetService('Debris'):AddItem(force, 0.1)
		end)
		table.insert(connections,con)
		touched:disconnect()
	end

end

function removeMonkey()

	if #connections > 0 then
		wait(5)
	end

	for i = 1, #connections do
		connections[i]:disconnect()
	end

	monkey:Destroy()
end

touched = monkey.Touched:connect(onTouched)
delay(10, removeMonkey)

