--Made by Stickmasterluke


sp=script.Parent
local Handle = sp:WaitForChild('Nerf Shoes'):WaitForChild('Handle')
speedboost=1		--100% speed bonus
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
			weld.C0=CFrame.new(0,-3.5,0)*CFrame.Angles(math.pi/4,0,0)
			weld.Parent=smokepart
			smokepart.Parent=sp
			smoke=Instance.new("Smoke")
			smoke.Enabled=t.Velocity.magnitude>speedforsmoke
			smoke.RiseVelocity=2
			smoke.Opacity=.25
			smoke.Size=.5
			smoke.Parent=smokepart
			LeftShoe= Handle:Clone()
			RightShoe= Handle:Clone()
			Handle.Transparency = 1
			if sp:FindFirstChild('Left Leg') then
				weld=Instance.new("Weld")
				weld.Name="leftShoeWeld"
				weld.Part0=sp['Left Leg']
				weld.Part1=LeftShoe
				weld.C0=CFrame.new(Vector3.new(0,-.575,-.4))*CFrame.Angles(0,0,0)
				weld.Parent=sp['Left Leg']
				LeftShoe.Parent = sp['Left Leg']
			end
			if sp:FindFirstChild('Right Leg') then
				weld=Instance.new("Weld")
				weld.Name="rightShoeWeld"
				weld.Part0=sp['Right Leg']
				weld.Part1=RightShoe
				weld.C0=CFrame.new(Vector3.new(0,-.575,-.4))*CFrame.Angles(0,0,0)
				weld.Parent=sp['Right Leg']
				RightShoe.Parent = sp['Right Leg']
			end
			h.Running:connect(function(speed)
				if smoke and smoke~=nil then
					smoke.Enabled=speed>speedforsmoke
				end
			end)
		end
	end
	while tool~=nil and tool.Parent==sp and h~=nil do
		sp.ChildRemoved:wait()
	end
	local h=sp:FindFirstChild("Humanoid")
	if h~=nil then
		h.WalkSpeed=16
	end
end

if smokepart~=nil then
	smokepart:remove()
end
if LeftShoe then
	LeftShoe:remove()
end
if RightShoe then
	RightShoe:remove()
end
Handle.Transparency = 0
script:remove()


