--Made by Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")
exploded=false


function bang(hit)
	if not exploded and hit~=nil and hit.Name~="Effect" and hit.Name~="Handle" then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h~=nil then
			local ct=sp:FindFirstChild("creator")
			if ct~=nil and ((not game.Players:GetPlayerFromCharacter(hit.Parent)) or game.Players:GetPlayerFromCharacter(hit.Parent)~=ct.Value) then
				for _,v in pairs(h:GetChildren()) do
					if v~=nil and v.className=="ObjectValue" then
						v:remove()
					end
				end
				ct:clone().Parent=h
				h:TakeDamage(sp:FindFirstChild("Motor") and 16 or 26)
				hithuman=true
			end
		end
		if hithuman or not sp:FindFirstChild("Motor") then
			exploded=true
			local sound=sp:FindFirstChild("Sound")
			if sound then
				sound:Play()
			end
			for i=1,math.random(4,8) do
				local p=Instance.new("WedgePart")
				p.Name="EmeraldShard"
				p.Transparency=sp.Transparency
				p.Reflectance=sp.Reflectance
				p.BrickColor=sp.BrickColor
				p.FormFactor="Custom"
				p.Size=Vector3.new(.5,.5,.5)+Vector3.new(math.random(),math.random(),math.random())
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.Anchored=false
				if math.random()<.5 then
					p.CanCollide=false
				end
				p.Locked=true
				p.BrickColor=sp.BrickColor
				local rp=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)
				p.CFrame=sp.CFrame*CFrame.new(rp*4)*CFrame.Angles(math.random()*6,math.random()*6,math.random()*6)
				p.Velocity=Vector3.new(0,30+(math.random()*30),0)+(rp*math.random(10,40))
				p.RotVelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*10
				debris:AddItem(p,2+(math.random()*4))
				p.Parent=game.Workspace
			end
			sp.Transparency=1
			sp.CanCollide=false
			sp.Anchored=true
			local cf=sp.CFrame
			sp.Size=Vector3.new(0,0,0)
			sp.CFrame=cf
			wait(1)
			if sp then
				sp:remove()
			end
		end
	end
end

sp.Touched:connect(bang)

wait(20)
sp:remove()





