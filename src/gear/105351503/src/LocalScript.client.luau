--Made by Stickmasterluke


local sp=script.Parent

originalgrip=CFrame.new(0,-.9,0)
currentgrip=originalgrip

swingspeed=1

debris=game:GetService("Debris")
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

sp.Equipped:connect(function(mouse)
	equipped=true
	local currentlast=lastequipped
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		onButton1Down(mouse)
	end)
	mouse.KeyDown:connect(function(key)
		key=string.lower(key)
		if key=="l" or key=="t" or key=="g" then
			local h=sp.Parent:FindFirstChild("Humanoid")
			if h~=nil then

			end
		end
	end)
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")
	if t and h then
		local equipanim=sp:FindFirstChild("Equip")
		if equipanim~=nil then
			local EquipAnim=h:LoadAnimation(equipanim)
			if EquipAnim and h.Health>0 then
				EquipAnim:Play(nil,nil,equipspeed)
			end
		end
		local holdanim=sp:FindFirstChild("Hold")
		if holdanim~=nil then
			if HoldAnim then
				HoldAnim:Stop()
			end
			HoldAnim=h:LoadAnimation(holdanim)
			if HoldAnim and h.Health>0 then
				HoldAnim:Play()
			end
		end
	end
end)

sp.Unequipped:connect(function()
	equipped=false
	if HoldAnim then
		HoldAnim:Stop()
	end
end)

function lunge()
	local t=sp.Parent:FindFirstChild("Torso")
	local h=sp.Parent:FindFirstChild("Humanoid")
	if t and h and equipped then
		local target=h.TargetPoint
		local direction=(target-t.Position)*Vector3.new(1,0,1)
		if direction.magnitude>.01 then
			direction=direction.unit
			local newBV=Instance.new("BodyVelocity")
			newBV.P=10^5
			newBV.maxForce=Vector3.new(newBV.P,0,newBV.P)
			newBV.velocity=direction*30
			debris:AddItem(newBV,1)
			newBV.Parent=t
			t.CFrame=CFrame.new(t.Position,target*Vector3.new(1,0,1)+Vector3.new(0,t.Position.Y,0))
			local sound=sp.Handle:FindFirstChild("FlashSound")
			if sound then
				sound:Play()
			end
			wait(.2)
			if newBV~=nil then
				newBV:remove()
			end
		end
	end
end

waitfor(sp,"RunAnim")
sp.RunAnim.Changed:connect(function()
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")
	local anim=sp:FindFirstChild(sp.RunAnim.Value)
	if anim and t and h then
		theanim=h:LoadAnimation(anim)
		theanim:Play(nil,nil,1/swingspeed)
		if theanim and h.Health>0 then
			local sound=sp.Handle:FindFirstChild("FlashSound")
			if sound then
				sound:Play()
			end
			if sp.RunAnim.Value=="OverHeadSwingFast" then
				spinsword(.5*swingspeed)
				wait(.125*swingspeed)
				swordOut()
				wait(.25*swingspeed)
				swordUp()
				sp.Grip=currentgrip
			end
		end
	end
end)

function tagHumanoid(humanoid,player)
	for i,v in ipairs(humanoid:GetChildren()) do
		if v.Name=="creator" then
			v:remove()
		end
	end
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=player
	creator_tag.Name="creator"
	creator_tag.Parent=humanoid
	debris:AddItem(creator_tag,1)
end

