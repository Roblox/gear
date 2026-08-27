--[[alexnewtron 2014]]--
local GLib = require(206209239)
local config = {
	g = script.Parent,
	check = true
}
function config.burn(hit)
	if hit and config.check and hit.Name~='NobleDragon' and hit.Name~='Effect' then
		config.check = false;
		local character, owner, humanoid = GLib.GetCharacter(hit)
		print('hit',hit,character,owner,humanoid)
		if character and humanoid then
			local creator=config.g:FindFirstChild("creator");
			if owner and creator and creator.Value and GLib.IsTeammate(owner, creator.Value) then
				config.check = true
				return;
			end
			humanoid:TakeDamage(25);
		end
		local fire=config.g:FindFirstChild("Fire");
		if fire then
			fire.Enabled=false;
		end
		config.g.Anchored=true;
		wait(3);
		config.g:destroy();
	end
end
config.g.Touched:connect(config.burn);

