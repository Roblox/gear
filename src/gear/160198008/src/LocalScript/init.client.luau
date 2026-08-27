--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	owner = game.Players.LocalPlayer,
	deb = game:GetService("Debris"),
	fireSound = script.Parent.Handle:WaitForChild("FireSound"),
	loadSound = script.Parent.Handle:WaitForChild("Loading"),
	chargeSound = script.Parent.Handle:WaitForChild("ChargeLoop"),
	reloadAnimation = script.Parent:WaitForChild("Reload"),
	readyAnimation = nil,
	effect = script.Parent:WaitForChild("Arrow"),
	gearWeld = nil,
	pCamera = workspace.CurrentCamera,
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	isCharging = false,
	fullyCharged = false,
	check = true,
	firerate = 1.25,
	range = 600,
	power = 300,
	rate = 1/30,
	fullDmg = 80,
	lightDmg = 36,
	bOffset = Vector3.new(0,0,0),
	wind = Vector3.new(2,-1,1).unit
};

function gearConfig.weldWeapon()
	gearConfig.gear.Arrow.Anchored = true;
	local w = Instance.new("Weld"); --Fixed by Luckymaxer
	w.Parent = gearConfig.gear;
	w.Part0 = gearConfig.gear.Handle;
	w.Part1 = gearConfig.gear.Arrow;
	w.C0 = gearConfig.gear.Handle.CFrame:inverse(gearConfig.gear.Handle);
	w.C1 = gearConfig.gear.Arrow.CFrame:inverse(gearConfig.gear.Arrow);
	gearConfig.gear.Arrow.Anchored = false;
	return w;
end

function gearConfig.checkintangible(a)if a and a~=nil then if a:IsDescendantOf(script.Parent.Parent)or a.Transparency>.8 or a.Name=="Handle"or string.lower(string.sub(a.Name,1,6))=="effect"or a.Name=="Bullet"or a.Name=="Laser"or string.lower(a.Name)=="water"or a.Name=="Rail"or a.Name=="Arrow"then return true end end;return false end

function gearConfig.drawbeam(beamstart,beamend,clr,fadedelay)
	local dist=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Effect"
	laser.Anchored=true
	laser.CanCollide=false
	laser.Shape="Block"
	laser.formFactor="Custom"
	laser.Size=Vector3.new(.2,.2,.2)
	laser.Transparency=5
	laser.Material=Enum.Material.Plastic
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=clr
	laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dist/2)*CFrame.Angles(math.pi/2,0,0)
	local m=Instance.new("SpecialMesh")
	m.Scale=Vector3.new(1,dist*5,1)
	m.Parent=laser
	gearConfig.deb:AddItem(laser,fadedelay*3)
	laser.Parent=workspace

	local frames=math.floor(fadedelay/gearConfig.rate)
	for frame=1,frames do
		wait(gearConfig.rate)
		local percent=frame/frames
		if (gearConfig.fullyCharged) then
			laser.CFrame=laser.CFrame+Vector3.new(0,0,0).unit*gearConfig.rate
		else
			laser.CFrame=laser.CFrame+gearConfig.wind*gearConfig.rate
		end
		
		laser.Transparency=.5+(percent*.5)
	end
	wait(1)
	laser:remove()
end

function gearConfig.castray(startpos,vec,length,ignore,delayifhit)
	local hit,endpos2=game.Workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
	if hit~=nil then
		if gearConfig.checkintangible(hit) then
			if delayifhit then
				wait()
			end
			hit,endpos2=gearConfig.castray(endpos2+(vec*.01),vec,length-((startpos-endpos2).magnitude),ignore,delayifhit)
		end
	end
	return hit,endpos2
end

gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
	gearConfig.isCharging = false;
	gearConfig.fullyCharged = false;
	gearConfig.chargeSound:Stop();
	if (gearConfig.gearWeld ~= nil) then
		gearConfig.gearWeld.Parent = script.Parent;
	end
	gearConfig.pCamera.FieldOfView = 70;
	gearConfig.owner.Character.Humanoid.WalkSpeed = 16;	
end);

