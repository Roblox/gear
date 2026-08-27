local Trap = script.Parent
local Mesh = Trap.Mesh
local ChompSound = Trap.ChompSound
trapDamage = 50
meshClosed = "http://www.roblox.com/asset/?id=59711981"
meshOpen = "http://www.roblox.com/asset/?id=59713741"
closedSize = Vector3.new(2.47, 2.25, 1.21)
openSize = Vector3.new(2, 3, 0.5)

wait(0.5)
Mesh.MeshId = meshOpen
Trap.Size = openSize

wait(1.5)

Trap.Transparency = 0.9
local connection
local count = 0

function clamp(hit)	
	if count == 0 then 
	
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if not humanoid then return end 
		count = 1 
		if not hit.Parent then return end		
		Trap.Transparency = 0.0
		Mesh.MeshId = meshClosed
		Trap.Size = closedSize
		if ChompSound then ChompSound:Play() end		
		humanoid:TakeDamage(trapDamage)	
		Trap.Transparency = 0.2 
		humanoid.WalkSpeed = 10.0
		wait(5)		
		humanoid.WalkSpeed = 16.0
		Trap.Transparency = 0.9 
		Mesh.MeshId = meshOpen
		Trap.Size = openSize
		count = count + 1
		count = 0
	end
end

connection = Trap.Touched:connect(clamp)





