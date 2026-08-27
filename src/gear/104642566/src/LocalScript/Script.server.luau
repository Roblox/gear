--Stickmasterluke


sp=script.Parent


timer=20
soundinterval=1


starttime=tick()
attached=false
debris=game:GetService("Debris")


function makeconfetti()
	local cp=Instance.new("Part")
	cp.Name="Effect"
	cp.FormFactor="Custom"
	cp.Size=Vector3.new(0,0,0)
	cp.CanCollide=false
	cp.Transparency=1
	cp.CFrame=sp.CFrame
	cp.Velocity=Vector3.new((math.random()-.5),math.random(),(math.random()-.5)).unit*20
	delay(.25+(math.random()*.2),function()
		if cp~=nil then
			cp.Velocity=cp.Velocity*.1
			wait(.5)
		end
		if cp~=nil then
			cp.Velocity=Vector3.new(0,-1,0)
			wait(1)
		end
		if cp~=nil then
			cp.Velocity=Vector3.new(0,-2,0)
		end
	end)
	local cbbg=Instance.new("BillboardGui")
	cbbg.Adornee=cp
	cbbg.Size=UDim2.new(7,0,4,0)
	local cil=Instance.new("ImageLabel")
	cil.BackgroundTransparency=1
	cil.BorderSizePixel=0
	cil.Size=UDim2.new(1,0,1,0)
	cil.Image="http://www.roblox.com/asset/?id=104606998"
	cil.Parent=cbbg
	cbbg.Parent=cp
	local bf=Instance.new("BodyForce")
	bf.force=Vector3.new(0,cp:GetMass()*196.2,0)
	bf.Parent=cp
	debris:AddItem(cp,7+math.random())
	cp.Parent=game.Workspace
end


sp.Touched:connect(function(hit)
	if (not attached) and hit and hit~=nil and sp~=nil then
		local ct=sp:FindFirstChild("creator")
		if ct.Value~=nil and ct.Value.Character~=nil then
			if hit.Parent~=ct.Value.Character and hit.Name~="Handle" and hit.Name~="Effect" then
				local h=hit.Parent:FindFirstChild("Humanoid")
				local t=hit.Parent:FindFirstChild("Torso")
				if h~=nil and t~=nil and h.Health>0 then
					attached=true
					local w=Instance.new("Weld")
					w.Part0=t
					w.Part1=sp
					w.C0=CFrame.new(0,0,.8)*CFrame.Angles(math.pi/2,3.5,0)
					w.Parent=sp
				end
			end
		end
	end
end)

while true do
	local percent=(tick()-starttime)/timer
	t1,t2=wait(((1-percent)*soundinterval))
	local beep=sp:FindFirstChild("Beep")
	if beep~=nil then
		beep:Play()
	end
	local bbg=sp:FindFirstChild("BillboardGui")
	if bbg~=nil then
		bbg.Adornee=sp
		li=bbg:FindFirstChild("LightImage")
		if li~=nil then
			li.Visible=true
		end
	end
	if percent>1 then
		break
	end
	wait(.1)
	if li then
		li.Visible=false
	end
end

wait(.5)
local smoke=sp:FindFirstChild("Smoke")
if smoke then
	smoke.Enabled=true
end
wait(.5)
local fusesound=sp:FindFirstChild("Fuse")
if fusesound~=nil then
	fusesound:Play()
end
local bbg=sp:FindFirstChild("BillboardGui")
if bbg~=nil then
	bbg.Adornee=sp
	li=bbg:FindFirstChild("LightImage")
	if li~=nil then
		li.Visible=false
	end
end
local partysound=sp:FindFirstChild("PleaseNo")
if partysound~=nil then
	partysound:Play()
end
for i=1,7 do
	makeconfetti()
end
wait(.5)
if smoke then
	smoke.Enabled=false
end
wait(2.5)

sp:remove()
