local sn = 1

local slides = {97698868,97701469, 97700362, 97701247 } 

function rotate()
	sn = sn + 1
	if sn > #slides then sn = 1 end
	script.Parent.Image = "http://www.roblox.com/asset/?id=" .. slides[sn]
end

for i=1,#slides do
	rotate() --preload all the images
end

script.Parent.MouseButton1Click:connect(rotate)