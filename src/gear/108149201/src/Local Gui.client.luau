--Made by Stickmasterluke


local sp=script.Parent


taunting=false

cursors={
	Left=108119671,
	Right=108119709,
	Center=108119490,
}

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end

sword=waitfor(sp,"Handle")
waitfor(sp,"Taunting")
waitfor(sp,"RunAnim")
waitfor(sp,"AnimToRun")
waitfor(sp,"MouseSide")
--[[local contentprovider=Game:GetService("ContentProvider")
for _,v in pairs(cursors) do
	contentprovider:Preload(v)		--Currently does not work
end]]

function swordUp()
	sp.Grip=CFrame.new(0,-1.7,0)
end

function swordOut()
	sp.Grip=CFrame.new(0,-1.7,0)*CFrame.Angles(math.pi/4,.4,0)
end

function onEquippedLocal(mouse)
	local currentlast=lastequipped
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	themouse=mouse
	mouse.Icon="http://www.roblox.com/Asset?ID="..tostring(cursors["Center"])
	mouse.Move:connect(function()
		local mp=mouse.X/mouse.ViewSizeX
		sp.MouseSide.Value=(mp<=1/3 and "Left") or (mp>=2/3 and "Right") or "Center"
	end)
	mouse.KeyDown:connect(function(key)
		key=string.lower(key)
		if key=="l" or key=="t" or key=="g" then
			local h=sp.Parent:FindFirstChild("Humanoid")
			if h~=nil then
				sp.Taunting.Value=true
				h.WalkSpeed=0
				tauntanim=h:LoadAnimation(sp.Taunt)
				tauntanim:Play()
				wait(1)
				swordOut()
				wait(1.4)
				swordUp()
				wait(1)
				h.WalkSpeed=16
				sp.Taunting.Value=false
			end
		end
	end)
end
sp.Equipped:connect(onEquippedLocal)

sp.MouseSide.Changed:connect(function()
	if themouse then
		themouse.Icon="http://www.roblox.com/Asset?ID="..tostring(cursors[sp.MouseSide.Value])
	end
end)

sp.RunAnim.Changed:connect(function()
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")
	local anim=sp:FindFirstChild(sp.AnimToRun.Value)
	if anim and t and h then
		theanim=h:LoadAnimation(anim)
		if theanim and h.Health>0 then
			theanim:Play()
			if sp.AnimToRun.Value=="OverHeadSwing" then
				wait(.25)
				swordOut()
				wait(.5)
				swordUp()
			end
		end
	end
end)
