local Handle = script.Parent
if Handle.className == "Part" then

	local Mesh = Handle:FindFirstChild("Plant Mesh")
	local scaler = 1

	Handle.Friction = 1
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.Parent = Handle
	BodyGyro.cframe = Handle.CFrame
	BodyGyro.maxTorque = Vector3.new(1000,1000,1000)
	BodyGyro.P = 1000
	BodyGyro.D = 50

	BodyPos = Instance.new("BodyPosition")
	BodyPos.position = Handle.Position
	BodyPos.P = 1000
	BodyPos.D = 500
	BodyPos.maxForce = Vector3.new(1000,1000,1000)

	while true do

		wait(10)
		BodyPos.Parent = Handle
		Mesh.Scale = Mesh.Scale + Vector3.new(scaler,scaler,scaler)
		BodyPos.position = BodyPos.position + Vector3.new(0,0.7,0)

	end

end
