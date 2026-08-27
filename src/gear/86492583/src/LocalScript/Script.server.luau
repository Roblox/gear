--Stickmasterluke


sp=script.Parent

damage=27

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
				end
			end
		end
	end
end



