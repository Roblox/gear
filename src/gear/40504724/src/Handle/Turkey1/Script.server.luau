base = script.Parent.Base
math.randomseed(tick())
wait(1)
while true do
	targetPos = Vector3.new(math.random(base.Position.X - 20, base.Position.X + 20), script.Parent.GroundHeight.Value, math.random(base.Position.Z - 20, base.Position.Z + 20))
	base.BodyPosition.position = targetPos
	base.CFrame = CFrame.new(base.Position, -targetPos)
	wait(1)
end