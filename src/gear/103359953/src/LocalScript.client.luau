--Made by Stickmasterluke


sp=script.Parent


function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

reloading=waitfor(sp,"Reloading")
down=waitfor(sp,"MouseDown")
runanim=waitfor(sp,"RunAnim")

animspeed=.8		--lower number is slower
equipspeed=.8
originalgrip=CFrame.new(0, -1.95000005, 0.0600000098, 1, 0, 0, 0, 1, 0, 0, 0, 1)
currentgrip=originalgrip
function swordUp()
	currentgrip=originalgrip
	sp.Grip=currentgrip
end
function swordOut()
	currentgrip=originalgrip*CFrame.Angles(math.pi/4,.4,0)
	sp.Grip=currentgrip
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

function update(mouse)
	if mouse~=nil then
		if reloading.Value then
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
		else
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		end
	end
end

runanim.Changed:connect(function()
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")
	local anim=sp:FindFirstChild(runanim.Value)
	if anim and t and h then
		local theanim=h:LoadAnimation(anim)
		if theanim and h.Health>0 then
			if runanim.Value=="RightSlash" then
				theanim:Play(nil,nil,2)
			else

				theanim:Play(nil,nil,animspeed)
			end
			
			if runanim.Value=="RightSlash" or runanim.Value=="LeftSlash" or runanim.Value=="OverHeadSwing" then
				spinsword(.5)
			end
			if runanim.Value=="OverHeadSwing" then
				wait(.25)
				swordOut()
				wait(.5)
				swordUp()
			elseif runanim.Value=="OverHeadSwingFast" then
				wait(.125)
				swordOut()
				wait(.25)
				swordUp()
			end
		end
	end
end)



local LastSpace = 0
local LastTeleport = 0
local nsmoke = Instance.new('Smoke')
function Equipped(mouse)
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")	
	if mouse~=nil then
		update(mouse)
		reloading.Changed:connect(function()
			update(mouse)
		end)
		mouse.Button1Down:connect(function()
			down.Value=true
		end)
		mouse.Button1Up:connect(function()
			down.Value=false
		end)
		mouse.KeyDown:connect(function(nkey)
			--print (nkey)
			if nkey == string.char(32) then
				if tick()-LastSpace < 1 and tick()-LastTeleport >5 then
					
					LastTeleport = tick()
					t.CFrame = t.CFrame + (t.CFrame.lookVector*20)
				elseif tick()-LastTeleport >5 then
					LastSpace = tick()
				end
				
			end
			
		end)
		
		
		if t and h then
			nsmoke.Color = Color3.new(0,0,0)
			nsmoke.Size = 15
			nsmoke.Parent = t
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
	end
end

function Unequipped()
	down.Value=false
	nsmoke.Parent = nil
	if HoldAnim then
		HoldAnim:Stop()
	end
end

sp.Equipped:connect(Equipped)
sp.Unequipped:connect(Unequipped)
