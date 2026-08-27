local i = 0
local delta = 0
while true do
	if i <= 0 then delta = .1 end
	if i >= 1 then delta = -.1 end
	script.Parent.RisingBlade.Mesh.VertexColor = Vector3.new(1-i,1-i,1)
	wait(.1)
	i = i + delta
end
