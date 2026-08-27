--Stickmasterluke



sp=script.Parent

local bv=sp:WaitForChild("BodyVelocity")


wait(.5+math.random())
bv.velocity=bv.velocity*Vector3.new(1,0,1)
for _=1,100 do
	bv.velocity=bv.velocity+Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*5
	wait(.5+math.random())
end

sp:remove()








