--[[ alexnewtron 2014 ]]--

local p = game.Players.LocalPlayer;
local h = p.Character:findFirstChild("Humanoid");

if (h ~= nil) then
	wait(7+math.random())
	h.WalkSpeed = 16;	
end