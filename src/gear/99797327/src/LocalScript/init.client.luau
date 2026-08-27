--Made by Stickmasterluke


sp=script.Parent


cooldown=10

debris=game:GetService("Debris")
check=true

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end

lastuse=waitfor(sp,"LastUse")

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	if mouse~=nil and plr~=nil then
		if tick()-cooldown<lastuse.Value then
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
			sp.Handle.Transparency=1
			wait(lastuse.Value-(tick()-cooldown))
			mouse.Icon="rbxasset://textures\\GunCursor.png"
			sp.Handle.Transparency=0
		else
			mouse.Icon="rbxasset://textures\\GunCursor.png"
			sp.Handle.Transparency=0
		end
		mouse.Button1Down:connect(function()
			if tick()-cooldown>lastuse.Value and mouse.Target and mouse.Target~=nil and mouse.Hit then
				local chr=sp.Parent
				if chr and check then
					local h=chr:FindFirstChild("Humanoid")
					if h and h.Health>0 then
						check=false
						lastuse.Value=tick()
						mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
						sp.Handle.Transparency=1
						local sound=sp.Handle:FindFirstChild("Sound")
						if sound~=nil then
							sound:Play()
						end

						local menorah=sp.Handle:clone()
						menorah.Name="Menorah"
						menorah.Friction=1
						menorah.Elasticity=0
						menorah.Transparency=0
						menorah.CFrame=menorah.CFrame+Vector3.new(0,-1,0)
						menorah.CanCollide=true
						menorah.Velocity=Vector3.new(0,0,0)
						menorah.RotVelocity=Vector3.new(0,0,0)

						local gyro=Instance.new("BodyGyro")		--this will keep the thing standing upright.
						gyro.Parent=menorah

						local CloneScript=script.Script:clone()
						CloneScript.Parent=menorah
						CloneScript.Disabled=false

						local sparkles=menorah:FindFirstChild("Sparkles")
						if sparkles then
							sparkles.Enabled=true
						end

						debris:AddItem(menorah,10)
						menorah.Parent=game.Workspace

						wait(cooldown)
						sp.Handle.Transparency=0
						mouse.Icon="rbxasset://textures\\GunCursor.png"
						check=true
					end
				end
			end
		end)
	end
end

function onUnequipped()
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)


