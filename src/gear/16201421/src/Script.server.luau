bin = script.Parent
resetted = false

function dis(part)
	while (part.Transparency < 1) do
		part.Transparency = part.Transparency+0.1
		wait()
	end
	part:remove()
end
function ref(part)
	while (part.Reflectance < 1) do
		part.Reflectance = part.Reflectance+0.1
		wait()
	end
	part:remove()
end
function onButton1Down(mouse)
	resetted = true
	local player = game.Players.LocalPlayer
	local char = player.Character
	if (char ~= nil) then
		local p = char:GetChildren()
		for i=1,#p do
			if (p[i].className == "Part") then
				local cA = coroutine.create(function() dis(p[i]) end)
				local cB = coroutine.create(function() ref(p[i]) end)
				coroutine.resume(cA)
				coroutine.resume(cB)
			end
		end
	end
end

function onSelected(mouse)
        print("Reset Selected");
	if (resetted == true) then return end
	mouse.Button1Down:connect(onButton1Down)
end

bin.Selected:connect(onSelected)