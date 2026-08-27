local Tool = script.Parent;

enabled = true



s1 = Instance.new("Sound")
s1.SoundId = "http://www.roblox.com/asset/?id=16921115"
s1.Parent = Tool.Handle

s2 = Instance.new("Sound")
s2.SoundId = "http://www.roblox.com/asset/?id=16921154"
s2.Parent = Tool.Handle

s3 = Instance.new("Sound")
s3.SoundId = "http://www.roblox.com/asset/?id=16921173"
s3.Parent = Tool.Handle

s4 = Instance.new("Sound")
s4.SoundId = "http://www.roblox.com/asset/?id=16921198"
s4.Parent = Tool.Handle

local sayings = {s1,s2,s3,s4}


function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	
	Tool.GripForward = Vector3.new(-0, -1, -0)
	Tool.GripPos = Vector3.new(-2, -0.6, -0)
	Tool.GripRight = Vector3.new(-1, 0, -0)
	Tool.GripUp = Vector3.new(-0, 0, 1)

	sayings[math.random(1,#sayings)]:Play()
	wait(2)

	Tool.GripForward = Vector3.new(-0, 1, 0)
	Tool.GripPos = Vector3.new(0, -0.3, -0.2)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, -0, 1)

	
	enabled = true

end

function onEquipped()
	for i=1,#sayings do
		sayings[i].Volume = 1
	end
end

function onUnequipped()
	for i=1,#sayings do
		sayings[i].Volume = 0
	end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
