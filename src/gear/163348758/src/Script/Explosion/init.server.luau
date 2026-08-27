--[[ alexnewtron 2014 ]]--
local GLib = require(206209239)
local config = {
	shell = script.Parent,
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	vP = script.Parent:WaitForChild("Victrola"),
	vE = script.Parent:WaitForChild("Explosion"),
	deb = game:GetService("Debris"),
	owner = script.Parent:WaitForChild("creator"),
	clients = game.Players:GetChildren(),
	force = -2000,
	affectedClients = {}
};
local pos = config.shell.Position;
config.shell.Anchored = true;
config.shell.CanCollide = false;
Spawn(function()local a=0;while config.shell.Parent~=nil do a=a+1;config.shell.CFrame=config.shell.CFrame*CFrame.Angles(0,math.pi/a,0)wait()end end)
Spawn(function()local a=config.tween("forward")a.add(2,{x=2.5},config.easing.outBack)a.add(2,{x=7},config.easing.outBack)for x=1,200 do local b=a.getCurrentProperties()config.shell.Mesh.Scale=Vector3.new(b.x,b.x,b.x)a.update(0.025)wait(0.025)if b.x>=7 then break end end end)
config.deb:AddItem(script.Parent, 10);
config.vP:Play();
local a=config.tween("forward")a.add(3,{x=1},config.easing.inOutQuad)a.add(3,{x=0.25},config.easing.inOutBack)wait(1.5)for x=1,200 do local b=a.getCurrentProperties()config.vP.Pitch=b.x;a.update(0.025)wait(0.025)if b.x<=0.3 then break end end
config.vP:Stop(); config.vE:Play();
Spawn(function()
	local p = Instance.new("Part");
	p.Size = Vector3.new(1,1,1);
	p.CFrame = script.Parent.CFrame;
	p.Anchored = true;
	p.Locked = true;
	p.CanCollide = false;
	p.BrickColor = BrickColor.new("Pastel brown");
	p.Shape = Enum.PartType.Ball;
	p.TopSurface = Enum.SurfaceType.Smooth;
	p.BottomSurface = Enum.SurfaceType.Smooth;
	p.Parent = script.Parent;
	local a=config.tween("forward")a.add(1,{x=1,t=0},config.easing.inOutQuad)a.add(1,{x=85,t=1},config.easing.inOutQuad)for x=1,200 do local b=a.getCurrentProperties()p.Size=Vector3.new(b.x,b.x,b.x)print(b.t);p.Transparency=b.t;a.update(0.025)wait(0.025)if b.x>=85 then break end end
end);
--and config.clients[i] ~= config.owner.Value
for i=1, #config.clients do
	if (config.clients[i] ~= nil and config.clients[i].Character ~= nil and config.clients[i].Character:findFirstChild("Torso") ~= nil) and not GLib.IsTeammate(config.clients[i], config.owner.Value) then
		if ((pos - config.clients[i].Character.Torso.Position).magnitude < 15) then
			table.insert(config.affectedClients, config.clients[i].Character);
		end
	end
end
for i=1, #config.affectedClients do
	if (config.affectedClients[i]:findFirstChild("Torso")) then
		local t = config.affectedClients[i].Torso;
		local dist = Vector3.new(pos.x - t.Position.x, pos.y - t.Position.y, pos.z - t.Position.z);
		local bodyForce = Instance.new("BodyForce")
		bodyForce.force = dist.unit * t:GetMass() * config.force;
		bodyForce.Parent = t;
		config.deb:AddItem(bodyForce, 0.5);
		t.Parent:FindFirstChild("Humanoid").Sit = true;
		local s = script["Sitter"]:Clone();
		s.Parent = t;
		s.Disabled = false;
		t.Parent:FindFirstChild("Humanoid"):TakeDamage(20);
	end
end
wait(0.5);
script.Parent:Destroy();