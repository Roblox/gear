--Made by Stickmasterluke


sp=script.Parent


local weaponevent=sp:WaitForChild("WeaponEvent")

firerate=.25

function onEquipped(mouse)
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			weaponevent:FireServer("Fire",mouse.Hit.p)
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
			wait(firerate)
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		end)
	end
end


sp.Equipped:connect(onEquipped)





