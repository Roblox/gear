--[[ alexnewtron 2014 ]]--

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local PlayersService = Game:GetService('Players');
local DebrisService = Game:GetService('Debris');

local Character = nil;
local Player = nil;
local Humanoid = nil;

Gear:WaitForChild("Handle");

local d = { Debris = game:GetService("Debris") };
local s = { ["Swing"] = Gear.Handle:WaitForChild("Swing")};

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	end
end;

Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	Gear.Activated:connect(function()
		if not Gear.Enabled or not Humanoid or Humanoid.Health == 0 then return; end
		Gear.Enabled = false;
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Wave");
		Spawn(function()
			for i=1, 8 do
				s["Swing"]:Play(); wait(.25);
			end
		end);
		wait(2);
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);
		local t = Instance.new("Part", workspace);
		d.Debris:AddItem(t, 15);
		t.CFrame = Character.Torso.CFrame + Vector3.new(0,4,0);
		t.Transparency = 0;
		t.CanCollide = false;
		local s = Instance.new("Smoke", t);
		s.RiseVelocity = 10;
		s.Size = 8;
		
		local m = Instance.new("SpecialMesh", t);
		m.MeshId = "http://www.roblox.com/asset/?id=102638417";
		m.Scale = Vector3.new(5,7,5);
		
		local bP = Instance.new("BodyPosition", t);
		bP.maxForce = Vector3.new(math.huge, math.huge, math.huge);
		bP.P = 10000;
		bP.position = Character.Torso.Position;
		
		local bG = Instance.new("BodyGyro", t);
		bG.maxTorque = Vector3.new(math.huge, math.huge, math.huge);
		bG.P = 3000;
		bG.D = 500;
		
		TagHumanoid(t, Player);
		
		local g = script.T:Clone();
		g.Parent = t;
		g.Disabled = false;
		
		Spawn(function()
			local eT = tick() + 15;
			while (tick() < eT) do
				local pos = (CFrame.new(Character.Torso.Position)*CFrame.Angles(0,math.pi*2*((tick()/10)%1),0)*CFrame.new(10,0,0));
				bP.position = pos.p;
				bG.cframe = pos;
				wait();
			end
		end);		
		
		local t = Game:GetService('InsertService'):LoadAsset(173791248):GetChildren()[1];
		d.Debris:AddItem(t, 15);
		t.Parent = workspace;
		t.CFrame = CFrame.new(Character.Torso.Position - Vector3.new(80,0,0));
		t.Anchored = false;
		t.CanCollide = false;
		
		local tbP = Instance.new("BodyPosition", t);
		tbP.maxForce = Vector3.new(math.huge, math.huge, math.huge);
		tbP.P = 500;
		tbP.position = (Character.Torso.Position + Vector3.new(80,0,0));
		
		local tBG = Instance.new("BodyGyro", t);
		tBG.maxTorque = Vector3.new(math.huge, math.huge, math.huge);
		tBG.P = 3000;
		tBG.D = 500;
		
		TagHumanoid(t, Player);
		
		local g = script.S:Clone();
		g.Parent = t;
		g.Disabled = false;
		
	--	tBG.cframe = CFrame.new(t.Position, tBG.cframe.p)*CFrame.Angles(0,-350,0);
		
		Spawn(function()
			local eT = tick() + 5;
			while (tick() < eT) do
				tBG.cframe = CFrame.new(t.Position, tBG.cframe.p)*CFrame.Angles(0,-350,0);
				wait();
			end
			tbP.position = t.Position - Vector3.new(0,20,0);
		end);
		
		wait(15);
		Gear.Enabled = true;
	end)
end);

Gear.Unequipped:connect(function()
	swing = false;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);
end)

