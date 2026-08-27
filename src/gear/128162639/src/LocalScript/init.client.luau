--Made by Stickmasterluke


sp=script.Parent


cooldown=2
numberemeralds=7
throwspeed=75


check=true
down=false
equipped=false
vec=Vector3.new(0,0,0)
debris=game:GetService("Debris")

local waveanimation=sp:WaitForChild("WaveAnim")
local emeraldscript=script:WaitForChild("EmeraldScript")


function onEquipped(mouse)
	if mouse~=nil then
		equipped=true
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			if mouse~=nil and check then
				check=false
				down=true
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				local h=sp.Parent:FindFirstChild("Humanoid")
				local t=sp.Parent:FindFirstChild("Torso")
				if h~=nil and h.Health>0 and t~=nil then
					waveAnim=h:LoadAnimation(waveanimation)
					if waveAnim then
						waveAnim:Play(nil,nil,2)
						delay(.5,function()
							if waveAnim then
								waveAnim:Stop()
							end
						end)
					end
					local summonthem=true
					if emeralds then
						for i,v in ipairs(emeralds) do
							if v and v.Parent==game.Workspace and v:FindFirstChild("Motor") then
								summonthem=false
							end
						end
					end
					if summonthem then
						local sound=sp.Handle:FindFirstChild("SummonSound")
						if sound then
							sound.Pitch=2
							sound:Play()
						end
						emeralds={}
						for i=1,numberemeralds do
							local p=Instance.new("Part")
							p.Name="Emerald"
							p.Transparency=.3
							p.Reflectance=.3
							p.BrickColor=BrickColor.new("Bright green")
							p.TopSurface="Smooth"
							p.BottomSurface="Smooth"
							p.Anchored=false
							p.CanCollide=true
							p.Locked=true
							p.formFactor="Custom"
							p.Size=Vector3.new(2,1,2)
							p.Elasticity=0
							p.Friction=1
							
							local fire=Instance.new("Fire")
							fire.Size=6
							fire.Heat=-20
							fire.Color=Color3.new(0,1,0)
							fire.SecondaryColor=Color3.new(1,1,1)
							fire.Enabled=true
							delay(.5,function()
								if fire then
									fire.Enabled=false
								end
							end)
							fire.Parent=p
		
							local m=Instance.new("SpecialMesh")
							m.MeshId="http://www.roblox.com/Asset/?id=9756362"
							m.Scale=Vector3.new(2,1,2)
							m.Parent=p
							
							local ct=Instance.new("ObjectValue")
							ct.Name="creator"
							ct.Value=game.Players.LocalPlayer
							ct.Parent=p
							
							local s=emeraldscript:clone()
							s.Parent=p
							s.Disabled=false
							
							local sound=Instance.new("Sound")
							sound.SoundId="http://www.roblox.com/Asset?ID=87015121"
							sound.Pitch=1+math.random()*.5
							sound.Volume=.5
							sound.Parent=p
							
							local cf=CFrame.new(0,0,0)*CFrame.Angles(0,((i-1)/(numberemeralds-1)-.5)*math.pi*.9,0)*CFrame.new(0,0,-5)*CFrame.Angles(0,math.pi*.5,math.pi*.5)*CFrame.Angles(0,math.pi*.25,0)
							p.CFrame=t.CFrame*cf
							local w=Instance.new("Motor")
							w.Part0=t
							w.Part1=p
							w.C0=cf
							w.Parent=p
							
							debris:AddItem(p,20)
							table.insert(emeralds,p)
							p.Parent=game.Workspace
						end
					else
						local sound=sp.Handle:FindFirstChild("SummonSound")
						if sound then
							sound.Pitch=4
							sound:Play()
						end
						for i,v in pairs(emeralds) do
							if v and v.Parent==game.Workspace then
								local bf=Instance.new("BodyForce")
								bf.force=Vector3.new(0,196.2*v:GetMass(),0)
								bf.Parent=v
								local weld=v:FindFirstChild("Motor")
								if weld then
									if weld.Part0 then
										vec=(weld.Part1.Position-weld.Part0.Position).unit
									end
									weld:remove()
								end
								v.CFrame=(v.CFrame+vec*3)*CFrame.Angles(0,math.pi*.25,0)*CFrame.Angles(math.pi*.5,0,0)
								v.Velocity=vec*throwspeed
								v.RotVelocity=Vector3.new(0,50,0)
								local fire=v:FindFirstChild("Fire")
								if fire then
									fire.Heat=20
									fire.Enabled=true
									delay(.5,function()
										if fire then
											fire.Enabled=false
										end
									end)
								end
							end
						end
						emeralds=nil
					end
					
					wait(cooldown)
					if mouse~=nil then
						mouse.Icon="rbxasset://textures\\GunCursor.png"
					end
				end
				check=true
			end
		end)
		mouse.Button1Up:connect(function()
			down=false
		end)
	end
end

function onUnequipped()
	equipped=false
	if waveAnim then
		waveAnim:Stop()
	end
end

sp.Unequipped:connect(onUnequipped)
sp.Equipped:connect(onEquipped)
