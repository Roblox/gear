-- Variables for the trap and its meshes.
local Trap = script.Parent
local Mesh = Trap.Mesh
local ChompSound = Trap.ChompSound
TRAP_DAMAGE = 30
CLOSED_MESH = "http://www.roblox.com/asset/?id=54031359"
OPEN_MESH = "http://www.roblox.com/asset/?id=54036937"
CLOSED_SIZE = Vector3.new(2.47, 2.05, 1.21)
OPEN_SIZE = Vector3.new(2.25, 3.01, 2.24)

-- Give the trap a little while to fall,
wait(0.5)
-- make it almost invisible,
--Trap.Transparency = 0.9
-- then open it and change its size.
Mesh.MeshId = OPEN_MESH
Trap.Size = OPEN_SIZE

-- Give the person who dropped it time to get away.
wait(1.5)

-- Connection
local connection

-- This semi-cheating counter is to make sure only one clamp call runs at a time, so a single person
-- doesn't get multiple limbs hit by the same clam at the same time.
local count = 0

-- clamp: Makes the clam slam, injuring whoever touched it.
function clamp(hit)	
	if count == 0 then 
		-- Make sure the hit was by someone who's still alive!
		local hitHum = hit.Parent:FindFirstChild("Humanoid")
		if not hitHum then print("Not a human") print(hit.Name) print(hit.Parent.Name) return end 
		count = 1 
		if not hit.Parent then return end

		-- Disconnect this function (temporarily) so the trap doesn't go off again anytime soon.
		--if connection then connection:disconnect() end

		-- Make the trap visible, close the clam, make a sound...
		Trap.Transparency = 0.0
		Mesh.MeshId = CLOSED_MESH
		Trap.Size = CLOSED_SIZE
		if ChompSound then ChompSound:Play() end

		-- ... and damage whoever touched it.
		hitHum:TakeDamage(TRAP_DAMAGE)

		-- Wait a little while, then open again, reconnecting clamp.		
		wait(5)
		--Trap.Transparency = 0.9
		Mesh.MeshId = OPEN_MESH
		Trap.Size = OPEN_SIZE
		count = count + 1
		count = 0
	end
end

connection = Trap.Touched:connect(clamp)





