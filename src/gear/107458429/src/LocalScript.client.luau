--Made by Stickmasterluke


local sp=script.Parent


cooldown=.5


debris=game:GetService("Debris")
check=true

function waitfor(parent,name)
	while true do
		local child=parent:FindFirstChild(name)
		if child~=nil then
			return child
		end
		wait()
	end
end

local handle=waitfor(sp,"Handle")
local debris=game:GetService("Debris")

function randomcolor()
	if handle then
		local m=handle:FindFirstChild("Mesh")
		if m~=nil then
			m.VertexColor=Vector3.new(math.random(1,2),math.random(1,2),math.random(1,2))*.5
		end
	end
end

function onButton1Down(mouse)
	if check then
		check=false
		mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
		local h=sp.Parent:FindFirstChild("Humanoid")
		local t=sp.Parent:FindFirstChild("Torso")
		local anim=sp:FindFirstChild("RightSlash")
		if anim and t and h then
			theanim=h:LoadAnimation(anim)
			theanim:Play(nil,nil,1.5)
			if theanim and h.Health>0 then
				local sound=sp.Handle:FindFirstChild("SlashSound")
				if sound then
					sound:Play()
				end
				wait(.25)
				handle.Transparency=1
				local p=handle:clone()
				p.Name="Effect"
				p.CanCollide=false
				p.Transparency=0
				p.Script.Disabled=false
				local tag=Instance.new("ObjectValue")
				tag.Name="creator"
				tag.Value=h
				tag.Parent=p
				p.RotVelocity=Vector3.new(0,0,0)
				p.Velocity=(mouse.Hit.p-p.Position).unit*100+Vector3.new(0,10,0)
				p.CFrame=CFrame.new(handle.Position,mouse.Hit.p)*CFrame.Angles(-math.pi/2,0,0)
				debris:AddItem(p,20+math.random()*5)
				p.Parent=game.Workspace
			end
		end
		wait(cooldown-.25)
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		randomcolor()
		handle.Transparency=0
		check=true
	end
end

sp.Equipped:connect(function(mouse)
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	equipped=true
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		onButton1Down(mouse)
	end)
end)

sp.Unequipped:connect(function()
	equipped=false
	handle.Transparency=0
	randomcolor()
end)


