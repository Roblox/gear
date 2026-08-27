local Tool = script.Parent;

enabled = true



s1 = Instance.new("Sound")
s1.SoundId = "http://www.roblox.com/asset/?id=12844799"
s1.Parent = Tool.Handle

s2 = Instance.new("Sound")
s2.SoundId = "http://www.roblox.com/asset/?id=12844794"
s2.Parent = Tool.Handle

s3 = Instance.new("Sound")
s3.SoundId = "http://www.roblox.com/asset/?id=12803520"
s3.Parent = Tool.Handle

s4 = Instance.new("Sound")
s4.SoundId = "http://www.roblox.com/asset/?id=12803507"
s4.Parent = Tool.Handle

s5 = Instance.new("Sound")
s5.SoundId = "http://www.roblox.com/asset/?id=12803498"
s5.Parent = Tool.Handle

local sayings = {s1,s2,s3,s4,s5}


function onActivated()
	if not enabled  then
		return
	end

	enabled = false
	
	Tool.GripForward = Vector3.new(1,0,0)
	Tool.GripPos = Vector3.new(.5,-1.5,-1.56)
	Tool.GripRight = Vector3.new(0,-.707,-.707)
	Tool.GripUp = Vector3.new(0,-.707,.707)

	sayings[math.random(1,#sayings)]:Play()
	wait(2)

	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripPos = Vector3.new(0,0,-.4)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)

	
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
