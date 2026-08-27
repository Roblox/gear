--[[ alexnewtron 2014 ]]--


config = {
	arrow = script.Parent,
	damage = script.Parent:WaitForChild("dmg").Value,
	sound = script.Parent.Hum,
	objectHit = script.Parent:WaitForChild("HitObject"),
	playerHit = script.Parent:WaitForChild("HitPlayer"),
	light = script.Parent.Light,
	weld = script.Parent:WaitForChild("Weld"),
	w = 0.1
};
arrow = script.Parent;

if config.weld~=nil then
	if config.weld.Part0~=nil then
		hit=config.weld.Part0;
		local ct=config.arrow:WaitForChild("creator");
		if ct.Value~=nil and ct.Value.Character~=nil then
			if hit.Parent~=ct.Value.Character and hit.Name~="Handle" and hit.Name~="Effect" then
				local h=hit.Parent:FindFirstChild("Humanoid")
				local t=hit.Parent:FindFirstChild("Torso")
				if h~=nil and t~=nil and h.Health>0 then
					for i,v in ipairs(h:GetChildren()) do
						if v.Name=="creator" then
							v:remove()
						end
					end
					ct:clone().Parent=h
					config.playerHit:Play()
					h:TakeDamage(config.damage)
				else
					config.objectHit:Play()
				end
			end
		end
	end
end

Spawn(function()
	while ( script.Parent ~= nil ) do
		wait(math.random());
		config.light.Range = math.random(5,10);
	end
end);

wait(19);
script.Parent:Destroy();
config.sound:Stop();