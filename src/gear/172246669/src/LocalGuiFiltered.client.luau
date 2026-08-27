--Made by Stickmasterluke


sp=script.Parent


local weaponevent=sp:WaitForChild("WeaponEvent")

function onEquippedLocal(mouse)
	if mouse then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			weaponevent:FireServer("Fire",mouse.Hit.p)
		end)
	end
end

sp.Equipped:connect(onEquippedLocal)




