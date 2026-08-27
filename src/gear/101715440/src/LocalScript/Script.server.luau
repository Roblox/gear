--Stickmasterluke


sp=script.Parent

damage=19

poisondamage=46
poisontime=7

wait()

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
				end
			end
		end
		local stingspersecond=1
		local stings=poisontime*stingspersecond
		for i=1,stings do
			wait(1/stingspersecond)
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
						h:TakeDamage(poisondamage/stings)
					end
				end
			end
		end
		local f=sp:FindFirstChild("Fire")
		if f~=nil then
			f.Enabled=false
		end
	end
else
	sp.Touched:connect(function(hit)
		if hit~=nil and not check then
			local ct=sp:FindFirstChild("creator")
			if ct.Value~=nil and ct.Value.Character~=nil then
				if hit.Parent~=ct.Value.Character and hit.Name~="Handle" and hit.Name~="Effect" then
					check=true
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
					end
				end
			end
		end
	end)
end



