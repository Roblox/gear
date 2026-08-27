--Stickmasterluke


sp=script.Parent

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		wait()
	end
	return a:FindFirstChild(b)
end

wait()

damagetag=waitfor(sp,"DamageTag")
ct=waitfor(sp,"creator")

local weld=sp:FindFirstChild("Weld")
if weld~=nil then
	if weld.Part0~=nil then
		hit=weld.Part0
		local sound=sp:FindFirstChild("Sound")
		if sound~=nil then
			sound:Play()
		end
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
					h:TakeDamage(damagetag.Value)
				end
			end
		end
	end
end



