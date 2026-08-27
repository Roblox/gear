--Made by Stickmasterluke

cursors={
"http://www.roblox.com/asset/?id=50912619",				--red			--change the cursors
"http://www.roblox.com/asset/?id=50912641",				--blue
"http://www.roblox.com/asset/?id=50911776",				--purple
reloading="http://www.roblox.com/asset/?id=50911776",
}
clipsize=45
equipped=false

sp=script.Parent
plr=game.Players.localPlayer

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

reload=waitfor(sp,"Reload")
gui=waitfor(sp,"PlasmaAssaultGui")
down=waitfor(sp,"Down")
ammo=sp:FindFirstChild("Ammo")
clips=sp:FindFirstChild("Clips")

function updategui()
	if equipped then
		local plr=game.Players.localPlayer
		if plr~=nil then
			if ammo==nil then
				gui.Bar.GunLabel.Text=sp.Name
				gui.Bar.AmmoLabel.Text=""
				gui.Bar.Fill.Size=UDim2.new(-1,0,.8,0)
			elseif clips==nil then
				gui.Bar.GunLabel.Text=sp.Name
				gui.Bar.AmmoLabel.Text=tostring(ammo.Value).."/"..tostring(clipsize)
				gui.Bar.Fill.Size=UDim2.new(-1*ammo.Value/clipsize,0,.8,0)
				gui.Bar.Fill.Visible=true
			else
				gui.Bar.GunLabel.Text=sp.Name
				gui.Bar.AmmoLabel.Text=tostring(ammo.Value).."/"..tostring(clipsize).."   "..tostring(clips.Value)
				gui.Bar.Fill.Size=UDim2.new(-1*ammo.Value/clipsize,0,.8,0)
				gui.Bar.Fill.Visible=true
			end
			if sp.Reloading.Value then
				gui.Bar.AmmoLabel.Text="Reloading"
			end
		end
	end
end

function onEquipped(mouse)
	if mouse~=nil then
		equipped=true
		local plr=game.Players.LocalPlayer
		if plr~=nil then
			local plrgui=plr:FindFirstChild("PlayerGui")
			if plrgui~=nil then
				gui.Parent=plrgui
			end
			mouse.Button1Down:connect(function()
				if not sp.Down.Value then
					sp.Aim.Value=mouse.Hit.p
					sp.Down.Value=true
					while sp.Down.Value do
						sp.Aim.Value=mouse.Hit.p
						wait()
					end
				end
			end)
			mouse.Button1Up:connect(function()
				sp.Down.Value=false
			end)
			mouse.KeyDown:connect(function(key)
				if string.byte(key)==string.byte("r") then
					reload.Value=not reload.Value
				end
			end)
			mouse.Icon=cursors[1]
			sp.Reloading.Changed:connect(function(val)
				if mouse~=nil and equipped then
					if val then
						mouse.Icon=cursors.reloading
					else
						mouse.Icon=cursors[1]
					end
					local plr=game.Players.localPlayer
					if plr~=nil then
						local gui=plr.PlayerGui:FindFirstChild("AmmoHud")
						if gui~=nil then
							updategui()
							if sp.Reloading.Value then
								gui.Bar.AmmoLabel.Text="Reloading"
							end
						end
					end
				end
			end)
			updategui()
		end
	end
end

function onUnequipped()
	gui.Parent=sp
	equipped=false
	local plr=game.Players.localPlayer
	if plr~=nil then
		local gui=plr.PlayerGui:FindFirstChild("AmmoHud")
		if gui~=nil then
			gui.Bar.GunLabel.Text=""
			gui.Bar.AmmoLabel.Text=""
			gui.Bar.Fill.Visible=false
		end
	end
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

if ammo~=nil then
	ammo.Changed:connect(function()
		updategui()
	end)
	if clips~=nil then
		clips.Changed:connect(function()
			updategui()
		end)
	end
end

while sp:FindFirstChild("Reloading")==nil do
	wait(1)
end
sp.Reloading.Changed:connect(function()
	updategui()
end)




