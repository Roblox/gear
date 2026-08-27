--Stickmasterluke


sp=script.Parent



fireflies=7



local debris=game:GetService("Debris")
check=true

local handle=sp:WaitForChild("Handle")
local handle2=sp:WaitForChild("Handle2")
local weld=sp:WaitForChild("Motor")
local animation=sp:WaitForChild("Animation")
local sound=handle:WaitForChild("Sound")
local fireflyscript=script:WaitForChild("FireflyScript")
local light=handle:FindFirstChild("PointLight")

function createfirefly()
	local p=Instance.new("Part")
	p.Name="Firefly"
	p.formFactor="Custom"
	p.Friction=0
	p.Elasticity=0
	p.Size=Vector3.new(.1,.1,.1)
	p.CFrame=handle.CFrame*CFrame.new(math.random()-.5,1+math.random(),math.random()-.5)
	p.Transparency=1
	p.CanCollide=true
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	local sb=Instance.new("SelectionBox")
	sb.Color=BrickColor.new("New Yeller")
	sb.Adornee=p
	sb.Parent=p
	local bf=Instance.new("BodyVelocity")
	bf.maxForce=Vector3.new(1,1,1)*10^2
	bf.velocity=Vector3.new(math.random()-.5,1,math.random()-.5)*4
	bf.Parent=p
	local bf=Instance.new("BodyAngularVelocity")
	bf.maxTorque=Vector3.new(1,1,1)*10^2
	bf.angularvelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*20
	bf.Parent=p
	local pl=Instance.new("PointLight")
	pl.Color=light.Color
	pl.Range=math.random(4,8)
	pl.Brightness=1
	pl.Parent=p
	local s=fireflyscript:clone()
	s.Disabled=false
	s.Parent=p
	debris:AddItem(p,math.random(20,30))
	p.Parent=game.Workspace
	return p
end

sp.Equipped:connect(function(mouse)
	equipped=true
	if mouse~=nil then 
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local t=sp.Parent:FindFirstChild("Torso")
			local h=sp.Parent:FindFirstChild("Humanoid")
			if t and h and h.Health>0 and equipped and check  then
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				check=false
				if anim then
					anim:Stop()
				end
				anim=h:LoadAnimation(animation)
				if anim then
					anim:Play()
				end
				wait(1)
				sound:Play()
				wait(1.7)
				handle2.Transparency=1
				local fakelid=handle2:clone()
				fakelid.Transparency=0
				fakelid.Parent=game.Workspace
				fakelid.CanCollide=true
				fakelid.Velocity=fakelid.Velocity+Vector3.new(math.random()-.5,3,math.random()-.5)*10
				debris:AddItem(fakelid,5)
				fakelid.Parent=game.Workspace
				wait(1)
				for i=1,fireflies do
					createfirefly()
					light.Brightness=4*(1-(i/fireflies))
					wait(math.random())
				end
				wait(5)
				if mouse~=nil then
					mouse.Icon="rbxasset://textures\\GunCursor.png"
				end
				light.Brightness=4
				handle2.Transparency=0
				check=true
			end
		end)
	end
	if weld then
		weld.Parent=sp
	end 
end)

sp.Unequipped:connect(function()
	equipped=false
	if weld then
		weld.Parent=sp
	end
	if anim then
		anim:Stop()
	end
	light.Brightness=4
	handle2.Transparency=0
end)
light.Brightness=4
handle2.Transparency=0

