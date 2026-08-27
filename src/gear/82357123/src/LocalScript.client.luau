--Made by Stickmasterluke


sp=script.Parent


function updateicon()
	if themouse~=nil then
		if sp.Enabled then
			themouse.Icon="rbxasset://textures\\GunCursor.png"
		else
			themouse.Icon="rbxasset://textures\\GunWaitCursor.png"
		end
	end
end

function onEquipped(mouse)
	if mouse~=nil then
		themouse=mouse
	end
	updateicon()
end


sp.Equipped:connect(onEquipped)
sp.Changed:connect(updateicon)


