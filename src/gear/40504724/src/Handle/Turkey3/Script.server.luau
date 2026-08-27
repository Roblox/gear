base = script.Parent.Base
math.randomseed(tick())
wait(1)
while true do
	targetPos = Vector3.new(math.random(base.Position.X - 30, base.Position.X + 30), script.Parent.GroundHeight.Value + 0.5, math.random(base.Position.Z - 30, base.Position.Z + 30))
	base.BodyPosition.position = targetPos
	base.CFrame = CFrame.new(base.Position, -targetPos)
	wait(1)
end