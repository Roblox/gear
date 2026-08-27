--Stickmasterluke


sp=script.Parent

damage=55

sp.Touched:connect(function(hit)
	if hit and hit~=nil and sp~=nil then
		local ct=sp:FindFirstChild("creator")
		if ct.Value~=nil and ct.Value.Character~=nil then
			if hit.Parent~=ct.Value.Character and hit.Name~="Handle" and hit.Name~="Effect" then
				local h=hit.Parent:FindFirstChild("Humanoid")
				local t=hit.Parent:FindFirstChild("Torso")
				damage=damage*.5
				if h~=nil and t~=nil and h.Health>0 then
					for i,v in ipairs(h:GetChildren()) do
						if v.Name=="creator" then
							v:remove()
						end
					end
					ct:clone().Parent=h
					h:TakeDamage(damage)
				end
				f=sp:FindFirstChild("Fire")
				if f and f~=nil and f.Parent==sp then
					f.Enabled=false
				end
				wait(7)
				if sp and sp~=nil and sp.Parent~=nil then
					sp:remove()
				end
			end
		end
	end
end)


