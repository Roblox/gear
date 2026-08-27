--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");

local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	callSound = script.Parent.Handle:WaitForChild("EagleCall"),
	lastEagle = script.Parent:WaitForChild("LastEagle"),
	debris = game:GetService("Debris"),
	maxDistance = 100,
	eagleHeight = 80,
	eagleDistance = 300,
	anims = {
		script.Parent:WaitForChild("Wave")
	},
	readyAnims = {}
};

function gearConfig.findFirstClass(a,b)for c,d in pairs(a:children())do if d:IsA(b)then return d end end;return nil end

function gearConfig.createEagle(attack, attackH)
	
	local attackLocation = attack.Position;

	local eagle = Instance.new("Part");
	eagle.Name = "Eagle-Attacking-"..attack.Parent.Name;
	eagle.Size = Vector3.new(0.7, 0.88, 3);
	eagle.FormFactor = Enum.FormFactor.Custom;
	eagle.Anchored = false;
	eagle.CanCollide = true;
	eagle.Locked = true;
	eagle.CFrame = CFrame.new(attackLocation+Vector3.new(0,gearConfig.eagleHeight,0))*CFrame.Angles(0,math.pi*2*math.random(),0)*CFrame.new(0,0,gearConfig.eagleDistance)
	local m = Instance.new("SpecialMesh", eagle);
	m.MeshType = Enum.MeshType.FileMesh;
	m.MeshId = "http://www.roblox.com/asset/?id=120647529";
	m.TextureId = "http://www.roblox.com/asset/?id=120647378";
	m.Scale = Vector3.new(1.25, 1.25, 1.25);
	local bP = Instance.new("BodyPosition", eagle);
	bP.maxForce = Vector3.new(9001, 9001, 9001);
	bP.D = 2500;
	bP.position = attack.Position;
	local bG = Instance.new("BodyGyro", eagle);
	bG.P = 10000;
	bG.maxTorque = Vector3.new(math.huge, math.huge, math.huge);
	local eagleA = Instance.new("ObjectValue");
	eagleA.Name = "EagleAttack";
	eagleA.Parent = eagle;
	eagleA.Value = attack;
	local eagleH = Instance.new("ObjectValue");
	eagleH.Name = "EagleAttackHumanoid";
	eagleH.Parent = eagle;
	eagleH.Value = attackH;
	local eagleS = script["eagleFramework"]:Clone();
	eagleS.Parent = eagle;
	gearConfig.debris:AddItem(eagle, 8);
	eagle.Parent = attack;
	eagleS.Disabled = false;	
	repeat wait() until eagle.Parent == nil
	return true;
end

function gearConfig.findFoe(cP)
	local r, h, d = nil, nil, gearConfig.maxDistance;
	for i,t in pairs(workspace:GetChildren()) do
		if (t:IsA("Model") and t ~= game.Players.LocalPlayer.Character) then
			local head = t:findFirstChild("Head");
			local hu = gearConfig.findFirstClass(t,"Humanoid");
			if (head ~= nil and hu ~= nil and hu.Health > 0) then
				local m = (head.Position - cP).magnitude;
				if (m < gearConfig.maxDistance) then
					if (m < d) then
						r = head;
						h = hu;
						d = m;
					end
				end
			end
		end
	end
	return r, h;
end


gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
end);

gearConfig.gear.Equipped:connect(function(m)
	gearConfig.equipped = true;
	if (m ~= nil) then
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		local torso=script.Parent.Parent:findFirstChild("Torso");
		gearConfig.readyAnims = {};
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
		end
		
		m.Button1Down:connect(function()
			if (gearConfig.check and human.Health > 0 and gearConfig.lastEagle.Value < tick()) then
				gearConfig.check = false;
				local gT, gH = gearConfig.findFoe(torso.Position);
				gearConfig.readyAnims[1]:Play();
				if (gT ~= nil and gH ~= nil) then
					gearConfig.callSound:Play();
					gearConfig.lastEagle.Value = (tick() + 5);
					gearConfig.createEagle(gT, gH);
					gearConfig.check = true;
				else
					local nb = script["NoOneNearby"]:Clone();
					nb.Parent = game.Players.LocalPlayer.PlayerGui;
					gearConfig.debris:AddItem(nb, 3); wait(3);					
					gearConfig.check = true;
				end
			end
		end);
	end
end);