local Creep = script.Parent
local creep1 = Creep.Handle.CreepSound1
local creep2 = Creep.Handle.CreepSound2
local creep3 = Creep.Handle.CreepSound3
local creep4 = Creep.Handle.CreepSound4
local creep5 = Creep.Handle.CreepSound5
local creep6 = Creep.Handle.CreepSound6


local colors = {Vector3.new(2,2,2), Vector3.new(1,0,0), Vector3.new(0,1,0), Vector3.new(0,0,1), Vector3.new(1,1,0), Vector3.new(0,1,1), Vector3.new(1,0,1)}
local floatRadius = 4


Creep.Enabled = true
function onActivated()
	if not Creep.Enabled then return end
	Creep.Enabled = false
	whichSound = math.random(1, 5)
	creepSound = Creep.Handle:FindFirstChild("CreepSound"..whichSound)
	if creepSound ~= nil then creepSound:Play() end
	
	local origPos = Vector3.new(0.1, -0.1, -0.2)
	local headPos = Vector3.new(1.5, 1.5, -1)

	--local alpha = math.random()*math.pi*2
	--local beta = math.random()*math.pi*2
	local alpha = 5*math.pi/4
	local beta = 0

	for i = 1, 7 do
		alpha = alpha + math.random()*math.pi*4/3 - math.pi*2/3 -- do it this way to minimize passing thru the center of the character by limiting the change of angle
		beta = beta + math.random()*math.pi*4/3 - math.pi*2/3

		local endPos = headPos + Vector3.new(math.sin(alpha)*math.cos(beta), math.cos(alpha)*math.cos(beta), math.sin(beta))*floatRadius
		local startPos = Creep.GripPos
		local startColor = Creep.Handle.Mesh.VertexColor
		local endColor = colors[math.random(1, #colors)]
		if i == 7 then endColor = Vector3.new(1,1,1) endPos = origPos end
		for j = 1, 5 do
			Creep.GripPos = startPos * (5-j)/5 + endPos * j/5
			Creep.Handle.Mesh.VertexColor = startColor * (5-j)/5 + endColor * j/5
			wait(.05)
		end
	end

	--Creep.GripForward = Vector3.new(0, 1, 0)
	--Creep.GripRight = Vector3.new(1, 0, 0)
	--Creep.GripPos = Vector3.new(0.1, -0.1, -0.2)

	Creep.Enabled = true

end

function onEquipped()
	creep1.Volume = 1
	creep2.Volume = 1
	creep3.Volume = 1
	creep4.Volume = 1
	creep5.Volume = 1
	creep6.Volume = 1
	creep6:Play()
end

function onUnequipped()
	creep1.Volume = 0
	creep2.Volume = 0
	creep3.Volume = 0
	creep4.Volume = 0
	creep5.Volume = 0
	creep6.Volume = 0
	creep1:Stop()
	creep2:Stop()
	creep3:Stop()
	creep4:Stop()
	creep5:Stop()
	creep6:Stop()
end

Creep.Unequipped:connect(onUnequipped)
Creep.Equipped:connect(onEquipped)
Creep.Activated:connect(onActivated)
