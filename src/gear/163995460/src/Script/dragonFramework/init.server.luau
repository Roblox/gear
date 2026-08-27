--[[ alexnewtron 2014 ]]--
local config = {
	b = script.Parent,
	m = script.Parent:WaitForChild("Mesh"),
	bP = script.Parent:WaitForChild("BodyPosition"),
	bG = script.Parent:WaitForChild("BodyGyro"),
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	owner = script.Parent:WaitForChild("creator"),
	fireS = script.Parent:WaitForChild("Fire"),
	maxDistance = 20,
	a = 0,
	fireScript = script:WaitForChild("FireballScript")
};
function config.findFirstClass(a,b)for c,d in pairs(a:children())do if d:IsA(b)then return d end end;return nil end
function config.getCreatorHealth()
	if config.owner and config.owner.Value and config.owner.Value.Parent==game.Players and config.owner.Value.Character and config.owner.Value.Character:findFirstChild("Humanoid") then
		return config.owner.Value.Character:FindFirstChild("Humanoid").Health;
	end
end
function config.getCreator()
	if config.owner and config.owner.Value and config.owner.Value.Parent==game.Players and config.owner.Value.Character then
		return config.owner.Value.Character:FindFirstChild("Head");
	end
end
function config.findFoe(cP)
	local r, h, d = nil, nil, config.maxDistance;
	for i,t in pairs(workspace:GetChildren()) do
		if (t:IsA("Model") and t ~= config.owner.Value.Character) then
			local head = t:findFirstChild("Head");
			local hu = config.findFirstClass(t,"Humanoid");
			if (head ~= nil and hu ~= nil and hu.Health > 0) then
				local m = (head.Position - cP).magnitude;
				if (m < config.maxDistance) then
					if (m < d) then
						local owner2 = game:GetService'Players':GetPlayerFromCharacter(t)
						if owner2 ~= nil and (owner2.TeamColor ~= config.owner.Value.TeamColor or owner2.Neutral or config.owner.Value.Neutral) then
							r = head;
							h = hu;
							d = m;
						end
					end
				end
			end
		end
	end
	return r, h;
end
function config.fire(pos)
	print("fireing");
	config.fireS:Play();
	local p = Instance.new("Part");
	local fireball=Instance.new("Part");
	fireball.Transparency=1;
	fireball.Name="Effect";
	fireball.BrickColor=BrickColor.new("Bright orange");
	fireball.Shape="Ball";
	fireball.Size=Vector3.new(2,2,2);
	fireball.CanCollide=false;
	fireball.CFrame=script.Parent.CFrame;
	fireball.Velocity=config.b.CFrame.lookVector*math.random(50,80)+Vector3.new(0,15,0);
	fireball.TopSurface="Smooth";
	fireball.BottomSurface="Smooth";
	config.owner:clone().Parent=fireball;
	local fire=Instance.new("Fire");
	fire.Parent=fireball;
	local firescript=config.fireScript:clone();
	firescript.Parent=fireball;
	firescript.Disabled=false;
	fireball.Parent=script.Parent;
end
config.b.Anchored = false;

Spawn(function()
	local a = 0;
	while (script.Parent.Parent ~= nil) do
		local w1_1 = CFrame.new(.5,0.1,.1)*CFrame.Angles(0,0,-0.5);
		local w1_2 = CFrame.new(.5,0.4,.1)*CFrame.Angles(0,0,0);
		local w2_1 = CFrame.new(-.6,.1,0)*CFrame.Angles(0,0,0.5);
		local w2_2 = CFrame.new(-.6,.4,0)*CFrame.Angles(0,0,0);
		if (a == 0) then
			a = 1;
			config.b.RightWingWeld.C0 = w1_1;
			config.b.LeftWingWeld.C0 = w2_1;
		elseif (a == 1) then
			a = 0;
			config.b.RightWingWeld.C0 = w1_2;
			config.b.LeftWingWeld.C0 = w2_2;
		end	
		wait(0.25);
	end
end);

while (script.Parent.Parent ~= nil) do
	wait(.1);
	local head = config.getCreator();
	if head and config.getCreatorHealth()>0 then
		config.bP.position = (head.CFrame*CFrame.new(3,0,0)).p;
		config.bG.cframe = CFrame.new(config.bP.position, head.Position + head.CFrame.lookVector * 10);
		local gT, gH = config.findFoe(head.Position);
		if (gT ~= nil and gH ~= nil) then
			config.bG.cframe = CFrame.new(config.bP.position, gT.Position);
			if (config.a >= 5) then
				config.a = 0;
				config.fire(gT.CFrame.lookVector);
			end
		end
		config.a = config.a + 1;
	else
		break;
	end
end
script.Parent:Destroy();
script:Destroy();