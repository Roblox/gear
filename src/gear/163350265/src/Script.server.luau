--[[ alexnewtron 2014 ]]--
local GLib = require(206209239)
script.Parent:WaitForChild("Handle");
local gearConfig = {
	gear = script.Parent,
	plyr = nil,
	equipped = false,
	check = true,
	attackReady = false,
	attacking = false,
	firePiece = {},
	debris = game:GetService("Debris"),
	gulping = script.Parent.Handle:WaitForChild("gulp"),
	sigh = script.Parent.Handle:WaitForChild("sigh"),
	dragon = script.Parent.Handle:WaitForChild("dragon"),
	anims = {
		script.Parent:WaitForChild("drink"),
		script.Parent:WaitForChild("attack")
	},
	readyAnims = {}
};

pcall(function() script.Parent:WaitForChild("FireBreath"):Destroy(); end);

function gearConfig.attack()
	gearConfig.dragon:Play();
	gearConfig.readyAnims[2]:Play();
	gearConfig.readyAnims[2]:AdjustSpeed(0.325);
	local pHead = gearConfig.plyr.Character.Head;
	for i=1, 3 do
		local p = Instance.new("Part");
		p.Name = "Dragon";
		p.Size = Vector3.new(1,1,1);
		p.CFrame = CFrame.new(pHead.Position, pHead.CFrame.lookVector);
		p.CanCollide = false;
		p.Transparency = 1;
		gearConfig.debris:AddItem(p, 6.5);
		p.Parent = pHead;
		table.insert(gearConfig.firePiece, p);
		local w = Instance.new("Weld", p);
		w.Part0 = pHead;
		w.Part1 = p;
		w.C0 = CFrame.new(0,0,-2 * i)*CFrame.Angles(-1.5,0,0);
		w.C1 = CFrame.new(0,0,0)*CFrame.Angles(0,0,0);
		local f = Instance.new("Fire",p);
		f.Size = 5;
		f.Heat = 25;
	end
	wait(7.5);
	gearConfig.attacking = false;
	gearConfig.check = true;
	gearConfig.firePiece = {};
end
gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
	gearConfig.check = true;
	for i=1, #gearConfig.readyAnims do
		gearConfig.readyAnims[i]:Stop();
	end
	if (gearConfig.attacking and #gearConfig.firePiece ~= 0) then
		for i=1, #gearConfig.firePiece do
			gearConfig.firePiece[i]:Destroy();
		end
		gearConfig.firePiece = {};
		gearConfig.attacking = false;		
		gearConfig.dragon:Stop();		
		local s = Instance.new("Sound", gearConfig.plyr.Character.Head);
		s.SoundId = "http://www.roblox.com/asset/?id=163212600";
		s.Pitch = 1;
		s.Volume = 0.85;
		s.Looped = false;
		gearConfig.debris:AddItem(s, 5);
		s:Play();		
	end
end);
gearConfig.gear.Equipped:connect(function()
	gearConfig.plyr = GLib.GetPlayerFromPart(script)
	gearConfig.equipped = true;
	if true then
		local human = script.Parent.Parent:findFirstChild("Humanoid");
		local torso = script.Parent.Parent:findFirstChild("Torso");
		gearConfig.readyAnims = {};
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));
		end	
		gearConfig.readyAnims[1].KeyframeReached:connect(function(k)
			if (k == "gulp") then
				gearConfig.gulping:Play();
				gearConfig.readyAnims[1]:AdjustSpeed(0.6);
			elseif (k == "done") then
				wait(.5);
				gearConfig.sigh:Play();
				wait(.5);
				gearConfig.attackReady = true;
			end
		end);
	end
end);
gearConfig.gear.Activated:connect(function()
	local char, plyr, human = GLib.GetCharacter(script)
	if (gearConfig.check and human.Health > 0) then
		gearConfig.check = false;
		gearConfig.attackReady = false;
		gearConfig.readyAnims[1]:Play();
		repeat wait(.5) until gearConfig.attackReady
		gearConfig.attacking = true;
		gearConfig.attack();
	end
end)