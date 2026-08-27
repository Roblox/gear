base = script.Parent.Base
math.randomseed(tick())
wait(1)
while true do
	targetPos = Vector3.new(math.random(base.Position.X - 25, base.Position.X + 25), script.Parent.GroundHeight.Value + 0.5, math.random(base.Position.Z - 25, base.Position.Z + 25))
	base.BodyPosition.position = targetPos
	base.CFrame = CFrame.new(base.Position, -targetPos)
	wait(1)
end