local Creep = script.Parent
local creep1 = Creep.Handle.CreepSound1
local creep2 = Creep.Handle.CreepSound2
local creep3 = Creep.Handle.CreepSound3
local creep4 = Creep.Handle.CreepSound4
local creep5 = Creep.Handle.CreepSound5
local creep6 = Creep.Handle.CreepSound6

Creep.Enabled = true
function onActivated()
	if not Creep.Enabled then return end
	Creep.Enabled = false
	whichSound = math.random(1, 5)
	creepSound = Creep.Handle:FindFirstChild("CreepSound"..whichSound)
	if creepSound ~= nil then creepSound:Play() end
	for i = 1, 45 do
		angle = i*math.pi*3/25
		-- spin
		Creep.GripForward = Vector3.new(math.sin(angle), math.cos(angle), 0)
		Creep.GripRight = Vector3.new(math.cos(angle), -math.sin(angle), 0)
		
		-- below is dance without spin
		--Creep.GripPos = Vector3.new(math.sin(angle), math.cos(angle), math.sin(angle/1.7))

		-- now need dance accounting for spin (new coordinate systems) [should need to mess with first two coords only]
		Creep.GripPos = Vector3.new(1, 0, math.sin(angle/1.7))
		wait(.05)
	end

	Creep.GripForward = Vector3.new(0, 1, 0)
	Creep.GripRight = Vector3.new(1, 0, 0)
	Creep.GripPos = Vector3.new(0, 0, 0)

	Creep.Enabled = true

end

function onEquipped()
	--CREEPSOUNDS:  40455621, 40455679,  40455718, 40455751, 40455781, 40455802
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
