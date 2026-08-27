--[[ alexnewtron 2014 ]]--
local h = script.Parent;
local d = true;
local e = game:GetService("Debris");
local c = script:WaitForChild("creator");
local sound = script.Parent:WaitForChild("Pop");
function r(a)
	for i,v in ipairs(a:GetChildren()) do
		if v.Name=="creator" then
			v:Destroy()
		end
	end	
	local creator_tag=Instance.new("ObjectValue");
	creator_tag.Value=c.Value;
	creator_tag.Name="creator";
	creator_tag.Parent=a;
end
h.Touched:connect(function(p)
	if (p ~= nil and p.Parent ~= nil) then
		local human = p.Parent:findFirstChild("Humanoid");
		local t = p.Parent:findFirstChild("Torso");
		if (human ~= nil and t ~= nil and human.Health > 0 and p.Parent ~= c.Value.Character and t:findFirstChild("Fire") == nil) then
			d = false;
			local fire = Instance.new("Fire", t);
			fire.Color = Color3.new(1,0,0);
			e:AddItem(fire, 10);
			fire.Size = 15;
			for i=1, 3 do
				r(human)
				human:TakeDamage(19);
				wait(1.5);
			end
			fire:Destroy();
		else
			if d then
				d = false;
				sound:Play();
				h.Velocity = h.Velocity + Vector3.new(0,30,0); wait(0.5);
				d = true;
			end
		end
	end
end);