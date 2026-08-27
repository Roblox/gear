--[[ alexnewtron 2014 ]]--

damage=60
local tag=script.Parent:WaitForChild("creator")

local c = {
	a = {168187887, 168187896, 168187907, 168187916, 168187923, 168187935},
	d = 25,
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
	c.clients = game.Players:GetChildren();
	local pos = script.Parent.Position;
	for i=1, #c.clients do
		if (c.clients[i] and c.clients[i].Character and (c.clients[i].Character:FindFirstChild("Torso") or c.clients[i].Character:FindFirstChild("UpperTorso"))) and not IsTeamMate(c.creator.Value,c.clients[i]) and c.clients[i].Character ~= c.creator.Value.Character then
			if ((pos - (c.clients[i].Character:FindFirstChild("Torso") or c.clients[i].Character:FindFirstChild("UpperTorso")).Position).Magnitude < c.d) then
				table.insert(c.affectedClients, c.clients[i]);
			end
		end
	end	
	for i=1, #c.affectedClients do
		if (c.clients[i].Character:FindFirstChild("Torso") or c.clients[i].Character:FindFirstChild("UpperTorso")) then
			local t = (c.clients[i].Character:FindFirstChild("Torso") or c.clients[i].Character:FindFirstChild("UpperTorso"));
			local dist = Vector3.new(pos.x - t.Position.x, pos.y - t.Position.y, pos.z - t.Position.z);
			local bodyForce = Instance.new("BodyForce")
			bodyForce.Force = dist.unit * t:GetMass() * c.f;
			bodyForce.Parent = t;
			c.deb:AddItem(bodyForce, 0.5);
			
			local h=c.affectedClients[i].Character:FindFirstChildOfClass("Humanoid")	--Luke was here
			if h and tag then
				h.Sit=true
				UntagHumanoid(h)
				TagHumanoid(h,c.creator.Value)
				h:TakeDamage(damage)
			end																	--lol ok bye
			
			local pG = Instance.new("ScreenGui", c.affectedClients[i].PlayerGui);
			local f = Instance.new("Frame", pG);
			f.Size = UDim2.new(1,0,1,0);
			f.BackgroundTransparency = 1;			
			for i=1, 10 do
				local p = Instance.new("ImageLabel", f);
				p.BackgroundTransparency = 1;
				local size = (math.random()*.2)+.5;
				p.Size = UDim2.new(size, 0,size, 0);
				p.Image = "rbxassetid://"..c.a[math.random(1, #c.a)];
				p.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0);
				c.deb:AddItem(p, 5+(math.random()*2));
			end		
		end
	end
end
wait(2);
c.bang();
script.Parent.Transparency=1	--Luke was here too
script.Parent.Anchored=true
for i=1,5 do
	local f=Instance.new("Fire")
	f.Heat=1
	f.Color=Color3.new(math.random(0,1),math.random(0,1),math.random(0,1))
	f.SecondaryColor=Color3.new(math.random(0,1),math.random(0,1),math.random(0,1))
	f.Size=60
	delay(math.random()*.5,function()
		if f then
			f.Enabled=false
		end
	end)
	f.Parent=script.Parent
end								--kthx
wait(5)
script.Parent:Destroy();