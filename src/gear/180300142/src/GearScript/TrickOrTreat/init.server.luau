--[[ alexnewtron 2014 ]]--

local Pumpkin = script.Parent;
local Creator = Pumpkin:WaitForChild("creator");

local tween = require(script:WaitForChild("b"));
local easing = require(script:WaitForChild("e"));

local Deb = true;

local Debris = game:GetService("Debris");

function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

local Treat = game:GetService("InsertService"):LoadAsset(39258329):GetChildren()[1];

local Sounds = {
	["ToT"] = Pumpkin:WaitForChild("TrickOrTreat"),
	["Trick"] = Pumpkin:WaitForChild("Trick"),
	["Treat"] = Pumpkin:WaitForChild("Treat"),
	["Splat"] = Pumpkin:WaitForChild("Splat"),
	["Victory"] = Pumpkin:WaitForChild("Victory"),
	["Come1"] = Pumpkin:WaitForChild("Come1"),
	["Come2"] = Pumpkin:WaitForChild("Come2")
}

local ts = tween("forward");
ts.add(1, {pX = 1.2, pZ = 1.35, pY = 1.2, m = .7}, easing.outBack);
ts.add(1, {pX = 2.2, pZ = 2.35, pY = 2, m = 1.2}, easing.outBack);
for x=1, 40 do
	local p = ts.getCurrentProperties();
--	Pumpkin.Size = Vector3.new(p.pX, p.pZ, p.pY);
	Pumpkin.Mesh.Scale = Vector3.new(p.m, p.m, p.m);	
	ts.update(0.025); wait(0.025);
end

Pumpkin.Anchored = true;
Sounds["ToT"]:Play();
Debris:AddItem(Pumpkin, 120);

spawn(function()
	while Deb do
		wait(math.random(5,10));
		local a = math.random(1,2);
		if Deb then
			Sounds["Come"..a]:Play();
		end
	end
end);

Pumpkin.Touched:connect(function(hit)
	if (Deb and hit and hit ~= nil and hit.Parent and hit.Parent ~= nil) then
		local h = hit.Parent:findFirstChild("Humanoid");
		local t = hit.Parent:findFirstChild("Torso");
		if (h ~= nil and t ~= nil and h.Health > 0) then
			local r = math.random(1,2);
			Deb = false;
			if (r == 1) then -- TRICK
				h.WalkSpeed = 1;
				Sounds["Trick"]:Play();
				wait(2.5);
				Sounds["Splat"]:Play();
				Pumpkin.Transparency = 1;
				local e = Instance.new("Explosion", script.Parent);
				e.ExplosionType = Enum.ExplosionType.NoCraters;
				e.BlastPressure = 0;
				e.BlastRadius = 500;
				e.Position = script.Parent.Position;
				UntagHumanoid(h);
				Creator.Parent = h;
				h:TakeDamage(20);
				h.WalkSpeed = 16;
				Debris:AddItem(Pumpkin, 2);
			elseif (r == 2) then -- TREAT
				h.WalkSpeed = 1;
				Sounds["Treat"]:Play();
				wait(2.5);
				Sounds["Victory"]:Play();
				Pumpkin.Transparency = 1;				
				h.Health = h.Health + math.random(10,25);				
				local p1 = Treat:Clone();
				p1.Parent = t.Parent;
				h.WalkSpeed = 16;
				Debris:AddItem(Pumpkin, 2);
			end
		end
	end
end);