while true do
	script.Parent:ChangeState(Enum.HumanoidStateType.FallingDown)
	local torso = script.Parent:FindFirstChild("Torso") or script.Parent:FindFirstChild("UpperTorso")
	if torso then
		script.Parent.Torso.RotVelocity = Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*2*30
	end
	wait(1)
end