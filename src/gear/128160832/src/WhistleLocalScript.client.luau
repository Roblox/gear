--Made by Stickmasterluke


sp=script.Parent


local cooldown=10
local jetheight=200
local jetdistance=2000
local jetspeed=300
local talkinggrip=CFrame.new(-1.5,-.5,.65)*CFrame.Angles(-.2,3.14159,0)
local holdinggrip=CFrame.new(0,-.35,.1)*CFrame.Angles(.4,-.9,0)


local debris=game:GetService("Debris")
local check=true
local laststrike=sp:WaitForChild("LastStrike")
local dodgeballscript=sp:WaitForChild("DodgeballScript")

local function createdodgeball(pos,velocity)
	local p=Instance.new("Part")
	p.Name="Dodgeball"
	p.Material="Concrete"
	p.BrickColor=BrickColor.new(math.random()>.5 and "Bright red" or "Bright blue")
	p.Elasticity=1
	p.CanCollide=true
	p.Locked=true
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.formFactor="Custom"
	p.Shape="Ball"
	
	local sound=Instance.new("Sound")
	sound.SoundId="http://www.roblox.com/asset/?id=112503990"
	sound.Parent=p
	
	local creatortag=Instance.new("ObjectValue")
	creatortag.Value=game.Players.LocalPlayer
	creatortag.Name="creator"
	creatortag.Parent=p
	
	local s=dodgeballscript:clone()
	s.Parent=p
	s.Disabled=false
	
	p.Size=Vector3.new(3,3,3)
	p.CFrame=CFrame.new(pos)
	p.Velocity=velocity
	debris:AddItem(p,3)
	p.Parent=game.Workspace
end

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	sp.Grip=holdinggrip
	if mouse~=nil and plr~=nil then
		if tick()-cooldown<laststrike.Value then
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
			wait(laststrike.Value-(tick()-cooldown))
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		else
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		end
		mouse.Button1Down:connect(function()
			if tick()-cooldown>laststrike.Value and mouse.Target and mouse.Target~=nil and mouse.Hit then
				local location=mouse.Hit.p
				local chr=sp.Parent
				if chr and check then
					local t=chr:FindFirstChild("Torso")
					local h=chr:FindFirstChild("Humanoid")
					if t and h and h.Health>0 then
						check=false
						laststrike.Value=tick()
						mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
						sp.Grip=talkinggrip
						local sound=sp.Handle:FindFirstChild("Sound")
						if sound~=nil then
							sound:Play()
						end

						local tp=Instance.new("Part")
						tp.Transparency=.5
						tp.Name="Effect"
						tp.Anchored=true
						tp.CanCollide=false
						tp.Size=Vector3.new(0,0,0)
						tp.BrickColor=BrickColor.new("Really red")
						tp.CFrame=CFrame.new(location)*CFrame.Angles(math.pi/2,0,0)
						local me=Instance.new("SpecialMesh")
						me.MeshId="http://www.roblox.com/asset/?id=3270017"
						me.Scale=Vector3.new(10,10,1)
						me.Parent=tp
						debris:AddItem(tp,5)
						tp.Parent=game.Workspace
						delay(0,function()
							while tp and tp.Transparency<1 do
								tp.Transparency=tp.Transparency+.025
								wait(.15)
							end
							if tp then
								tp:remove()
							end
						end)

						delay(3,function()
							for i=1,30 do
								local startpos=location+Vector3.new((math.random()-.5)*100,5+50*math.random(),(math.random()-.5)*100)
								local vec=(location+Vector3.new(0,15,0)-startpos).unit
								createdodgeball(startpos,vec*(60+math.random()*70))
								wait(.2)
							end
						end)

						wait(2)
						local sound=sp.Handle:FindFirstChild("Sound")
						if sound~=nil then
							sound:Stop()
						end
						sp.Grip=holdinggrip
						wait(cooldown-2)
						mouse.Icon="rbxasset://textures\\GunCursor.png"
						check=true
					end
				end
			end
		end)
	end
end

function onUnequipped()
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)


