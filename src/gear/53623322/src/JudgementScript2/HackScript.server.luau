local Tool = script.Parent

pos = Tool:FindFirstChild("Pos")

judgementBall = game.Workspace:FindFirstChild("JUDGEMENT")

while judgementBall == nil do 
	judgementBall = game.Workspace:FindFirstChild("JUDGEMENT")
	wait(1.0)
end

bv = Instance.new("BodyVelocity")
bv.Name = "Movement"
bv.P = 100000
bv.maxForce = Vector3.new(100000, 100000, 100000)
bv.Parent = judgementBall

function onChange()
	bv.velocity = pos.Value
end

pos.Changed:connect(onChange)