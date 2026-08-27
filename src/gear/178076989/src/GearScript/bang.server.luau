--[[ alexnewtron 2014 ]]--
local c = {
	d = 20,
	f = -1500,
	deb = game:GetService("Debris"),
	s = script.Parent:WaitForChild("Splat"),
	clients = nil,	
	affectedClients = {},
	creator = script:WaitForChild("Creator")
}

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function c.bang()
	c.s:Play();
	c.clients = game:GetService("Players"):GetPlayers();
	local pos = script.Parent.Position;
	for i=1, #c.clients do
		if (c.clients[i] and c.clients[i].Character and (c.clients[i].Character:FindFirstChild("Torso") or c.clients[i].Character:FindFirstChild("UpperTorso"))) and not IsTeamMate(c.creator.Value,c.clients[i]) and c.clients[i].Character ~= c.creator.Value.Character then
			if ((pos - (c.clients[i].Character:FindFirstChild("Torso") or c.clients[i].Character:FindFirstChild("UpperTorso")).Position).Magnitude < c.d) then
				table.insert(c.affectedClients, c.clients[i]);
			end
		end
	end	
	for i=1, #c.affectedClients do
		local t = c.affectedClients[i].Character:FindFirstChild("Torso") or c.affectedClients[i].Character:FindFirstChild("UpperTorso")
		if t then
			local dist = Vector3.new(pos.x - t.Position.x, pos.y - t.Position.y, pos.z - t.Position.z);
			local bodyForce = Instance.new("BodyForce")
			local humanHit = t.Parent:FindFirstChildOfClass("Humanoid");
			bodyForce.Force = dist.unit * t:GetMass() * c.f;
			bodyForce.Parent = t;
			c.deb:AddItem(bodyForce, 0.5);
			if (humanHit) then
				humanHit.Sit = true;
				UntagHumanoid(humanHit)
				TagHumanoid(humanHit,c.creator.Value)
				humanHit:TakeDamage(30);
			end
			t.Parent:FindFirstChildOfClass("Humanoid").Sit = true;
			local pG = Instance.new("ScreenGui", c.affectedClients[i].PlayerGui);
			local f = Instance.new("Frame", pG);
			f.Size = UDim2.new(1,0,1,0);
			f.BackgroundTransparency = 1;	
		end
	end
end
wait(2);
c.bang();
script.Parent.Transparency = 1;
local e = Instance.new("Explosion", script.Parent);
e.ExplosionType = Enum.ExplosionType.NoCraters;
e.BlastPressure = 0;
e.BlastRadius = 500;
e.Position = script.Parent.Position;
wait(1.5);
script.Parent:Destroy();