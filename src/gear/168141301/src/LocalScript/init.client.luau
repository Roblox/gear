--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");
print(1)
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	isSwinging = false,
	attackDeb = true,
	check = true,
	taunting = false,
	debris = game:GetService("Debris"),
	taunting = script.Parent:WaitForChild("Taunting"),
	runAnim = script.Parent:WaitForChild("RunAnim"),
	specialSound = script.Parent.Handle:WaitForChild("dragon"),
	specialScript = script:WaitForChild("fire"),
	lastHumanoid = nil,
	anims = {
		script.Parent:WaitForChild("TonightsForcast")
	},
	sounds = {
		script.Parent.Handle:WaitForChild("Slash1")
	},
	readyAnims = {},
	deb = 0.75,
	damage = 25
};
print(2)
gearConfig.runAnim.Value = "";
gearConfig.taunting.Value = false;
gearConfig.gear.Equipped:connect(function(m)
	gearConfig.equipped = true;
	if (m ~= nil) then
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		gearConfig.lastHumanoid = human;
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
		end		
		m.KeyDown:connect(function(key)
			local key = string.lower(key);
			local leftArm =script.Parent.Parent:findFirstChild("Left Arm");
			local torso = script.Parent.Parent:findFirstChild("Torso");
			local special = leftArm:findFirstChild("Effect");
			if (key == "l" or key == "t" or key == "g" or key == "e" or key == "q") then
				if (gearConfig.check and not gearConfig.taunting.Value and human ~= nil and human.Health > 0 and torso ~= nil and leftArm ~= nil and special == nil) then
					Spawn(function() wait(4); human.WalkSpeed = 16; end);
					gearConfig.check = false;
					gearConfig.taunting.Value = true;
					human.WalkSpeed=12;
					gearConfig.readyAnims[1]:Play();
					gearConfig.specialSound:Play();					
					local p=Instance.new("Part");
					p.Name="Effect";
					p.CanCollide=false;
					p.Transparency=1;
					p.FormFactor="Custom";
					p.Size=Vector3.new(0,0,0);
					local frost=Instance.new("Fire");
					frost.Color=Color3.new(0,.4,1);
					frost.SecondaryColor = Color3.new(0,1,1);
					frost.Size=8;
					frost.Heat=25;
					frost.Parent=p;
					local w=Instance.new("Motor");
					w.Part0=leftArm;
					w.Part1=p;
					w.C0=CFrame.new(0,0,0)*CFrame.Angles(math.pi,0,0);
					w.Parent=p;
					gearConfig.debris:AddItem(p,10);
					p.Parent=leftArm;
					wait(.7);
					for i=1,18 do
						if p and p.Parent~=nil then
							local p2=Instance.new("Part");
							p2.Name="Effect";
							p2.Transparency=1;
							p2.BrickColor=BrickColor.new("Bright red");
							p2.CanCollide=false;
							p2.FormFactor="Custom";
							p2.Position=p.Position;
							p2.Shape="Ball";
							p2.Size=Vector3.new(3,3,3);
							p2.Velocity=(torso.CFrame.lookVector*40)+(Vector3.new((math.random()-.5)*2,(math.random()-.5)*2,(math.random()-.5)*2)*8);
							local f2 = Instance.new("Fire");
							f2.Color=Color3.new(0,.4,1);
							f2.SecondaryColor = Color3.new(0,1,1);
							f2.Size = 5;
							f2.Heat = 10;
							f2.Parent = p2; 
							local bf=Instance.new("BodyForce");
							bf.force=Vector3.new(0,p2:GetMass()*196.2,0);
							bf.Parent=p2;
							local sc=gearConfig.specialScript:clone();
							sc.Parent=p2;
							sc.Disabled=false;
							local c=Instance.new("ObjectValue");
							c.Name="creator";
							c.Value=game.Players.LocalPlayer;
							c.Parent=p2;
							gearConfig.debris:AddItem(p2,1);
							p2.Parent=workspace;
						end
						wait(.1);
					end
					wait(2.5);
					if frost then
						frost.Enabled = false
					end	
					gearConfig.taunting.Value = false;
					wait(10);
					gearConfig.check = true;
				end		
			end
		end);
	end
end);
gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
	if (gearConfig.lastHumanoid ~= nil) then
		gearConfig.lastHumanoid.WalkSpeed = 16;
	end
end);
gearConfig.runAnim.Changed:connect(function()
	local h=gearConfig.gear.Parent:FindFirstChild("Humanoid")
	local t=gearConfig.gear.Parent:FindFirstChild("Torso")
	local anim=gearConfig.gear:FindFirstChild(gearConfig.runAnim.Value);
	if anim and t and h then
		local theanim=h:LoadAnimation(anim);
		if theanim and h.Health>0 then
			theanim:Play()
		end
	end
end);