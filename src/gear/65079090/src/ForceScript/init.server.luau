local vCharacter = script.Parent

local myTorso = vCharacter:FindFirstChild("Torso")

while script:FindFirstChild("Direction") == nil do 
	wait()
end

local direction = script.Direction.Value

if myTorso then 
	local bv = Instance.new("BodyVelocity") 
	bv.P = 300000
	bv.maxForce = Vector3.new(bv.P, bv.P, bv.P)
	bv.velocity = direction * 30.0
	bv.Parent = myTorso

	wait(1.50)

	if bv then bv:Remove() end
end

wait(2.0)
if script then script:Remove() end
