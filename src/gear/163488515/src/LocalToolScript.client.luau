--Made by Stickmasterluke


local sp=script.Parent


local handle=sp:WaitForChild("Handle")
local debounce=true


local modelassetid=160000787


function finddwarf()
	for _,v in ipairs(game.Workspace:GetChildren()) do
		if v and v.Name=="Grumpy" then
			local creator=v:FindFirstChild("creator")
			if creator and creator.Value==game.Players.LocalPlayer then
				return v
			end
		end
	end
end


function onequipped(mouse)
	mouse.Button1Down:connect(function()
		local plr=game.Players.LocalPlayer
		if plr and plr.Character and debounce then
			debounce=false
			if not finddwarf() then
				local grumpy=game:GetService("InsertService"):LoadAsset(modelassetid):GetChildren()[1]
				local creator=grumpy:WaitForChild("creator")
				creator.Value=plr
				grumpy.Parent=game.Workspace
				grumpy:MoveTo(handle.Position)
			end
			sp:remove()
			wait(1)
			debounce=true
		end
	end)
end

sp.Equipped:connect(onequipped)



