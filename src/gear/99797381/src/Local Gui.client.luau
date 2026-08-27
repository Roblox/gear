--Made by Stickmasterluke


local sp=script.Parent

originalgrip=CFrame.new(-0.0500001907, -1.5, 1.74845525e-008, -1, 0, -2.62268344e-007, 0, 1, 0, 2.62268344e-007, 0, -1)--CFrame.new(.15,-2,0)*CFrame.Angles(0,math.pi/2,0)
currentgrip=originalgrip

enabled=true

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

originalgrip=CFrame.new(.15,-2,0)*CFrame.Angles(0,math.pi/2,0)
currentgrip=originalgrip

function swordUp()
	currentgrip=originalgrip
end

function swordOut()
	currentgrip=originalgrip*CFrame.Angles(math.pi/4,.4,0)
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
