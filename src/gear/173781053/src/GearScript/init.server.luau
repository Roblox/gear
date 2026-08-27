--[[ alexnewtron 2014 ]]--

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local Character = nil;
local Player = nil;
local Humanoid = nil;

local Check = true;

local d = { Debris = game:GetService("Debris") };
local s = { ["Sizzle"] = Gear.Handle:WaitForChild("Sizzle"), ["Fire"] = Gear.Handle:WaitForChild("Fire") };

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end


function throw()
	local head = Character:findFirstChild("Head");
	if (head == nil) then return; end
	local targetPos = Controller:InvokeClient(Player, ClientAgent.REQUEST_TARGETPOINT);
	local lookAt = (targetPos - head.Position).unit;
	local launch = head.Position + 10 * lookAt;
	local ammo = Gear.Ammo:Clone();
	ammo.Transparency = 0;
	ammo.CFrame = CFrame.new(launch, launch + lookAt);
	ammo.Velocity = lookAt * 50;
	ammo.Parent = workspace;
	local force = Instance.new("BodyForce");
	force.force = Vector3.new(0,20,0);
	force.Parent = ammo;
	local t = script.bomb:Clone();
	t.Parent = ammo;
	t.Disabled = false;
	d.Debris:AddItem(ammo, 120);
	TagHumanoid(ammo, Player);
end


Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	s["Sizzle"]:Play();
	Gear.Ammo.Transparency = 0;
	Gear.Activated:connect(function()
		if not Check or not Humanoid or Humanoid.Health == 0 then return; end
		Check = false;
		Gear.Ammo.Transparency = 1;
		s["Fire"]:Play();
		s["Sizzle"]:Stop();
		throw();
		wait(1.5);
		Gear.Ammo.Transparency = 0;
		s["Sizzle"]:Play();
		Check = true;
	end)
end);

Gear.Unequipped:connect(function()
	s["Sizzle"]:Stop();
end);