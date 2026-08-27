--Made by Stickmasterluke


local sp=script.Parent

originalgrip=CFrame.new(0.05,-1.6,0,0,0,-1,0,1,0,1,0,0)
currentgrip=originalgrip

debris=game:GetService("Debris")
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
blizscript=waitfor(sp,"BlizzardScript")
gui=waitfor(blizscript,"BlizzardGui")
guiclone=gui:clone()
guiclonescript=waitfor(guiclone,"LocalScript")
guiclonescript.Disabled=false

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
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		local plrgui=plr:FindFirstChild("PlayerGui")
		if plrgui~=nil then
			guiclone.Parent=plrgui
		end
	end
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
				sp.Taunting.Value=false
			end
		end
	end)
end)

sp.Unequipped:connect(function()
	equipped=false
	guiclone.Parent=sp
	if mh~=nil then
		mh.WalkSpeed=16
	end
end)

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

r=17
while true do
	wait(.5)
	plr=game.Players.LocalPlayer
	if equipped and plr and plr.Character then
		local t=plr.Character:FindFirstChild("Torso")
		if t~=nil then
			local parts=game.Workspace:FindPartsInRegion3(Region3.new(t.Position-Vector3.new(r,r,r),t.Position+Vector3.new(r,r,r)),sp.Parent,100)
			for i,v in ipairs(parts) do
				if v.Name=="Torso" then
					local h=v.Parent:FindFirstChild("Humanoid")
					if h~=nil then
						tagHumanoid(h,plr)
						h:TakeDamage(2)
						local tblizscript=v.Parent:FindFirstChild("BlizzardScript")
						if tblizscript~=nil then
							local ttimer=tblizscript:FindFirstChild("Timer")
							if ttimer~=nil then
								ttimer.Value=3
							end
						else
							local nblizscript=blizscript:clone()
							nblizscript.Parent=v.Parent
							nblizscript.Disabled=false
						end
					end
				end
			end
		end
		mh=sp.Parent:FindFirstChild("Humanoid")
		if mh~=nil then
			mh.WalkSpeed=20
		end
	end
end
