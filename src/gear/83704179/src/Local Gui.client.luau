--Stickmasterluke
--A nice simple axe

local sp = script.Parent
local sword = sp:WaitForChild'Handle'


enabled=true
taunting=false

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
	sp.Grip=CFrame.new(.15,-2,0)*CFrame.Angles(0,math.pi/2,0)
end

function swordOut()
	sp.Grip=(CFrame.new(.15,-2,0)*CFrame.Angles(0,math.pi/2,0))*CFrame.Angles(math.pi/4,.4,0)
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
