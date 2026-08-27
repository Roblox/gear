--Made by Stickmasterluke


sp=script.Parent

speedboost=.95		--95% speed bonus
speedforsmoke=10	--smoke apears when character running >= 10 studs/second.

function waitfor(a,b,c)
	local c=c or 5*60
	local d=tick()+c
	while a:FindFirstChild(b)==nil and tick()<=d do
		wait()
	end
	return a:FindFirstChild(b)
end

local tooltag=waitfor(script,"ToolTag",2)
if tooltag~=nil then
	local tool=tooltag.Value
	local h=sp:FindFirstChild("Humanoid")
	if h~=nil then
		h.WalkSpeed=16+16*speedboost
		local t=sp:FindFirstChild("Torso")
		if t~=nil then
			smokepart=Instance.new("Part")
			smokepart.FormFactor="Custom"
			smokepart.Size=Vector3.new(0,0,0)
			smokepart.TopSurface="Smooth"
			smokepart.BottomSurface="Smooth"
			smokepart.CanCollide=false
			smokepart.Transparency=1
			local weld=Instance.new("Weld")
			weld.Name="SmokePartWeld"
			weld.Part0=t
			weld.Part1=smokepart
			weld.C0=CFrame.new(0,0,1.5)*CFrame.Angles(math.pi/2,0,0)
			weld.Parent=smokepart
			smokepart.Parent=sp
			smoke=Instance.new("Fire")
			smoke.Enabled=t.Velocity.magnitude>speedforsmoke
			smoke.Size=5
			smoke.Heat=0
			smoke.Color=Color3.new(0,.95,1)
			smoke.SecondaryColor=Color3.new(0,.95,1)
			smoke.Parent=smokepart
			delay(0,function()
				while smoke and smoke~=nil do
					smoke.Enabled=t.Velocity.magnitude>speedforsmoke
					wait(.2)
				end
			end)
		end
	end
	while tool~=nil and tool.Parent==sp and h~=nil do
		sp.ChildRemoved:wait()
	end
	if smoke then
		smoke:remove()
		smoke=nil
	end
	local h=sp:FindFirstChild("Humanoid")
	if h~=nil then
		h.WalkSpeed=16
	end
end

if smokepart~=nil then
	smokepart:remove()
end
script:remove()


