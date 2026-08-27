--[[ alexnewtron 2014 ]]--
--Updated for R15 avatars by StarWars

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
local s = { ["Launch"] = Gear.Handle:WaitForChild("Launch")};

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
	
	PIZZA = game:GetService("InsertService"):LoadAsset(175696937):GetChildren()[1];
		
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
end);

Gear.Activated:connect(function()
	if not Gear.Enabled or not Humanoid or Humanoid.Health == 0 then return; end
	Gear.Enabled = false;
	s["Launch"]:Play();
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "R15Cannon");
	else
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Cannon");
	end
	

	local r = math.random(1,2);
	if (r == 1) then
		-- SHIRT!
		local l = Instance.new("Part", workspace);
		l.Size = Vector3.new(1, 0.78, 1.64);
		
		d.Debris:AddItem(l, 10);
		
		local m = Instance.new("SpecialMesh", l);
		m.MeshId = "http://www.roblox.com/asset/?id=172282848"
		m.TextureId = "http://www.roblox.com/asset/?id=172282768"
		m.Scale = Vector3.new(2,2,2);
		
		l.CFrame=CFrame.new(Gear.Handle.Position+Gear.Handle.CFrame.lookVector*4)
		l.Velocity=Gear.Handle.CFrame.lookVector*math.random(50,80)+Vector3.new(0,35,0);	
		
		l.Touched:connect(function(p)
			if (p ~= nil and p.Parent ~= nil and p.Parent:FindFirstChild("Humanoid") ~= nil) then -- and p.Parent ~= Character
				--shirt time!
				
				for i, v in ipairs(p.Parent:GetChildren()) do
					if (v:IsA("Shirt")) then
						v:Destroy();
					end
				end
				
				local shirt = Instance.new("Shirt", p.Parent);
				shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=176080681";
				
				l:Destroy();					
			end
		end);			
		
	elseif (r == 2) then
		-- PIZZA!
		local l = Instance.new("Part", workspace);
		l.Size = Vector3.new(1, 0.78, 1.64);
		
		d.Debris:AddItem(l, 10);
		
		local m = Instance.new("SpecialMesh", l);
		m.MeshId = "http://www.roblox.com/asset/?id=172282868"
		m.TextureId = "http://www.roblox.com/asset/?id=172282768"
		m.Scale = Vector3.new(2,2,2);
		
		l.CFrame=CFrame.new(Gear.Handle.Position+Gear.Handle.CFrame.lookVector*4)
		l.Velocity=Gear.Handle.CFrame.lookVector*math.random(50,80)+Vector3.new(0,35,0);
		
		l.Touched:connect(function(p)
			if (p ~= nil and p.Parent ~= nil and p.Parent:FindFirstChild("Humanoid") ~= nil and p.Parent:findFirstChild("Roblox University PIZZA!") == nil and Player.Backpack:findFirstChild("Roblox University PIZZA!") == nil) then
				local p1 = PIZZA:Clone();
				p1.Parent = p.Parent;
				l:Destroy();
			end
		end);
	end
	wait(1.5);
	Gear.Enabled = true;
end)