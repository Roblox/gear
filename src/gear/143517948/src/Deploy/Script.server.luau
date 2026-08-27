--Made by Stickmasterluke
--Fixed by TakeoHonorable

sp=script.Parent


scale=.5
jumpcooldown=1
color=BrickColor.new("Bright red")
transparency=.5
rate=1/30

local lastjump=tick()
local debris=game:GetService("Debris")
local cf=CFrame.new()
local mesh=sp:WaitForChild("Mesh")

function waitfor(a,b,c)
	local c=c or 5*60
	local d=tick()+c
	while a:FindFirstChild(b)==nil and tick()<=d do
		wait()
	end
	return a:FindFirstChild(b)
end

wait(3)

local sbp=Instance.new("BodyPosition")
sbp.maxForce=Vector3.new(1,1,1)*(10^7)
sbp.position=sp.Position+Vector3.new(0,15,0)
sbp.Parent=sp

local frames=1/rate
for frame=1,frames do
	local newscale=(1+(5*(frame/frames)))
	sp.Size=Vector3.new(2,2,2)*newscale
	mesh.Scale=Vector3.new(1,1,1)*newscale
	wait(rate)
end

local ct=waitfor(sp,"creator",5)
if ct then
	if ct.Value and ct.Value.Character then
		gui=sp:FindFirstChild("JumpPointGui")
		if gui then
			local jumpbutton=gui:FindFirstChild("JumpButton")
			local plrgui=ct.Value:FindFirstChild("PlayerGui")
			if plrgui and jumpbutton then
				gui.Parent=plrgui
				jumpbutton.MouseButton1Down:Connect(function()
					if ct and ct.Value and ct.Value.Character and tick()-lastjump>jumpcooldown then
						local torso=ct.Value.Character:FindFirstChild("HumanoidRootPart")
						local humanoid=ct.Value.Character:FindFirstChildOfClass("Humanoid")
						if torso and humanoid and humanoid.Health>0 then
							local sound=sp:FindFirstChild("WarpSound")
							if sound then
								sound:Play()
							end
							local tcf=torso.CFrame
						
							local p=Instance.new("Part")
							p.BrickColor=color
							p.FormFactor="Custom"
							p.Size=Vector3.new(0,0,0)
							p.Anchored=true
							p.CanCollide=false
							p.TopSurface="Smooth"
							p.BottomSurface="Smooth"
							p.Material = Enum.Material.Neon
							p.Name="Effect"
							local m=Instance.new("SpecialMesh")
							m.MeshType="Sphere"
							m.Parent=p
							debris:AddItem(p,5)
							p.CFrame=tcf
							p.Parent=game.Workspace

							ct.Value.Character:MoveTo(sp.Position)

							local p2=Instance.new("Part")
							p2.BrickColor=color
							p2.FormFactor="Custom"
							p2.Size=Vector3.new(0,0,0)
							p2.Anchored=true
							p2.CanCollide=false
							p2.TopSurface="Smooth"
							p2.BottomSurface="Smooth"
							p2.Material = Enum.Material.Neon
							p2.Name="Effect"
							local m2=Instance.new("SpecialMesh")
							m2.MeshType="Sphere"
							m2.Parent=p2
							debris:AddItem(p2,5)
							p2.CFrame=torso.CFrame
							p2.Parent=game.Workspace

							delay(0,function()
								frames=.5/rate
								for frame=1,frames do
									local percent=frame/frames
									m.Scale=Vector3.new(15,15,15)*(1-percent)*8
									p.Transparency=percent
									m2.Scale=Vector3.new(15,15,15)*percent*8
									p2.Transparency=percent
									wait(rate)
								end
							end)
							lastjump=tick()
						end
					end
				end)
			end
		end
		while ct and ct.Value and ct.Value.Character and ct.Value.Character:FindFirstChildOfClass("Humanoid") and ct.Value.Character:FindFirstChildOfClass("Humanoid").Health>0 and gui and gui.Parent do
			wait(.15)
		end
	end
end

if gui then
	gui:Destroy()
end
local e=Instance.new("Explosion")
e.BlastPressure=0
e.Position=sp.Position
e.Parent=game.Workspace
									--Maybe add a sound
wait(.5)
sp:Destroy()









