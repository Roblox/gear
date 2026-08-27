--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");
print(1);
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	debris = game:GetService("Debris"),
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	lastHumanoid = nil,
	anims = {
		script.Parent:WaitForChild("Eat"),
		script.Parent:WaitForChild("attack"),		
	},
	sounds = {},
	readyAnims = {}
};
function gearConfig.prepare()local a=gearConfig.tween("forward")a.add(1,{x=.85},gearConfig.easing.inOutQuad)a.add(1,{x=.005},gearConfig.easing.inOutQuad)for x=1,200 do local b=a.getCurrentProperties()gearConfig.gear.Handle.Mesh.Scale=Vector3.new(b.x,b.x,b.x)a.update(0.025)wait(0.025)if b.x<=.005 then break end end end
function gearConfig.fire()
	local head = game.Players.LocalPlayer.Character:findFirstChild("Head");
	if (head ~= nil) then
		gearConfig.readyAnims[2]:Play();
		for i=1, 3 do
			local p = Instance.new("Part");
			local fireball=Instance.new("Part");
			fireball.Transparency=0;
			fireball.Name="Effect";
			fireball.BrickColor=BrickColor.new("Bright orange");
			fireball.Shape="Ball";
			fireball.Size=Vector3.new(2,2,2);
			fireball.CanCollide=true;
			fireball.CFrame=CFrame.new(head.Position+head.CFrame.lookVector*4)
			fireball.Velocity=head.CFrame.lookVector*math.random(50,80)+Vector3.new(0,15,0);
			fireball.TopSurface="Smooth";
			fireball.BottomSurface="Smooth";
			local fM = Instance.new("SpecialMesh", fireball);
			fM.MeshId = "http://www.roblox.com/asset/?id=165709439";
			fM.TextureId = "http://www.roblox.com/asset/?id=165709478"
			local sound = Instance.new("Sound", fireball);
			sound.SoundId = "http://www.roblox.com/asset/?id=167488249"
			sound.Name = "Pop";
			local fire=Instance.new("Fire");
			fire.Parent=fireball;
			fireball.Parent = workspace;
			gearConfig.debris:AddItem(fireball, 5);
			local fireDeath=script.fireDeath:clone();
			fireDeath.Parent=fireball;
			fireDeath.creator.Value = game.Players.LocalPlayer;
			fireDeath.Disabled=false;
			wait(0.5);
		end
		gearConfig.gear.Handle.Mesh.Scale = Vector3.new(.85,.85,.85);
		gearConfig.readyAnims[2]:Stop();
		gearConfig.check = true;
	end	
end
gearConfig.gear.Equipped:connect(function(m)
	gearConfig.equipped = true;
	if (m ~= nil) then
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		gearConfig.lastHumanoid = human;
		if (#gearConfig.readyAnims == 0) then
			for i=1, #gearConfig.anims do
				table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
			end
			gearConfig.readyAnims[1].KeyframeReached:connect(function(k)
				if (k == "shrink") then
					gearConfig.prepare();
				elseif (k == "finish") then
					gearConfig.readyAnims[1]:Stop();
					gearConfig.fire();
				end
			end);
		end
		m.Button1Down:connect(function()
			if (gearConfig.check and human.Health > 0) then
				gearConfig.check = false; 
				gearConfig.readyAnims[1]:Play();
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
gearConfig.gear.Handle.Touched:connect(function(p)
	if (p ~= nil and p.Parent ~= nil and not gearConfig.check and p.Parent ~= game.Players.LocalPlayer.Character) then
		local h = p.Parent:findFirstChild("Humanoid");
		local t = p.Parent:findFirstChild("Torso");
		if (h ~= nil and t ~= nil and h.Health > 0) then
			local f = t:findFirstChild("fireDeath");
			if (f == nil) then
				local ff = script.fireDeath:Clone();
				ff.creator.Value = game.Players.LocalPlayer;
				ff.Parent = t;
				ff.Disabled = false;
			end
		end
	end
end);