gearConfig.gear.Equipped:connect(function(m)
	gearConfig.equipped = true;
	gearConfig.isCharging = false;
	gearConfig.fullyCharged = false;
	if script.Parent:FindFirstChild("Arrow") then
		gearConfig.effect.Transparency = 0
	end
	if (gearConfig.readyAnimation ~= nil) then
		gearConfig.readyAnimation:Stop();
	end
	if (gearConfig.gearWeld ~= nil) then
		gearConfig.gearWeld.Parent = script.Parent;
	end
--	gearConfig.weldWeapon()
	gearConfig.gear.Arrow.Anchored = false;
	if (m ~= nil) then
		m.Icon="rbxasset://textures\\GunCursor.png"
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		gearConfig.readyAnimation = human:LoadAnimation(gearConfig.reloadAnimation);
		m.Button1Down:connect(function() -- charge			
			if (gearConfig.check and human.Health > 0 and gearConfig.isCharging == false) then
				gearConfig.pCamera.FieldOfView = 70;
				human.WalkSpeed = 16;
				gearConfig.isCharging = true;
				gearConfig.fullyCharged = false;
				gearConfig.readyAnimation:Play();
				gearConfig.readyAnimation:AdjustSpeed(0.5);
				gearConfig.loadSound:Play();
				Spawn(function()
					wait(1);
					if gearConfig.isCharging then gearConfig.chargeSound:Play(); end
				end);
				Spawn(function()
					local ts = gearConfig.tween("forward");
					ts.add(2, {x = 70}, gearConfig.easing.inOutQuad); ts.add(2, {x = 55}, gearConfig.easing.inOutQuad);
					local hs = gearConfig.tween("forward");
					hs.add(2, {x = 16}, gearConfig.easing.inOutQuad); hs.add(2, {x = 11}, gearConfig.easing.inOutQuad);
					for x=1, 200 do
						local p = ts.getCurrentProperties();
						gearConfig.pCamera.FieldOfView = p.x;
						
						local h = hs.getCurrentProperties();
						human.WalkSpeed = h.x;
						ts.update(0.025); hs.update(0.025); wait(0.025);
						if not gearConfig.isCharging then gearConfig.fullyCharged = false; break; end
						if (p.x <= 55) then gearConfig.fullyCharged = true; break; end
					end
				end);
			end	
		end);	
		
		m.Button1Up:connect(function()
			local head=script.Parent.Parent:findFirstChild("Head");
			local torso=script.Parent.Parent:findFirstChild("Torso");
			gearConfig.isCharging = false;
			gearConfig.pCamera.FieldOfView = 70;
			human.WalkSpeed = 16;
			gearConfig.loadSound:Stop();
			gearConfig.chargeSound:Stop();
			gearConfig.readyAnimation:Stop();
			if (human ~= nil and head ~= nil and torso ~= nil) then
				if (gearConfig.check and human.Health > 0) then
					gearConfig.check = false;
					
					local startPos = head.Position;
					local fakeStartPos = (gearConfig.gear.Handle.CFrame*CFrame.new(gearConfig.bOffset)).p;

					local v = (m.Hit.p - startPos).unit;
					
					gearConfig.readyAnimation:Play();
					gearConfig.readyAnimation:AdjustSpeed(4);
					Spawn(function() wait(0.3) gearConfig.readyAnimation:Stop(); end);

					local arrow = Instance.new("Part");
					arrow.Name = "Part";
					arrow.BrickColor = BrickColor.new("Black");
					arrow.CanCollide=true;
					arrow.TopSurface="Smooth";
					arrow.BottomSurface="Smooth";
					arrow.formFactor="Custom";
					arrow.Size=Vector3.new(.2,.2,2);
					local me=Instance.new("SpecialMesh");
					me.MeshId="http://www.roblox.com/asset/?id=159721292";
					me.TextureId="http://www.roblox.com/asset/?id=159721355";
					me.Scale=Vector3.new(1,1,1);
					me.VertexColor=Vector3.new(1,1,1);
					me.Parent=arrow;
					
					local hum = Instance.new("Sound");
					hum.Name = "Hum";
					hum.Parent = arrow;
					hum.SoundId = "http://www.roblox.com/asset/?id=159827216";
					hum.Volume = 1;
					hum.Looped = true;
	
					local sound1 = Instance.new("Sound");
					sound1.Name = "HitObject";
					sound1.SoundId = "http://www.roblox.com/asset/?id=159827759";
					sound1.Volume = 1;
					sound1.Parent= arrow;			
					
					local sound2 = Instance.new("Sound");
					sound2.Name = "HitPlayer";
					sound2.SoundId = "http://www.roblox.com/asset/?id=159830185";
					sound2.Volume = 1;
					sound2.Parent = arrow;
					
					local light = Instance.new("PointLight");
					light.Name = "Light";
					light.Brightness = 5;
					light.Color = Color3.new(0,255,0);
					light.Range = 5;
					light.Enabled = true;
					light.Shadows = false;
					light.Parent = arrow;
					
					local c = Instance.new("ObjectValue");
					c.Name="creator";
					c.Value=gearConfig.owner;
					c.Parent=arrow;
					local dmg = Instance.new("IntValue");
					dmg.Name='dmg';
					dmg.Parent=arrow;
					if (gearConfig.fullyCharged) then dmg.Value = gearConfig.fullDmg; else dmg.Value = gearConfig.lightDmg; end				
					
					local s=script.Script:clone();
					s.Parent=arrow;
					s.Disabled=false;
					
					local hit,endpos=gearConfig.castray(startPos, v, gearConfig.range, gearConfig.gear.Parent, false);
					local fakevec=(endpos-fakeStartPos).unit;
					
					if hit~=nil then
						local newcf= CFrame.new(endpos,endpos+fakevec)*CFrame.new(0,0,.5);
						arrow.CFrame = newcf;
						local w = Instance.new("Weld");
						w.Part0 = hit;
						w.Part1 = arrow;
						w.C0 = hit.CFrame:inverse() * newcf;
						w.C1 = newcf:inverse() * newcf;
						w.Parent = arrow;
					else
						arrow.CFrame = CFrame.new(endpos, endpos + fakevec);
						arrow.Velocity = fakevec * gearConfig.power;
						arrow.Parent = workspace;
					end
					
					gearConfig.deb:AddItem(arrow,15)
					arrow.Parent = workspace;
					hum:Play();					
					
					Spawn(function()
						gearConfig.drawbeam(fakeStartPos,endpos,BrickColor.new("Lime green"),.25);
					end)
	
					gearConfig.fireSound:Play()
					local shoulder = torso:FindFirstChild("Right Shoulder");
					if (shoulder ~= nil) then
						shoulder.CurrentAngle = 2;
					end
					if script.Parent:FindFirstChild("Arrow") then
						gearConfig.effect.Transparency = 1
					end
					m.Icon="rbxasset://textures\\GunWaitCursor.png"
					wait(gearConfig.firerate)
					if script.Parent:FindFirstChild("Arrow") then
						gearConfig.effect.Transparency = 0
					end
					m.Icon="rbxasset://textures\\GunCursor.png"
					gearConfig.check=true					
				end
			end
		end);
	end
end);

gearConfig.gearWeld = gearConfig.weldWeapon();