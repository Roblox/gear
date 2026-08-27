--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	gearTitle = "ToD-11571622",
	slashAnim = nil,
	slashSound = script.Parent.Handle:WaitForChild("Slash"),
	thunderSound = script.Parent.Handle:WaitForChild("Lightning"),
	chargeSound = script.Parent.Handle:WaitForChild("Charging"),
	completedSound = script.Parent.Handle:WaitForChild("ChargeReady"),
	debris = game:GetService("Debris"),
	isCharging = false,
	isSwinging = false,
	chargingAnim = false,
	allowCharge = true,
	fullyCharged = false,
	good = false,
	attackDeb = true,
	animSpeed = 1,
	mesh = script.Parent.Handle:WaitForChild("Mesh"),
	sparkles = script.Parent.Handle:WaitForChild("Sparkles"),
	chargedSparkles = script.Parent.Handle:WaitForChild("Charged"),
	equipAnim = script.Parent:WaitForChild("Equip"),
	equipSound = script.Parent.Handle:WaitForChild("Equip"),
	light = script.Parent.Handle:WaitForChild("PointLight"),
	knownHuman = nil,
	pCamera = workspace.CurrentCamera,
	pFoV = 70,
	deb = 0.5,
	battleDeb = 0.5,
	TimeOfDay = nil,
	time = {},
	anims = {
		script.Parent:WaitForChild("LeftSlash"),
		script.Parent:WaitForChild("RightSlash")
	},
	chargeAnim = nil,
	readyAnims = {},
	damage = 10,
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	player = nil,
};

gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
	gearConfig.isCharging = false;
	gearConfig.fullyCharged = false;
	gearConfig.pCamera.FieldOfView = gearConfig.pFoV;
	gearConfig.light.Enabled = false;
	gearConfig.chargedSparkles.Enabled = false;
	gearConfig.deb = 0.5;
	gearConfig.battleDeb = 0.5;
	gearConfig.damage = 10;
	gearConfig.sparkles.Enabled = false;
	gearConfig.chargeSound:Stop();
	gearConfig.equipSound:Stop();
	if (gearConfig.chargeAnim ~= nil) then
		gearConfig.chargeAnim:Stop();
	end
	gearConfig.slashSound.Pitch = 0.85;
	gearConfig.damage = 10;
	if (gearConfig.knownHuman ~= nil) then
		gearConfig.knownHuman.WalkSpeed = 16;
	end
	if (gearConfig.good) then
		game.Lighting.TimeOfDay = gearConfig.originalToD;
		gearConfig.good = false;
	end
end);

gearConfig.mesh.VertexColor = Vector3.new(1,1,1);
gearConfig.chargedSparkles.Enabled = false;
gearConfig.sparkles.Enabled = false;

if (game.Lighting:findFirstChild(gearConfig.gearTitle)) then
	gearConfig.originalToD = game.Lighting[gearConfig.gearTitle].Value;
else
	local t = Instance.new("StringValue");
	t.Name = gearConfig.gearTitle;
	t.Value = game.Lighting.TimeOfDay;
	t.Parent = game.Lighting;
	gearConfig.originalToD = t.Value;
end

script.Parent.Handle.Touched:connect(function(hit)
	if hit.Parent~=gearConfig.player.Character and hit.Name~="Handle" and hit.Name~="Effect" and gearConfig.isSwinging and gearConfig.attackDeb then
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
			c.Value = gearConfig.player;
			h:TakeDamage(gearConfig.damage);
			wait(gearConfig.battleDeb);
			gearConfig.attackDeb = true;
		end
	end
end);

