local Cursors = {
"http://www.roblox.com/asset/?id=90875398",--50912619", -- red -- change the cursors
"http://www.roblox.com/asset/?id=50912641", -- blue
"http://www.roblox.com/asset/?id=90875896", -- purple
Reloading = "http://www.roblox.com/asset/?id=90875896", }--50911776", }

local Tool = script.Parent

script.Parent.Equipped:Connect(function(mouse)
	Equipped = true
	
	mouse.Button1Down:Connect(function()
		script.Parent.RemoteEvent:FireServer('ClickDown',mouse.Hit)
	end)
	mouse.Button1Up:connect(function()
		script.Parent.RemoteEvent:FireServer('ClickUp')
	end)
	
	mouse.Icon = Cursors[1]
	Tool.Reloading.Changed:Connect(function(val)
		if mouse and Equipped then
			if val then
				mouse.Icon = Cursors.Reloading
			else
				mouse.Icon = Cursors[1]
			end
		end
	end)
end)

script.Parent.Unequipped:Connect(function()
	Equipped = false
end)