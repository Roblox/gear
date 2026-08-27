--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");
print(1);
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	debris = game:GetService("Debris"),
	lastHumanoid = nil,
	anims = {
		script.Parent:WaitForChild("OverHeadSwing")
	},
	sounds = {
		script.Parent.Handle:WaitForChild("Slash1")
	},
	readyAnims = {},
	deb = 0.75,
	damage = 25
};
pcall(function() gearConfig.gear:WaitForChild("Effect"):WaitForChild("Fire").Enabled = false; end);
function gearConfig.cloner()
	for i=1, 15 do
		local e = gearConfig.gear.Effect:Clone();
		e.CFrame = gearConfig.gear.Effect.CFrame;
		e.Anchored = true;
		e.CanCollide = false;
		gearConfig.debris:AddItem(e, 8);
		e.Parent = script.Parent.Parent;
		local ss = script.s:Clone();
		ss.Parent = e;
		ss.Disabled = false;
		wait(0.05);
	end
end
gearConfig.gear.Equipped:connect(function(m)
	gearConfig.equipped = true;
	if (m ~= nil) then
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		gearConfig.lastHumanoid = human;
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
		end		
		m.Button1Down:connect(function()
			if (gearConfig.check and human.Health > 0) then
				gearConfig.check = false; 
				gearConfig.gear.Effect.Fire.Enabled = true;
				Spawn(gearConfig.cloner);
				gearConfig.readyAnims[1]:Play(); -- Swing!
				gearConfig.sounds[1]:Play();
				wait(1);
				gearConfig.gear.Effect.Fire.Enabled = false;
				gearConfig.check = true;
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
			else
				for i,v in ipairs(h:GetChildren()) do
					if v.Name=="creator" then
						v:Destroy()
					end
				end	
				local creator_tag=Instance.new("ObjectValue");
				creator_tag.Value=game.Players.LocalPlayer;
				creator_tag.Name="creator";
				creator_tag.Parent=h;
				h:TakeDamage(2);
			end
		end
	end
end);