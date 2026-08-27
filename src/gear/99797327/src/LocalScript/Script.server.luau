--Made by Stickmasterluke


sp=script.Parent


debris=game:GetService("Debris")

wait(3)

for i=1,8 do
	wait(.5)
	local p=Instance.new("Part")
	p.Name="Effect"
	p.CanCollide=true
	p.Anchored=false
	p.FormFactor="Custom"
	p.Size=Vector3.new(1,1,1)
	p.BrickColor=BrickColor.new("Bright blue")
	p.Reflectance=.75
	p.CFrame=sp.CFrame+Vector3.new(0,4,0)
	p.Velocity=Vector3.new((math.random()-.5)*20,50,(math.random()-.5)*20)
	local sparkles=Instance.new("Sparkles")
	sparkles.SparkleColor=Color3.new(0,204/255,1)
	sparkles.Parent=p
	debris:AddItem(p,10)
	p.Parent=game.Workspace
end
