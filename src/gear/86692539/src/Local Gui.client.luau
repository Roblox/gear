--Made by Stickmasterluke


local sp=script.Parent

originalgrip=CFrame.new(.15,-2,0)*CFrame.Angles(0,math.pi/2,0)
currentgrip=originalgrip

enabled=true
taunting=false

function waitfor(parent,name)
	while true do
		local child=parent:FindFirstChild(name)
		if child~=nil then
			return child
		end
		wait()
	end
end

waitfor(sp,"Handle")

function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled=false
	mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
	wait(.75)
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	enabled=true
end

function swordUp()
	currentgrip=originalgrip
end

function swordOut()
	currentgrip=originalgrip*CFrame.Angles(math.pi/4,.4,0)
end

function spinsword(spintime)
	delay(0,function()
		local startspin=tick()
		local endspin=startspin+spintime
		while tick()<endspin do
			sp.Grip=currentgrip*CFrame.Angles(math.pi*2*((tick()-startspin)/spintime),0,0)
			wait()
		end
		sp.Grip=currentgrip
	end)
end

function onEquippedLocal(mouse)
	local currentlast=lastequipped
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		onButton1Down(mouse)
	end)
	waitfor(sp,"Taunting")
	waitfor(sp,"Taunt")
	mouse.KeyDown:connect(function(key)
		key=string.lower(key)
		if key=="l" or key=="t" or key=="g" then	-- :3
			local h=sp.Parent:FindFirstChild("Humanoid")
			if h~=nil then
				sp.Taunting.Value=true
				h.WalkSpeed=0
				tauntanim=h:LoadAnimation(sp.Taunt)
				tauntanim:Play()
				wait(1)
				swordOut()
				sp.Grip=currentgrip
				wait(1.4)
				swordUp()
				sp.Grip=currentgrip
				wait(1)
				h.WalkSpeed=16
				sp.Taunting.Value=false
			end
		end
	end)
end
sp.Equipped:connect(onEquippedLocal)

waitfor(sp,"RunAnim")
sp.RunAnim.Changed:connect(function()
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")
	local anim=sp:FindFirstChild(sp.RunAnim.Value)
	if anim and t and h then
		theanim=h:LoadAnimation(anim)
		if theanim and h.Health>0 then
			theanim:Play()
			if sp.RunAnim.Value=="RightSlash" or sp.RunAnim.Value=="LeftSlash" or sp.RunAnim.Value=="OverHeadSwing" then
				spinsword(.5)
			end
			if sp.RunAnim.Value=="OverHeadSwing" then
				wait(.25)
				swordOut()
				wait(.5)
				swordUp()
				sp.Grip=currentgrip
			elseif sp.RunAnim.Value=="OverHeadSwingFast" then
				wait(.125)
				swordOut()
				wait(.25)
				swordUp()
				sp.Grip=currentgrip
			end
		end
	end
end)
