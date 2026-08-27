--Made by Stickmasterluke


sp=script.Parent
plr=game.Players.localPlayer


firerate=1

rate=1/30
debris=game:GetService("Debris")
equipped=false
check=true

storeWeld=sp:FindFirstChild("PartWeld")
while storeWeld==nil do
	wait()
	storeWeld=sp:FindFirstChild("PartWeld")
end

function throw(vec,vel)
	if sp:FindFirstChild("Handle")~=nil then
		local vec=vec+(Vector3.new(math.random(),math.random(),math.random())*.1)
		local p=sp.Handle:clone()
		p.Name="Effect"
		p.CanCollide=false
		p.Velocity=(vec*vel)+Vector3.new(0,vel*.4,0)
		p.RotVelocity=p.RotVelocity+(Vector3.new(math.random(),Vector3.new(math.random(),Vector3.new(math.random()))-Vector3.new(-.5,-.5,-.5))*20)
		local w=Instance.new("Weld")
		w.Part0=p
		w.Part1=p.InnerPart
		w.Parent=p
		local tag=Instance.new("ObjectValue")
		tag.Value=game.Players.LocalPlayer
		tag.Name="creator"
		tag.Parent=p
		local s=sp.Script:clone()
		s.Parent=p
		s.Disabled=false
		debris:AddItem(p,10)
		p.Parent=game.Workspace
	end
end

function onEquipped(mouse)
	equipped=true
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local he=sp.Parent:FindFirstChild("Head")
			local hu=sp.Parent:FindFirstChild("Humanoid")
			if check and he and hu and hu.Health>0 then
				check=false
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				local vec=(mouse.Hit.p-sp.Handle.Position).unit
				local s=sp.Handle:FindFirstChild("ThrowSound")
				if s~=nil then
					s:Play()
				end
				throw(vec,100)
				throw(vec,80)
				throw(vec,60)
				throw(vec,40)
				wait(firerate)
				mouse.Icon="rbxasset://textures\\GunCursor.png"
				check=true
			end
		end)
	end
	if storeWeld then
		storeWeld.Parent=sp
	end
end

function onUnequipped()
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





