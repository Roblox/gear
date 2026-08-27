--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");

local gearConfig = {
	gear = script.Parent,
	equipped = false,
	plyr = nil,
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	check = true,
	control = 0,
	speed = 5,
	planeGoTo = nil,
	mouseDown = false,
	endPlane = false,
	m = nil,
	anims = {
		script.Parent:WaitForChild("Throw")
	},
	readyAnims = {},
	planePart = nil
};

gearConfig.gear.GripPos = Vector3.new(0,0,0);
gearConfig.gear.Handle.Mesh.Scale = Vector3.new(0.25, 0.25, 0.25);

function gearConfig.throwPlane()
	local vA = {up=1,mode=0,a=0};	
	vA.p = Instance.new("Part");
	gearConfig.planePart = vA.p
	vA.p.Name = gearConfig.plyr.Name.."'s Plane";
	vA.p.Parent = script.Parent.Parent;
	vA.p.Size = Vector3.new(1.75,1.72,3.8);
	vA.p.Locked = true;
	vA.p.CanCollide = true;	
	vA.m = Instance.new("SpecialMesh", vA.p);
	vA.m.MeshType = Enum.MeshType.FileMesh;
	vA.m.Scale = Vector3.new(0.25,0.25,0.25);
	vA.m.MeshId = "http://www.roblox.com/asset/?id=161268656";
	vA.m.TextureId = "http://www.roblox.com/asset/?id=161268679";
	vA.p.CFrame = gearConfig.gear.Handle.CFrame;
	vA.bP = Instance.new("BodyPosition", vA.p);
	vA.bP.maxForce = Vector3.new(math.huge, math.huge, math.huge);
	vA.bP.position = vA.p.Position;
	vA.bG = Instance.new("BodyGyro", vA.p);
	vA.bG.maxTorque = Vector3.new(math.huge, math.huge, math.huge);
	vA.pS = Instance.new("Sound", vA.p);
	vA.pS.Name = "Propeller";
	vA.pS.Looped = true;
	vA.pS.SoundId = "http://www.roblox.com/asset/?id=162896679";
	vA.pE = Instance.new("Sound", vA.p);
	vA.pE.Name = "Explosion";
	vA.pE.SoundId = "http://www.roblox.com/asset/?id=162271116";
	vA.aT = Instance.new("StringValue", vA.p);
	vA.aT.Name = "asset-type";
	vA.aT.Value = "ASSET_1930_PLANE";
	gearConfig.endPlane = false;
	
	vA.p.Touched:connect(function(p)
		local PAT = p:findFirstChild("asset-type");
		if (PAT ~= nil and gearConfig.control == 1) then
			if (PAT.Value == "ASSET_1930_PLANE") then
				local e = Instance.new("Explosion", vA.p);
				e.BlastPressure = 0;
				e.BlastRadius = 500;
				e.Position = vA.p.Position;
				e.ExplosionType = Enum.ExplosionType.NoCraters;
				vA.pE:Play();
				vA.pS:Stop();
				gearConfig.endPlane = true;
			end
		end
	end);
	local sitter = script.NeverSit:Clone()
	sitter.Parent = gearConfig.plyr.Character
	sitter.Disabled = false
	local delta = 0
	while (vA.up == 1) do
		if (vA.mode == 0) then
			vA.bP.position = vA.p.Position + vA.p.CFrame.lookVector * gearConfig.speed;
			vA.bG.cframe = CFrame.new(vA.p.Position, vA.bP.position);
			vA.a = vA.a + 1;
			if (vA.a >= 25) then
				vA.mode = 1;
			end
		elseif (vA.mode == 1) then
			vA.p.CanCollide = true
			local a=gearConfig.tween("forward")a.add(1,{m=0.25,x=1.75,y=1.72,z=3.8},gearConfig.easing.inOutQuad)a.add(1,{m=1,x=16,y=7.2,z=13},gearConfig.easing.inOutBack)for x=1,200 do local b=a.getCurrentProperties()vA.m.Scale=Vector3.new(b.m,b.m,b.m)vA.p.Size=Vector3.new(b.x,b.y,b.z)vA.bP.position=vA.p.Position+vA.p.CFrame.lookVector*gearConfig.speed/2;a.update(0.025)wait(0.025)if b.m>=1 then vA.mode=2;break end end
		elseif (vA.mode == 2) then
			local w = Instance.new("Weld", vA.p);
			w.Part0 = vA.p;
			w.Part1 = gearConfig.plyr.Character.Torso;
			w.C0 =CFrame.new(-0.1,1.5,-1)*CFrame.Angles(0,0,0);
			w.C1 = CFrame.new(0,0,0)*CFrame.Angles(0,0,0);
			sitter:Destroy()
			gearConfig.plyr.Character.Humanoid.Sit = true;
			vA.pS:Play();
			vA.mode = 3;
		elseif (vA.mode == 3) then
			gearConfig.control = 1;
			vA.bP.position = vA.p.Position + vA.p.CFrame.lookVector * gearConfig.speed*(delta/(1/30));
