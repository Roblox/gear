local frost = script.Parent:FindFirstChild("Frost")

while frost == nil do
	frost = script.Parent:FindFirstChild("Frost")
	wait()
end

local weld = Instance.new("Weld")
weld.Part0 = script.Parent.Frost
weld.Parent = weld.Part0
weld.Part1 = script.Parent.Handle
weld.C0 = CFrame.new(0,-1.5,0)
weld.C1 = CFrame.Angles(0,0,math.pi/2)
script.Parent.Frost.Anchored = false

function onEquipped()
	script.Parent.Frost.Anchored = true
	local weld = Instance.new("Weld")
	weld.Part0 = script.Parent.Frost
	weld.Parent = weld.Part0
	weld.Part1 = script.Parent.Handle
	weld.C0 = CFrame.new(0,-1.5,0)
	weld.C1 = CFrame.Angles(0,0,math.pi/2)
	script.Parent.Frost.Anchored = false
end

script.Parent.Equipped:connect(onEquipped)