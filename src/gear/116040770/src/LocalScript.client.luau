--Stickmasterluke


sp=script.Parent


cooldown=.35

lightontexture=115984370
lightofftexture=115955343

local weld=sp:WaitForChild("Motor")
local lp=sp:WaitForChild("LightPart")
local handle=sp:WaitForChild("Handle")
local spotlight=lp:WaitForChild("SpotLight")
local spotlight2=lp:WaitForChild("SpotLight2")
local mesh=handle:WaitForChild("Mesh")
local sound=handle:WaitForChild("Sound")
lastclick=0




sp.Equipped:connect(function(mouse)
	equipped=true
	if mouse~=nil then
		themouse=mouse
		mouse.Button1Down:connect(function()
			if lastclick+cooldown<tick() then
				spotlight.Enabled=not spotlight.Enabled
				spotlight2.Enabled=spotlight.Enabled
				mesh.TextureId="http://www.roblox.com/asset?id="..tostring((spotlight.Enabled and lightontexture) or lightofftexture)
				sound:Play()
				lastclick=tick()
			end
		end)
	end
	if weld~=nil then
		weld.Parent=sp
	end
	while equipped and sp.Parent~=nil do
		local head=sp.Parent:FindFirstChild("Head")
		if spotlight.Enabled and themouse and handle and weld and head then
			local vec=themouse.Hit.p-head.Position
			local pos=(handle.CFrame*CFrame.new(0,0,-1)).p
			local cf=CFrame.new(pos,pos+vec)
			--lp.CFrame=cf
			weld.C0=handle.CFrame:toObjectSpace(cf)
		end
		wait()
	end
end)

sp.Unequipped:connect(function()
	if weld~=nil then
		weld.Parent=sp
	end
	equipped=false
end)

















