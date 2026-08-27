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

local d = { 
	Debris = game:GetService("Debris"),
	push = -1000
};
local s = { 
	["Swing"] = Gear.Handle:WaitForChild("Swing"),
	["Slap"] = Gear.Handle:WaitForChild("Slap")
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
end);

Gear.Activated:connect(function()
	if not Check or not Humanoid or Humanoid.Health == 0 then return; end
	Check = false;
	local r = math.random(2,4);
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Slash"..r.."Anim");
	s["Swing"]:Play();
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
			local hitDeb = t:findFirstChild("hit-deb");
			if (hitDeb == nil) then
				-- Home run!
				local pos = Gear.Handle.Position;
				local dist = Vector3.new(pos.x - t.Position.x, pos.y - t.Position.y, pos.z - t.Position.z);
				local bodyForce = Instance.new("BodyForce")
				bodyForce.force = dist.unit * t:GetMass() * d.push;
				bodyForce.Parent = t;
				d.Debris:AddItem(bodyForce, .5);
				h.Sit = true;				
				local c = Instance.new("BoolValue", t);
				c.Name = "hit-deb";				
				d.Debris:AddItem(c, 3);	
				s["Slap"]:Play();
			end			
		end
	end
end);