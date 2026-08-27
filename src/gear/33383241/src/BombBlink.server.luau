local Mesh = script.Parent.Mesh
local blink = false

while true do

	blink = not blink
	if blink then
		Mesh.TextureId = "http://www.roblox.com/asset/?id=28512114"
	else
		Mesh.TextureId = "http://www.roblox.com/asset/?id=33378623"
	end
	wait(2)

end
