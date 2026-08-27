--Stickmasterluke


sp=script.Parent


extrahealth=100

local debris=game:GetService("Debris")
check=true

function onEquipped(mouse)
	if mouse~=nil then 
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local anim=sp:FindFirstChild("ButtonPress")
				if anim and t and h and h.Health>0 and check then
					mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
					check=false
					anim2=h:LoadAnimation(anim)
					anim2:Play()
					wait(.5)
					local s=sp.Handle:FindFirstChild("Sound")
					if s~=nil then
						s:Play()
					end
					wait(1.5)
					if h~=nil and h.Health>0 then
						local healthratio=h.Health/h.MaxHealth
						h.MaxHealth=h.MaxHealth+extrahealth
						h.Health=h.MaxHealth*healthratio
					end
					wait(.5)
					if mouse~=nil then
						mouse.Icon="rbxasset://textures\\GunCursor.png"
					end
					sp:remove()
					check=true
				end
			end
		end)
	end
end


sp.Equipped:connect(onEquipped)

