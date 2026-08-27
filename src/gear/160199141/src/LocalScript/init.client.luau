--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	damage = 0,
	anims = {
		
	},
	plyr = game.Players.LocalPlayer,
	readyAnims = {}
};

gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
end);

gearConfig.gear.Equipped:connect(function(m)
	if (m ~= nil) then
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		gearConfig.readyAnims = {};
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
		end
		m.Button1Up:connect(function()
			if (gearConfig.check and human.Health > 0 and gearConfig.plyr.Character:findFirstChild("Torso")) then
				gearConfig.check = false;
				
				local targetPos = human.TargetPoint;
				local character = gearConfig.plyr.Character;
				local torso = character:findFirstChild("Torso");
				local lookAt = (character.Head.Position).unit;
				local spawnPos = torso.Position + (lookAt);
				
				-- Create the blimp
				local b = Instance.new("Part");
				b.Name = "Blimp";
				b.Size = Vector3.new(1,1,2);
				b.CanCollide = false;
				b.Anchored = true;
				b.Locked = true;
				local m = Instance.new("SpecialMesh", b);
				m.MeshType = "FileMesh";
				m.MeshId = "http://www.roblox.com/asset/?id=159797799";
				m.TextureId = "http://www.roblox.com/asset/?id=159797858";
				
				local bP = Instance.new("BodyPosition", b);
				bP.maxForce = Vector3.new(400000, 400000, 400000);
				bP.P = 10000;
				bP.position = spawnPos;
				
				local bG = Instance.new("BodyGyro", b);
				bG.maxTorque = Vector3.new(400000, 400000, 400000);
				bG.P = 3000;
				bG.D = 500;
				
				b.Position = spawnPos;
				b.Parent = game.Players.LocalPlayer.Character;
				
				local c = Instance.new("ObjectValue");
				c.Name = "creator";
				c.Value = gearConfig.plyr;
				c.Parent = b;
				
				local bScript = script["blimpFramework"]:Clone();
				bScript.Parent = b;
				bScript.Disabled = false;
				
				script.Parent:Destroy();
				script:Destroy();
			end
		end);
	end
end);