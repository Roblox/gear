--Stickmasterluke


sp=script.Parent

damage=36
stuck=false

sp.Touched:connect(function(hit)
	if hit and hit~=nil and sp~=nil and not stuck then
		local ct=sp:FindFirstChild("creator")
		if ct.Value~=nil and ct.Value.Character~=nil then
			if hit.Parent~=ct.Value.Character and hit.Name~="Handle" and hit.Name~="Effect" then
				stuck=true
				local w=Instance.new("Weld")
				w.Part0=hit
				w.Part1=sp
				w.C0=hit.CFrame:toObjectSpace(sp.CFrame)
				w.Parent=sp
				local bf=sp:FindFirstChild("BodyForce")
				if bf then
					bf:remove()
				end
				local sound=sp:FindFirstChild("Sound")
				if sound then
					sound:Play()
				end
				sp.Transparency=0
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
				local smoke=sp:FindFirstChild("Smoke")
				if smoke then
					smoke.Enabled=true
					wait(.1)
					if smoke then
						smoke.Enabled=false
					end
				end
				wait(5)
				if sp and sp~=nil and sp.Parent~=nil then
					sp:remove()
				end
			end
		end
	end
end)

while not stuck do
	wait(.5)
	local smoke=sp:FindFirstChild("Smoke")
	if not stuck and smoke then
		sp.Transparency=1
		smoke.Enabled=true
		wait(.3)
		if smoke then
			smoke.Enabled=false
		end
	end
	wait(1.5)
	local smoke=sp:FindFirstChild("Smoke")
	if not stuck and smoke then
		sp.Transparency=0
		smoke.Enabled=true
		wait(.3)
		if smoke then
			smoke.Enabled=false
		end
	end
end


