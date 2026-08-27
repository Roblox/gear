--Stickmasterluke


sp=script.Parent


dist=100

rate=1/30
local debris=game:GetService("Debris")
equipped=false

function onEquipped(mouse)
	equipped=true
	if mouse~=nil then 
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and sp.Enabled then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local animobject=sp:FindFirstChild("HoldToSky")
				if t and h and animobject then
					if h.Health>0 then
						sp.Enabled=false
						anim=h:LoadAnimation(animobject)
						if anim then
							anim:Play()
						end
						wait(.5)
						local r=Instance.new("Part")
						r.Transparency=.5
						r.Name="Rainarch"
						r.formFactor="Custom"
						r.Size=Vector3.new(.1,.1,.1)
						r.Anchored=true
						r.CanCollide=false
						local rm=Instance.new("SpecialMesh")
						rm.Scale=Vector3.new(0,0,0)
						rm.MeshId="http://www.roblox.com/asset/?id=74866958"
						rm.TextureId="http://www.roblox.com/asset/?id=74866919"
						rm.Parent=r
						debris:AddItem(r,60)
						r.Parent=game.Workspace
						local startpos=(t.CFrame*CFrame.new(0,-3,-10)).p
						local endpos=(CFrame.new(startpos)*CFrame.Angles(0,math.pi*2*math.random(),0)*CFrame.new(0,0,dist)).p
						local frames=4/rate
						for frame=1,frames do
							wait(rate)
							local percent=frame/frames
							r.CFrame=CFrame.new(startpos+(((endpos-startpos)*percent)*.5),endpos)*CFrame.Angles(0,math.pi/2,0)+Vector3.new(0,percent*dist*.22,0)
							rm.Scale=Vector3.new(percent*dist*.03,percent*dist*.025,1)
						end
						local p=Instance.new("Part")
						p.Name="Pot O Gold"
						p.Shape="Ball"
						p.Size=Vector3.new(3,3,3)
						p.Anchored=true
						p.BrickColor=BrickColor.new("Black")
						p.CFrame=CFrame.new(endpos+Vector3.new(0,1.5,0))
						local pm=Instance.new("SpecialMesh")
						pm.MeshId="http://www.roblox.com/asset/?id=24000971"
						pm.TextureId="http://www.roblox.com/asset/?id=24000962"
						pm.Scale=Vector3.new(2.5,2.5,2.5)
						pm.Parent=p
						local cs=Instance.new("Sound")
						cs.Name="CoinSound"
						cs.SoundId="http://www.roblox.com/asset/?id=19073176"
						cs.Looped=false
						cs.PlayOnRemove=false
						cs.Parent=p
						local ps=sp.Script:clone()
						ps.Parent=p
						ps.Disabled=false
						debris:AddItem(p,60)
						p.Parent=game.Workspace
						sp:remove()
					end
				end
			end
		end)
	end
end


sp.Equipped:connect(onEquipped)

