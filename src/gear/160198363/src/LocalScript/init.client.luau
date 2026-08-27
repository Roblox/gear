--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");

local gearConfig = {
	gear = script.Parent,
	equipped = false,
	isSwinging = false,
	attackDeb = true,
	check = true,
	debris = game:GetService("Debris"),
	anims = {
		script.Parent:WaitForChild("Slash2Anim"),
		script.Parent:WaitForChild("Slash3Anim"),
		script.Parent:WaitForChild("Slash4Anim"),
	},
	sounds = {
		script.Parent.Handle:WaitForChild("Slash1")
	},
	readyAnims = {},
	deb = 0.75,
	damage = 25
};

script.Parent.Handle:WaitForChild("PointLight").Enabled = true;

function gearConfig.trail()
	if (gearConfig.equipped) then
		local p = Instance.new("Part", script.Parent);
		p.Name = "lT";
		p.Size = Vector3.new(1,1,1);
		p.Transparency = 1;
		p.CFrame = gearConfig.gear.Handle.CFrame;
		p.Anchored = true;
		p.CanCollide = false;
		
		local lT = Instance.new("BillboardGui", p);
		lT.Name = "Trail";
		lT.Adornee = p;
		lT.Size = UDim2.new(10,0,10,0);
		
		local img = Instance.new("ImageLabel", lT);
		img.Name = "Trail";
		img.BackgroundTransparency = 1;
		img.Image = "http://www.roblox.com/asset/?id=159992610";
		img.ImageTransparency = 0.5;
		img.Size = UDim2.new(1,0,1,0);
		
		local light = Instance.new("PointLight", p);
		light.Name = "Light";
		light.Brightness = 10;
		light.Color = Color3.new(5/255,255/255,255/255);
		light.Range = 8;
		light.Enabled = true;
		light.Shadows = false;
		
		local c = script["c"]:Clone();
		c.Parent = img;
		c.Disabled = false;
		
		gearConfig.debris:AddItem(p, 10);
	end
end

script.Parent.Handle.Touched:connect(function(hit)
	if hit.Parent~=game.Players.LocalPlayer.Character and hit.Name~="Handle" and hit.Name~="Effect" and gearConfig.isSwinging and gearConfig.attackDeb then
		local h=hit.Parent:FindFirstChild("Humanoid");
		local t=hit.Parent:FindFirstChild("Torso");
		if h~=nil and t~=nil and h.Health>0 then
			gearConfig.attackDeb = false;
			for i,v in ipairs(h:GetChildren()) do
				if v.Name=="creator" then
					v:remove();
				end
			end
			local c = Instance.new("ObjectValue", h);
			c.Name = "creator";
			c.Value = game.Players.LocalPlayer;
			h:TakeDamage(gearConfig.damage);
			wait(0.05);
			gearConfig.attackDeb = true;
		end
	end
end);

gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
end);

gearConfig.gear.Equipped:connect(function(m)
	gearConfig.equipped = true;
	if (m ~= nil) then
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
		end
		
		m.Button1Down:connect(function()
			if (gearConfig.check and human.Health > 0) then
				gearConfig.check = false;
				local a = math.random(1, #gearConfig.readyAnims);
				gearConfig.readyAnims[a]:Play();
				gearConfig.sounds[math.random(1, #gearConfig.sounds)]:Play();
				gearConfig.isSwinging = true;
				Spawn(function() wait(gearConfig.deb); gearConfig.check = true; end);
				repeat gearConfig.trail(); wait(0.085) until gearConfig.check or not gearConfig.equipped		
				gearConfig.isSwinging = false;	
			end
		end);
		
		m.Button1Up:connect(function()
			if (gearConfig.check and human.Health > 0) then
				
			end
		end);
	end
end);