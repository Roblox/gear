--[[ alexnewtron 2014 ]]--
local p = game.Players.LocalPlayer;
local i = 0;
while (i < 50) do
	i = i + 1;
	p.Character:findFirstChild("Humanoid").Sit = true;
	wait();
end
script:Destroy();