--[[ alexnewtron 2014 ]]--
local config = {
	object = script.Parent,
	debris=game:GetService("Debris"),
	creator = script.Parent:WaitForChild("creator"),
};
config.object.Touched:connect(function(hit)
	if hit and hit~=nil and hit.Parent~=nil then
		local h=hit.Parent:FindFirstChild("Humanoid");
		local t=hit.Parent:FindFirstChild("Torso");
		if h~=nil and t~=nil then
			
			if config.creator.Value and config.creator.Value~=nil and t:FindFirstChild("FireWeld") then
				local plr=game.Players:GetPlayerFromCharacter(hit.Parent);
				if plr then
					if plr==config.creator.Value then
						return;
					end
				end
				h:TakeDamage(5);
			elseif (config.creator.Value and config.creator.Value~=nil and t:FindFirstChild("FireWeld") == nil) then
				local plr=game.Players:GetPlayerFromCharacter(hit.Parent);
				if plr then
					if plr==config.creator.Value then
						return;
					end
				end
				local d = script.death:Clone();
				d.creator.Value = config.creator.Value;
				d.Parent = t;
				d.Disabled = false;
				local p=Instance.new("Part");
				p.Name="Effect";
				p.BrickColor=BrickColor.new("Pastel light blue");
				p.FormFactor="Custom";
				p.Size=Vector3.new(2,2,2);
				p.Transparency=1;
				p.CanCollide=false;
				p.TopSurface="Smooth";
				p.BottomSurface="Smooth";
				local f = Instance.new("Fire");
				f.Color=Color3.new(255/255,127/255,0);
				f.Size=15;
				f.Heat=25;
				f.Parent=p;
				local cf=CFrame.Angles(0,math.pi*2*math.random(),.5*math.random());
				p.CFrame=t.CFrame*cf;
				local w=Instance.new("Motor");
				w.Name="FireWeld";
				w.Part0=t;
				w.Part1=p;
				w.C0=CFrame.Angles(0,math.pi*2*math.random(),.5*math.random());
				w.Parent=t;
				config.debris:AddItem(p,8);
				p.Parent=workspace;
			--	h.WalkSpeed=5;
				delay(0,function()
					wait(10+math.random())
					if h and h~=nil then
				--		h.WalkSpeed=16;
					end
					if p and p~=nil then
						p:Destroy();
					end
				end)
				config.object:Destroy();
			end
		end
	end
end)
wait(.8);
config.object:Destroy();
