--[[ alexnewtron 2014 ]]--

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local PlayersService = game:GetService('Players');
local DebrisService = game:GetService('Debris');

local Character = nil;
local Player = nil;
local Humanoid = nil;

local Check = true;

local d = { Debris = game:GetService("Debris") };
local s = { 
	["Equip"] = Gear.Handle:WaitForChild("Equip"),
	["Slash"] = Gear.Handle:WaitForChild("Slash1"),
	["Hit"] = Gear.Handle:WaitForChild("SwordHit"),
 };

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end


if (Gear:FindFirstChild("Ammo")) then
	Gear["Ammo"]:Destroy();
end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_START) then
		d.throw();
	elseif (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	end
end;


Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Equip");
	s["Equip"]:Play();
end);

Gear.Activated:connect(function()
	if not Check or not Humanoid or Humanoid.Health == 0 then return; end
	Check = false;
	local r = math.random(1,3);
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Slash"..r);
	spawn(function()
		for i=1, 15 do
			local p = Instance.new("Part", workspace);
			p.Transparency = 1;
			p.Anchored = true;
			p.CanCollide = false;
			p.Locked = true
			p.CFrame = Gear.Effect.CFrame;
			local f = Gear.Effect.Fire:Clone();
			f.Parent = p;
			f.Enabled = true;
			local s = Controller.F:Clone();
			s.Parent = p;
			s.Disabled = false;
			d.Debris:AddItem(p, 12);
			wait();
		end
	end)
	local sF = s["Slash"]:Clone();
	sF.Parent = Gear.Handle;
	sF.Name = "T";
	d.Debris:AddItem(sF, 4);
	sF:Play();
	wait(.3);
	Check = true;
end)

Gear.Unequipped:connect(function()
	Check = true;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);
end)

Gear.Handle.Touched:connect(function(p)
	if (Player ~= nil and Character ~= nil and p ~= nil and p.Parent ~= nil and p.Parent ~= Character) then
		local h = p.Parent:findFirstChild("Humanoid");
		local t = p.Parent:findFirstChild("Torso");
		if (h ~= nil and t ~= nil and h.Health > 0) then
			UntagHumanoid(h);
			TagHumanoid(h,Player);
			h:TakeDamage(10);	
			if (h.Health <= 0) then
				s["Hit"]:Play();
			end			
			if (t:findFirstChild("SWORD_FIRE") == nil) then
				local tD = p.Parent:GetChildren();
				for i=1, #tD do
					if (tD[i]:IsA("Part")) then
						local f = Instance.new("Fire", tD[i]);
						f.Name = "SWORD_FIRE";
						d.Debris:AddItem(f, 5);
					end
				end				
			end
		end
	end
end);