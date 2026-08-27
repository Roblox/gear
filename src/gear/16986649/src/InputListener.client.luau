--[[
	Listens for input, ya know
--]]

script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function()
		script.Parent.Fire:FireServer(mouse.Hit.p)
	end)
end)