local inputcon
gearConfig.gear.Equipped:connect(function()
	if inputcon then inputcon:disconnect() inputcon = nil end
	gearConfig.player = game:GetService'Players':GetPlayerFromCharacter(gearConfig.gear.Parent)
	if not gearConfig.player then return end
	gearConfig.equipped = true;
	gearConfig.isCharging = false;
	gearConfig.fullyCharged = false;
	gearConfig.pCamera.FieldOfView = gearConfig.pFoV;
	gearConfig.mesh.VertexColor = Vector3.new(1,1,1);
	local human=script.Parent.Parent:findFirstChild("Humanoid");
	gearConfig.knownHuman = human;
	local eq = human:LoadAnimation(gearConfig.equipAnim);
	for i=1, #gearConfig.anims do
		table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
	end
	gearConfig.chargeAnim = human:LoadAnimation(script.Parent:WaitForChild("Charge"));
	eq:Play();
	gearConfig.equipSound:Play();
	
	inputcon = script.Parent.Input.OnServerEvent:connect(function(client, input, ...) print(gearConfig.player, client, input, ...)
		if client == gearConfig.player then
			if input == 'Mouse1Down' then
				if (gearConfig.check and human.Health > 0 and gearConfig.allowCharge and not gearConfig.isCharging) then
					gearConfig.isCharging = true;
					wait(0.5);
					if gearConfig.isCharging then
						gearConfig.chargeAnim:Play();
						gearConfig.chargeSound.Pitch = 1;
						gearConfig.chargeSound:Play();
						gearConfig.chargingAnim = true;
						Spawn(function()
							local ts = gearConfig.tween("forward");
							ts.add(2, {x = gearConfig.pFoV, y = 1, z = 16, n = 1}, gearConfig.easing.inOutQuad); ts.add(2, {x = 55, y = 0.5, z = 0, n = 0.2}, gearConfig.easing.inOutQuad);
							for x=1, 200 do
								local p = ts.getCurrentProperties();
								gearConfig.pCamera.FieldOfView = p.x;
								gearConfig.mesh.VertexColor = Vector3.new(p.n, p.n, p.n);
								gearConfig.chargeSound.Pitch = p.y;
								human.WalkSpeed = p.z;
								ts.update(0.025); wait(0.025);
								if not gearConfig.isCharging then gearConfig.pCamera.FieldOfView = gearConfig.pFoV; break; end
								if human.Health <= 0 then gearConfig.pCamera.FieldOfView = gearConfig.pFoV; gearConfig.isCharging = false; end
								if (p.x <= 55) then gearConfig.fullyCharged = true; gearConfig.sparkles.Enabled = true; gearConfig.completedSound:Play(); break; end
							end
						end);
					end
				end
			elseif input == 'Mouse1Up' then
				if (gearConfig.check and human.Health > 0) then
					human.WalkSpeed = 16;
					if gearConfig.fullyCharged then
						
						local lightning = Instance.new("Part");
						lightning.Transparency = 1;
						lightning.Size = Vector3.new(4,0.2,4);
						lightning.BrickColor = BrickColor.new("New Yeller");
						lightning.Position = script.Parent.Parent:findFirstChild("Head").Position + Vector3.new(0,25,0);
						lightning.Anchored = true;
						
						gearConfig.debris:AddItem(ll, 15);
						
						local m = Instance.new("CylinderMesh", lightning);
						m.Scale = Vector3.new(1,500,1);
						
						gearConfig.debris:AddItem(lightning, 10);
						lightning.Parent = script.Parent.Parent;
						
						gearConfig.thunderSound:Play();
						
						Spawn(function()
							local ts = gearConfig.tween("forward");
							ts.add(1, {x = 0.1, y = 0}, gearConfig.easing.inOutQuad); ts.add(1, {x = 10, y = 1}, gearConfig.easing.outBack);
							for x=1, 200 do
								local p = ts.getCurrentProperties();
								lightning.Size = Vector3.new(p.x,0.2,p.x);
								lightning.Transparency = p.y;
								if (script.Parent.Parent:findFirstChild("Head")) then
									lightning.Position = script.Parent.Parent:findFirstChild("Head").Position + Vector3.new(0,25,0);
								end
								ts.update(0.025); wait(0.025);
								if (p.x >= 10) then break; end
							end
							lightning:Destroy();
						end);
						
						Spawn(function()gearConfig.TimeOfDay=game.Lighting.TimeOfDay;for a in string.gmatch(game.Lighting.TimeOfDay,"%d+")do gearConfig.time[#gearConfig.time+1]=a end;local b=gearConfig.time[1]local c=gearConfig.time[2]local d=0;local e=0;local f=d-b/10;local g=e-c/10;for h=1,10 do b=b+f;c=c+g;if b>0 then game.Lighting.TimeOfDay=b..":"..c..":".."00"end;wait(0.1)end end)
						
						gearConfig.chargeAnim:Stop();
						gearConfig.mesh.VertexColor = Vector3.new(1,1,0.5);
						gearConfig.chargedSparkles.Enabled = true;
						gearConfig.sparkles.Enabled = false;
						gearConfig.deb = 0.01;
						gearConfig.battleDeb = 0.01;
						gearConfig.animSpeed = 2;
						gearConfig.slashSound.Pitch = 1;
						gearConfig.allowCharge = false;
						gearConfig.fullyCharged = false;
						gearConfig.damage = 40;
						gearConfig.good = true;
						gearConfig.light.Enabled = true;
						local moon = nil;				
						
						if (script.Parent.Parent:findFirstChild("Head")) then
							moon = Instance.new("BillboardGui");
							moon.Size = UDim2.new(10,0,10,0);
							moon.StudsOffset = Vector3.new(0,8,0);
							local m1 = Instance.new("ImageLabel", moon);
							m1.Name = "moon";
							m1.Image = "rbxassetid://160011283";
							m1.Size = UDim2.new(1,0,1,0);
							m1.BackgroundTransparency = 1;
							moon.Parent = script.Parent.Parent;
							moon.Adornee = script.Parent.Parent:findFirstChild("Head");
						end
						
						Spawn(function()local a=gearConfig.tween("forward")a.add(3,{x=gearConfig.pFoV,y=human.WalkSpeed},gearConfig.easing.inOutQuad)a.add(3,{x=120,y=human.WalkSpeed+15},gearConfig.easing.inOutQuad)for x=1,200 do local b=a.getCurrentProperties()gearConfig.pCamera.FieldOfView=b.x;human.WalkSpeed=b.y;a.update(0.025)wait(0.025)if b.x>=120 then break end end end)
						gearConfig.chargeSound:Stop();
						local t = 0;
						repeat wait(1) t = t + 1; until t >= 10 or human.Health <= 0 or gearConfig.equipped == false
						gearConfig.damage = 10;
						gearConfig.mesh.VertexColor = Vector3.new(1,1,1);
						gearConfig.chargedSparkles.Enabled = false;
						gearConfig.deb = 0.5;
						gearConfig.battleDeb = 0.5;
						gearConfig.animSpeed = 1;
						gearConfig.good = false;
						gearConfig.slashSound.Pitch = 0.85;
						gearConfig.allowCharge = true;
						gearConfig.fullyCharged = false;
						gearConfig.check = false;
						gearConfig.light.Enabled = false;
						game.Lighting.TimeOfDay = gearConfig.originalToD;
						if moon~=nil then Spawn(function()for a=1,50 do moon["moon"].ImageTransparency=moon["moon"].ImageTransparency+0.05;wait(0.05)if moon["moon"].ImageTransparency>=1 then break end end;moon:Destroy()end)end
						Spawn(function()local a=gearConfig.tween("forward")a.add(2,{x=120,y=human.WalkSpeed},gearConfig.easing.inOutQuad)a.add(2,{x=70,y=16},gearConfig.easing.inOutQuad)for x=1,200 do local b=a.getCurrentProperties()gearConfig.pCamera.FieldOfView=b.x;human.WalkSpeed=b.y;a.update(0.025)wait(0.025)if b.x<=gearConfig.pFoV then gearConfig.check=true;break end end end)
					else
						gearConfig.sparkles.Enabled = false;
						if (gearConfig.allowCharge) then
							gearConfig.mesh.VertexColor = Vector3.new(1,1,1);
						end
						gearConfig.slashAnim = gearConfig.readyAnims[math.random(1, #gearConfig.readyAnims)];
						gearConfig.check = false;
						gearConfig.isCharging = false;
						gearConfig.slashAnim:Play();
						gearConfig.slashAnim:AdjustSpeed(gearConfig.animSpeed);
						gearConfig.slashSound:Play();
						gearConfig.chargeSound:Stop();
						gearConfig.chargeAnim:Stop();
						gearConfig.isSwinging = true;
					end				
					wait(gearConfig.deb);
					gearConfig.check = true;
					gearConfig.isSwinging = false;
				end
			end
		end
	end)
end);

gearConfig.gear.Unequipped:connect(function()
	if inputcon then inputcon:disconnect() inputcon = nil end
end)