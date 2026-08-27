local c = script.Parent:WaitForChild("creator").Value;
script.Parent.Touched:connect(function(p)
	if (p.Parent:findFirstChild("Humanoid") and game:GetService("Players"):GetPlayerFromCharacter(p.Parent) ~= c) then
		p.Parent["Humanoid"].Sit = true;
	end
end);