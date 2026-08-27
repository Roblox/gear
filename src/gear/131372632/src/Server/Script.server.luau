--Made by Stickmasterluke


sp=script.Parent

damage=100
rate=1/30

function waitfor(a,b)
	while not a:FindFirstChild(b) do
		a.ChildAdded:Wait()
	end
	return a:FindFirstChild(b)
end

local ct=waitfor(sp,"creator")
local debris=game:GetService("Debris")
check=false


sp.Touched:Connect(function(hit)
	if hit and hit and sp and (not check) then
		if ct.Value and ct.Value.Character then
			if hit.Parent~=ct.Value.Character and hit.Name~="Handle" and hit.Name~="Effect" and hit.Name~="Handle2" and hit.Parent.Name~="Ghost" then
				check=true
				local h=hit.Parent:FindFirstChildOfClass("Humanoid")
				local t=hit.Parent:FindFirstChild("HumanoidRootPart")
				if h and t and h.Health>0 then
					for i,v in ipairs(h:GetChildren()) do
						if v.Name=="creator" then
							v:Destroy()
						end
					end
					if ct then
						for i,v in ipairs(h:GetChildren()) do
							if v.Name=="creator" then
								v:Destroy()
							end
						end
						local clonect=ct:Clone()
						debris:AddItem(clonect,1)
						clonect.Parent=h
					end
					h:TakeDamage(damage)
					if h.Health<=0 then

						local ghost=game:GetService("InsertService"):LoadAsset(94251705):GetChildren()[1]
						--local ghost=game.Lighting.Ghost:clone()
						if ct then
							local clonect=ct:Clone()
							clonect.Parent=ghost
						end
						if h and h.Parent then
							for i,v in ipairs(h.Parent:GetChildren()) do
								if v:IsA("CharacterMesh") then
									local vclone=v:Clone()
									vclone.BaseTextureId=0
									vclone.OverlayTextureId=0
									vclone.Parent=ghost
								elseif v:IsA("Accoutrement") then
									local vclone=v:Clone()
									local hndl=vclone:FindFirstChild("Handle")
									if hndl then
										hndl.BrickColor=BrickColor.new("Light stone grey")
										hndl.Transparency=.5
										hndl.Reflectance=0
										for i2,v2 in ipairs(hndl:GetChildren()) do
											if v2.className=="SpecialMesh" then
												v2.TextureId=""
											end
										end
									end

									vclone.Parent=ghost
								end
							end
						end

						sp.Transparency=1
						sp.Anchored=true
						local p=Instance.new("Part")
						p.Transparency=.5
						p.Name="Effect"
						p.formFactor="Custom"
						p.BrickColor=BrickColor.new("Light stone grey")
						p.Anchored=true
						p.CanCollide=false
						p.Size=Vector3.new(.2,.2,.2)
						p.TopSurface="Smooth"
						p.BottomSurface="Smooth"
						p.CFrame=sp.CFrame
						local m=Instance.new("SpecialMesh")
						m.MeshType="Sphere"
						m.Parent=p
						debris:AddItem(p,4)
						p.Parent=workspace
						local frames=.25/rate
						for frame=1,frames do
							local percent=frame/frames
							if m then
								m.Scale=Vector3.new(5,5,5)*percent*12
							end
							wait(rate)
						end
						local frames=1/rate
						for frame=1,frames do
							local percent=frame/frames
							if m then
								m.Scale=Vector3.new(5,5,5)*(.2+((1-percent)*.8))*12
							end
							if p then
								p.Transparency=.5-(percent*.25)
							end
							wait(rate)
						end
						if p then
							p:Destroy()
							if ct and sp then
								if ct.Value then
									if ct.Value.Character then
										local t=ct.Value.Character:FindFirstChild("HumanoidRootPart")
										if t then
											local fire=sp:FindFirstChild("Fire")
											if fire then
												fire.Color=Color3.new(.5,1,1)
											end
											local od=(t.Position-sp.Position).magnitude
											local frames=1/rate
											for frame=1,frames do
												if t and sp then
													local vec=(sp.Position-t.Position).unit
													sp.CFrame=CFrame.new(t.Position+vec*((1-(frame/frames))*od))
													wait(rate)
												end
											end
											if t and sp then
												debris:AddItem(ghost,40)
												ghost.Parent= workspace
												ghost:MoveTo(sp.Position)
											end
										end
									end
								end
							end
						end
					end
				end
				if sp and sp and sp.Parent then
					sp:Destroy()
				end
			end
		end
	end
end)

wait(20)
sp:Destroy()


