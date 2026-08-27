--Made by Stickmasterluke


local sp=script.Parent


local tauntcooldown=10

local originalgrip=CFrame.Angles(math.pi/2,0,0)+Vector3.new(0,-.25,-1.4)

local currentgrip=originalgrip

local debris=game:GetService("Debris")
local enabled=true
local taunting=false
local lasttaunt=0

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
	waitfor(sp,"Taunting")
	waitfor(sp,"Taunt")
	--[[waitfor(sp,"Summon")
	mouse.KeyDown:connect(function(key)
		key=string.lower(key)
		if key=="l" or key=="t" or key=="g" or key=="e" then
			local h=sp.Parent:FindFirstChild("Humanoid")
			if h~=nil and (not sp.Taunting.Value) and lasttaunt+tauntcooldown<tick() then
				lasttaunt=tick()
				sp.Taunting.Value=true
				h.WalkSpeed=0
				tauntanim=h:LoadAnimation(sp.Taunt)
				tauntanim:Play()
				wait(4)
				sp.Summon.Value=not sp.Summon.Value
				wait(1)
				h.WalkSpeed=16
				sp.Taunting.Value=false
			end
		end
	end)
	--]]
end)

sp.Unequipped:connect(function()
	equipped=false
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

