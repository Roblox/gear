--Stickmasterluke
--A nice simple axe


local sp=script.Parent

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
waitfor(sp.Handle,"Mesh")
waitfor(sp,"RunAnim")
waitfor(sp,"Taunting")
waitfor(sp,"LeftSlash")
waitfor(sp,"RightSlash")
waitfor(sp,"Taunt")

sp.Handle.Mesh.Scale=Vector3.new(1.3,1.3,1.3)


function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled=false
	mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
	wait(1.25)
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	enabled=true
end

function swordUp()
	--sp.Grip=CFrame.new(.15,-2,0)*CFrame.Angles(0,math.pi/2,0)
end

function swordOut()
	--sp.Grip=(CFrame.new(.15,-2,0)*CFrame.Angles(0,math.pi/2,0))*CFrame.Angles(math.pi/4,.4,0)
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
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		if plr.Character~=nil then
			local ra=plr.Character:FindFirstChild("Right Arm")
			if ra~=nil then
				ra.Transparency=1
			end
		end
	end
end

function onUnequippedLocal(mouse)
	local currentlast=lastequipped
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		if plr.Character~=nil then
			local ra=plr.Character:FindFirstChild("Right Arm")
			if ra~=nil then
				ra.Transparency=0
			end
		end
	end
end

sp.Equipped:connect(onEquippedLocal)
sp.Unequipped:connect(onUnequippedLocal)

while sp:FindFirstChild("RunAnim")==nil do
	wait()
end
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
			end
		end
	end
end)
