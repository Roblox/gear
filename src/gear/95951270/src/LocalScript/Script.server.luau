--Stickmasterluke


sp=script.Parent

damage=36

wait(.1)

local weld=sp:FindFirstChild("Weld")
if weld~=nil then
	if weld.Part0~=nil then
		hit=weld.Part0
		local sound=sp:FindFirstChild("Sound")
		if sound~=nil then
			sound:Play()
		end
		local ct=sp:FindFirstChild("creator")
		if ct.Value~=nil and ct.Value.Character~=nil then
			if hit.Parent~=ct.Value.Character and hit.Name~="Handle" and hit.Name~="Effect" then
				local h=hit.Parent:FindFirstChild("Humanoid")
				local t=hit.Parent:FindFirstChild("Torso")
				if h~=nil and t~=nil and h.Health>0 then
					for i,v in ipairs(h:GetChildren()) do
						if v.Name=="creator" then
							v:remove()
						end
					end
					ct:clone().Parent=h
					h:TakeDamage(damage)
					if h.Health<=0 then
						for i,v in ipairs(h.Parent:GetChildren()) do
							if v.className=="Shirt" or v.className=="Pants" or v.className=="CharacterMesh" then
								v:remove()
							end
						end
						local head=h.Parent:FindFirstChild("Head")
						if head~=nil then
							for i,v in ipairs(head:GetChildren()) do
								v:remove()
							end
							local m=Instance.new("SpecialMesh")
							m.MeshId="http://www.roblox.com/asset/?id=36869983"
							m.TextureId="http://www.roblox.com/asset/?id=36869975"
							m.Scale=Vector3.new(.95,.9,.95)
							m.Parent=head
						end
						local t=h.Parent:FindFirstChild("Torso")
						if t~=nil then
							for i,v in ipairs(t:GetChildren()) do
								v:remove()
							end
							local m=Instance.new("SpecialMesh")
							m.MeshId="http://www.roblox.com/asset/?id=36780113"
							m.TextureId="http://www.roblox.com/asset/?id=36780292"
							m.Scale=Vector3.new(1,1,1)
							m.Parent=t
						end
						local la=h.Parent:FindFirstChild("Left Arm")
						if la~=nil then
							for i,v in ipairs(la:GetChildren()) do
								v:remove()
							end
							local m=Instance.new("SpecialMesh")
							m.MeshId="http://www.roblox.com/asset/?id=36780032"
							m.TextureId="http://www.roblox.com/asset/?id=36780292"
							m.Scale=Vector3.new(1,1,1)
							m.Parent=la
						end
						local ra=h.Parent:FindFirstChild("Right Arm")
						if ra~=nil then
							for i,v in ipairs(ra:GetChildren()) do
								v:remove()
							end
							local m=Instance.new("SpecialMesh")
							m.MeshId="http://www.roblox.com/asset/?id=36780156"
							m.TextureId="http://www.roblox.com/asset/?id=36780292"
							m.Scale=Vector3.new(1,1,1)
							m.Parent=ra
						end
						local ll=h.Parent:FindFirstChild("Left Leg")
						if ll~=nil then
							for i,v in ipairs(ll:GetChildren()) do
								v:remove()
							end
							local m=Instance.new("SpecialMesh")
							m.MeshId="http://www.roblox.com/asset/?id=36780079"
							m.TextureId="http://www.roblox.com/asset/?id=36780292"
							m.Scale=Vector3.new(1,1,1)
							m.Parent=ll
						end
						local rl=h.Parent:FindFirstChild("Right Leg")
						if rl~=nil then
							for i,v in ipairs(rl:GetChildren()) do
								v:remove()
							end
							local m=Instance.new("SpecialMesh")
							m.MeshId="http://www.roblox.com/asset/?id=36780195"
							m.TextureId="http://www.roblox.com/asset/?id=36780292"
							m.Scale=Vector3.new(1,1,1)
							m.Parent=rl
						end
					end
				end
			end
		end
	end
end



