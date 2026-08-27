-- Original by Alexnewtron

--[[
	Fixed by ArceusInator
	- Works with FE
	- No longer spawns frozen
--]]
script.Parent:WaitForChild("Handle");
local remoteCon
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	damage = 0,
	anims = {},
	plyr = nil,
	roar = script.Parent.Handle:WaitForChild("Roar"),
	fireS = script.Parent.Handle:WaitForChild("Fire"),
	readyAnims = {}
};
gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
	
	if remoteCon then remoteCon:disconnect() remoteCon=nil end
end);
gearConfig.gear.Equipped:connect(function()
	gearConfig.plyr = game.Players:getPlayerFromCharacter(gearConfig.gear.Parent)
	local human=script.Parent.Parent:findFirstChild("Humanoid");
	gearConfig.readyAnims = {};
	for i=1, #gearConfig.anims do
		table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
	end
	remoteCon = gearConfig.gear.Click.OnServerEvent:connect(function(p)
		if p == gearConfig.plyr then
			if (gearConfig.check and human.Health > 0 and gearConfig.plyr.Character:findFirstChild("Torso")) then
				gearConfig.check = false;				
				local targetPos = human.TargetPoint;
				local character = gearConfig.plyr.Character;
				local torso = character:findFirstChild("Torso");
				local lookAt = (character.Head.Position).unit;
				local spawnPos = torso.Position + (lookAt);		
				gearConfig.roar:Play();
				local b = Instance.new("Part");
				b.Name = "NobleDragon";
				b.Size = Vector3.new(1.35,1.4,2.39);
				b.CanCollide = false;
				b.Anchored = true;
				b.Locked = true;
				local m = Instance.new("SpecialMesh", b);
				m.MeshType = "FileMesh";
				m.Scale = Vector3.new(2,2,2);
				m.MeshId = "http://www.roblox.com/asset/?id=163023421";
				m.TextureId = "http://www.roblox.com/asset/?id=163023507";				
				local wR = Instance.new("Part");
				wR.Name = "NobleDragon";
				wR.Size = Vector3.new(0.95,0.8,0.59);
				wR.CanCollide = false;
				wR.Locked = true;
				local m = Instance.new("SpecialMesh", wR);
				m.MeshType = "FileMesh";
				m.Scale = Vector3.new(2,2,2);
				m.MeshId = "http://www.roblox.com/asset/?id=163023449";
				m.TextureId = "http://www.roblox.com/asset/?id=163023507";
				wR.Parent = b;				
				local w = Instance.new("Weld", b);
				w.Name = "RightWingWeld";
				w.Part0 = b;
				w.Part1 = wR;
				w.C0 = CFrame.new(.5,.4,.1)*CFrame.Angles(0,0,0);
				w.C1 = CFrame.new(0,0,0)*CFrame.Angles(0,0,0);				
				local wL = Instance.new("Part");
				wL.Name = "NobleDragon";
				wL.Size = Vector3.new(0.95,0.8,0.59);
				wL.CanCollide = false;
				wL.Locked = true;
				local m = Instance.new("SpecialMesh", wL);
				m.MeshType = "FileMesh";
				m.Scale = Vector3.new(2,2,2);
				m.MeshId = "http://www.roblox.com/asset/?id=163023466";
				m.TextureId = "http://www.roblox.com/asset/?id=163023507";
				wL.Parent = b;				
				local w = Instance.new("Weld", b);
				w.Name = "LeftWingWeld";
				w.Part0 = b;
				w.Part1 = wL;
				w.C0 = CFrame.new(-.6,.4,0)*CFrame.Angles(0,0,0);
				w.C1 = CFrame.new(0,0,0)*CFrame.Angles(6,0,0);				
				local bP = Instance.new("BodyPosition", b);
				bP.maxForce = Vector3.new(400000, 400000, 400000);
				bP.P = 10000;
				bP.position = spawnPos;				
				local bG = Instance.new("BodyGyro", b);
				bG.maxTorque = Vector3.new(400000, 400000, 400000);
				bG.P = 3000;
				bG.D = 500;				
				b.Position = gearConfig.gear.Handle.Position;
				b.Parent = workspace;				
				local c = Instance.new("ObjectValue");
				c.Name = "creator";
				c.Value = gearConfig.plyr;
				c.Parent = b;
				gearConfig.fireS:Clone().Parent = b;
				local bScript = script["dragonFramework"]:Clone();
				bScript.Parent = b;
				bScript.Disabled = false;				
				script.Parent:Destroy();
				script:Destroy();
			end
		end
	end);
end);