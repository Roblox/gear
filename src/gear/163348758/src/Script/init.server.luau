--[[ alexnewtron 2014 ]]--
local GLib = require(206209239)
script.Parent:WaitForChild("Handle");
local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	debris = game:GetService("Debris"),
	anims = {
		script.Parent:WaitForChild("Throw")
	},
	readyAnims = {}
};
function gearConfig.throwAsset()
	gearConfig.threwBomb = true
	local bomb = script.Parent.Handle:Clone()
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = script.Parent.Handle.Position;
	bomb.Name = "Victrola"
	bomb.Locked = true	
	local owner = Instance.new("ObjectValue", bomb);
	owner.Name = "creator";
	owner.Value = GLib.GetPlayerFromPart(script);
	local new_script = script["Explosion"]:clone()
	new_script.Disabled = false
	new_script.Parent = bomb	
	bomb.Parent = workspace
	script.Parent.Handle.Transparency = 1;
	repeat wait() until bomb.Parent == nil
	script.Parent.Handle.Transparency = 0;
	gearConfig.check = true;
	gearConfig.threwBomb = false
end
gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
	for i=1, #gearConfig.readyAnims do
		gearConfig.readyAnims[i]:Stop();
	end
	if not gearConfig.threwBomb then
		gearConfig.check = true
	end
end);
gearConfig.gear.Equipped:connect(function()
	gearConfig.equipped = true;
		local human = script.Parent.Parent:findFirstChild("Humanoid");
		local torso = script.Parent.Parent:findFirstChild("Torso");
		gearConfig.readyAnims = {};
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));
		end
		gearConfig.readyAnims[1].KeyframeReached:connect(function(k)
			if (k == "throw") then
				if gearConfig.equipped then
					gearConfig.throwAsset();
				else
				end
			end
		end);	
end);
gearConfig.gear.Activated:connect(function()
	local char, plyr, human = GLib.GetCharacter(script)
	if (gearConfig.check and human.Health > 0) then
		gearConfig.check = false;
		gearConfig.readyAnims[1]:Play();
	end
end)