--			vA.p.CFrame = CFrame.new(vA.bP.position) * CFrame.Angles(vA.p.CFrame:toEulerAnglesXYZ())
			if (gearConfig.planeGoTo ~= nil) then
				local planeGoToWorld = vA.p.Position + gearConfig.planeGoTo
				vA.bG.cframe = CFrame.new(vA.p.Position, planeGoToWorld);
			end
			if (gearConfig.plyr.Character.Humanoid.Health <= 0 or gearConfig.endPlane or gearConfig.plyr.Character.Humanoid.Jump) then
				vA.mode = 4;
			end
		elseif (vA.mode == 4) then
			vA.p.CanCollide = false;
			gearConfig.control = 0;
			vA.pS:Stop();
			local a=gearConfig.tween("forward")a.add(1,{m=1,x=16,y=7.2,z=13},gearConfig.easing.inOutQuad)a.add(1,{m=0.25,x=1.75,y=1.72,z=3.8},gearConfig.easing.inOutBack)for x=1,200 do local b=a.getCurrentProperties()vA.m.Scale=Vector3.new(b.m,b.m,b.m)vA.p.Size=Vector3.new(b.x,b.y,b.z)vA.bP.position=gearConfig.gear.Handle.Position;vA.bG.cframe=CFrame.new(vA.p.Position,gearConfig.gear.Handle.Position)a.update(0.025)wait(0.025)if b.m<=0.25 then break end end
			vA.up = false;
		end	
		delta = wait();
	end
	vA.p:Destroy();
end

gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
end);

gearConfig.gear.Equipped:connect(function()
	gearConfig.plyr = game.Players:GetPlayerFromCharacter(gearConfig.gear.Parent)
	gearConfig.equipped = true;
	local human=script.Parent.Parent:findFirstChild("Humanoid");
	local torso=script.Parent.Parent:findFirstChild("Torso");
	gearConfig.readyAnims = {};
	for i=1, #gearConfig.anims do
		table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
	end
	gearConfig.readyAnims[1].KeyframeReached:connect(function(k)
		if (k == "throw") then
			if gearConfig.equipped then
				gearConfig.gear.Handle.Transparency = 1;
				gearConfig.throwPlane();
				gearConfig.gear.Handle.Transparency = 0;
				gearConfig.check = true;
			else
				gearConfig.check = true;
			end
		end
	end);
end);

script.Parent.Input.OnServerEvent:connect(function(client, action, ...)
	if client.Character == script.Parent.Parent then
		if action == 'Mouse1' then
			local down = ...
			
			if down then
				local human=script.Parent.Parent:findFirstChild("Humanoid");
				if (gearConfig.check and human.Health > 0) then
					gearConfig.check = false;
					gearConfig.readyAnims[1]:Play();
				end
				if (gearConfig.control == 1) then
					gearConfig.mouseDown = true;
				end
			else
				gearConfig.mouseDown = false;
			end
		elseif action == 'Key' then
			local down, key = ...
			
			if down then
				if (key == nil) then return; end
				local key = key:lower()
				if (key == ' ') then
					gearConfig.endPlane = true;
				end
			end
		elseif action == 'MouseUpdate' then
			local hit = ...
			
			
			if (gearConfig.control == 1 ) then
				if (gearConfig.mouseDown) and gearConfig.planePart then
					gearConfig.planeGoTo = hit.p - gearConfig.planePart.Position
				end
			end
		end
	end
end)