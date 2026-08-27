local t = script.Parent;
local f = t:WaitForChild("Fire");
wait(4); f.Enabled = false; wait(2); t:Destroy();