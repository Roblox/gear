--[[ alexnewtron 2014 ]]--
local c = {
	p = game.Players.LocalPlayer,
	h = game.Players.LocalPlayer.Character:findFirstChild("Humanoid"),
	debris=game:GetService("Debris"),
	c = script:WaitForChild("creator")
};
function c.r()
	for i,v in ipairs(c.h:GetChildren()) do
		if v.Name=="creator" then
			v:Destroy()
		end
	end	
	local creator_tag=Instance.new("ObjectValue");
	creator_tag.Value=c.c.Value;
	creator_tag.Name="creator";
	creator_tag.Parent=c.h;
end
if (c.h ~= nil) then
	for i=1, 5 do
		c.r();
		c.h:TakeDamage(7);
		wait(1.5);
	end	
end
script:Destroy();